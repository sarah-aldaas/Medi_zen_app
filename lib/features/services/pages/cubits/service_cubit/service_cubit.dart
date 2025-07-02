import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/services/data/datasources/services_remote_datasoources.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../data/model/health_care_service_filter.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServicesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency
  int _currentPage = 1;
  bool _hasMore = true;
  bool isLoading = false;
  Map<String, dynamic> _currentFilters = {};
  List<HealthCareServiceModel> allServices = [];

  ServiceCubit({
    required this.remoteDataSource,
    required this.networkInfo,
  }) : super(ServiceInitial());

  Future<void> getAllServiceHealthCare({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      allServices = [];
      emit(ServiceHealthCareLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }
    // Check internet connectivity for initial load
    if (!loadMore) {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        context.pushNamed(AppRouter.noInternet.name);
        emit(ServiceHealthCareError(error: 'No internet connection'));
        ShowToast.showToastError(message: 'No internet connection. Please check your network.');
        return;
      }
    }

    final result = await remoteDataSource.getAllHealthCareServices(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 5,
    );

    if (result is Success<PaginatedResponse<HealthCareServiceModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        allServices.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          ServiceHealthCareSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<HealthCareServiceModel>(
              paginatedData: PaginatedData<HealthCareServiceModel>(items: allServices),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(ServiceHealthCareError(error: result.data.msg ?? 'Failed to fetch health care services'));
      }
    } else if (result is ResponseError<PaginatedResponse<HealthCareServiceModel>>) {
      emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care services'));
    }
  }

  void checkAndReload({required BuildContext context}) {
    if (state is! ServiceHealthCareSuccess) {
      getAllServiceHealthCare(context: context);
    }
  }

  Future<void> getSpecificServiceHealthCare({
    required String id,
    required BuildContext context, // Add context parameter
  }) async {
    emit(ServiceHealthCareLoading());

    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceHealthCareError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    try {
      final result = await remoteDataSource.getSpecificHealthCareServices(id: id);
      if (result is Success<HealthCareServiceModel>) {
        emit(ServiceHealthCareModelSuccess(healthCareServiceModel: result.data));
      } else if (result is ResponseError<HealthCareServiceModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to fetch health care service details');
        emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care service details'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(ServiceHealthCareError(error: e.toString()));
    }
  }
}