import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/data_sources/address_remote_data_sources.dart';
import '../../../data/models/Address_model.dart';
part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRemoteDataSource remoteDataSource;

  AddressCubit({required this.remoteDataSource}) : super(AddressInitial());

  Future<void> fetchAddresses() async {
    emit(AddressLoading());
    final result = await remoteDataSource.getListAllAddress();
    if (result is Success<PaginatedResponse<AddressModel>>) {
      emit(AddressSuccess(
        paginatedResponse: result.data,
      ));
    } else if (result is ResponseError<PaginatedResponse<AddressModel>>) {
      emit(AddressError(error: result.message ?? 'Failed to fetch addresses'));
    }
  }


  Future<void> createAddress({required AddressModel addressModel}) async {
    emit(AddressLoading());
    final result = await remoteDataSource.createAddress(addressModel: addressModel);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await fetchAddresses();
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(AddressError(error: result.data.msg));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to create Address');
      emit(AddressError(error: result.message ?? 'Failed to create Address'));
    }
  }

  Future<void> updateAddress({required String id, required AddressModel addressModel}) async {
    emit(AddressLoading());
    final result = await remoteDataSource.updateAddress(id: id, addressModel: addressModel);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await fetchAddresses();
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(AddressError(error: result.data.msg));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to update address');
      emit(AddressError(error: result.message ?? 'Failed to update address'));
    }
  }

  Future<void> deleteAddress({required String id}) async {
    emit(AddressLoading());
    final result = await remoteDataSource.deleteAddress(id: id);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await fetchAddresses();
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(AddressError(error: result.data.msg));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to delete address');
      emit(AddressError(error: result.message ?? 'Failed to delete address'));
    }
  }

  Future<AddressModel?> showAddress({required String id}) async {
    emit(AddressLoading());
    final result = await remoteDataSource.showAddress(id: id);
    if (result is Success<AddressModel>) {
      return result.data;
    } else if (result is ResponseError<AddressModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch Address details');
      emit(AddressError(error: result.message ?? 'Failed to fetch Address details'));
      return null;
    }
    return null;
  }
}