import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/data_sources/address_remote_data_sources.dart';
import '../../../data/models/address_model.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRemoteDataSource remoteDataSource;
  List<AddressModel> _allAddresses = [];
  int _currentPage = 1;
  bool _hasMore = true;
  String? _typeIdFilter;
  String? _useIdFilter;

  AddressCubit({required this.remoteDataSource}) : super(AddressInitial());

  Future<void> fetchAddresses({bool loadMore = false,required BuildContext context}) async {
    try {
      if (!loadMore) {
        _allAddresses = [];
        _currentPage = 1;
        _hasMore = true;
        emit(AddressLoading(isFirstFetch: true));
      } else if (!_hasMore) {
        return;
      }

      final result = await remoteDataSource.getListAllAddress(
        page: _currentPage,
        perPage: 10,
        typeId: _typeIdFilter,
        useId: _useIdFilter,
      );

      if (result is Success<PaginatedResponse<AddressModel>>) {
        if(result.data.msg=="Unauthorized. Please login first."){
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        final newAddresses = result.data.paginatedData?.items ?? [];

        final updatedAddresses = List<AddressModel>.from(_allAddresses);

        final existingIds = updatedAddresses.map((addr) => addr.id).toSet();
        updatedAddresses.addAll(
          newAddresses.where((addr) => !existingIds.contains(addr.id)),
        );

        _allAddresses = updatedAddresses;
        _hasMore = result.data.meta?.currentPage != result.data.meta?.lastPage;

        if (_hasMore) {
          _currentPage++;
        }

        emit(
          AddressSuccess(
            paginatedResponse: PaginatedResponse<AddressModel>(
              status: result.data.status,
              errNum: result.data.errNum,
              msg: result.data.msg,
              paginatedData: PaginatedData<AddressModel>(items: _allAddresses),
              meta: result.data.meta,
              links: result.data.links,
            ),
            isLoadingMore: _hasMore,
          ),
        );
      } else if (result is ResponseError<PaginatedResponse<AddressModel>>) {
        emit(
          AddressError(error: result.message ?? 'Failed to fetch addresses'),
        );
      }
    } catch (e) {
      emit(AddressError(error: 'An unexpected error occurred'));
    }
  }

  Future<void> applyFilters({String? typeId, String? useId,required BuildContext context}) async {
    _typeIdFilter = typeId;
    _useIdFilter = useId;
    await fetchAddresses(context: context);
  }

  Future<void> createAddress({
  required BuildContext context,
    required AddOrUpdateAddressModel addressModel,
  }) async {
    emit(AddressLoading());
    try {
      final result = await remoteDataSource.createAddress(
        addressModel: addressModel,
      );
      if (result is Success<PublicResponseModel>) {
        if(result.data.msg=="Unauthorized. Please login first."){
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        if (result.data.status) {
          await fetchAddresses(context: context);
        } else {
          ShowToast.showToastError(message: result.data.msg);
          emit(AddressError(error: result.data.msg));
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(
          message: result.message ?? 'Failed to create Address',
        );
        emit(AddressError(error: result.message ?? 'Failed to create Address'));
      }
    } catch (e) {
      emit(AddressError(error: 'Failed to create address'));
    }
  }

  Future<void> updateAddress({
    required String id,
    required AddOrUpdateAddressModel? addressModel,required BuildContext context
  }) async {
    emit(AddressLoading());
    try {
      final result = await remoteDataSource.updateAddress(
        id: id,
        addressModel: addressModel!,
      );
      if (result is Success<PublicResponseModel>) {
        if(result.data.msg=="Unauthorized. Please login first."){
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        if (result.data.status) {
          await fetchAddresses(context: context);
        } else {
          ShowToast.showToastError(message: result.data.msg);
          emit(AddressError(error: result.data.msg));
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(
          message: result.message ?? 'Failed to update address',
        );
        emit(AddressError(error: result.message ?? 'Failed to update address'));
      }
    } catch (e) {
      emit(AddressError(error: 'Failed to update address'));
    }
  }

  Future<void> deleteAddress({required String id,required BuildContext context}) async {
    emit(AddressLoading());
    try {
      final result = await remoteDataSource.deleteAddress(id: id);
      if (result is Success<PublicResponseModel>) {
        if(result.data.msg=="Unauthorized. Please login first."){
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        if (result.data.status) {
          await fetchAddresses(context: context);
        } else {
          ShowToast.showToastError(message: result.data.msg);
          emit(AddressError(error: result.data.msg));
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(
          message: result.message ?? 'Failed to delete address',
        );
        emit(AddressError(error: result.message ?? 'Failed to delete address'));
      }
    } catch (e) {
      emit(AddressError(error: 'Failed to delete address'));
    }
  }

  Future<AddressModel?> showAddress({required String id}) async {
    emit(AddressLoading());
    try {
      final result = await remoteDataSource.showAddress(id: id);
      if (result is Success<AddressModel>) {
        return result.data;
      } else if (result is ResponseError<AddressModel>) {
        ShowToast.showToastError(
          message: result.message ?? 'Failed to fetch Address details',
        );
        emit(
          AddressError(
            error: result.message ?? 'Failed to fetch Address details',
          ),
        );
      }
    } catch (e) {
      emit(AddressError(error: 'Failed to fetch address details'));
    }
    return null;
  }
}
