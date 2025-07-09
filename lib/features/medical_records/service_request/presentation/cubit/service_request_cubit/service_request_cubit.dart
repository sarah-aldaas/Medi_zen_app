import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/network_info.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../data/data_source/service_request_remote_data_source.dart';
import '../../../data/models/service_request_model.dart';

part 'service_request_state.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  final ServiceRequestRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  int _currentPage = 1;
  bool _hasMore = true;
  List<ServiceRequestModel> _allRequests = [];
  Map<String, dynamic> _currentFilters = {};

  ServiceRequestCubit({
    required this.remoteDataSource,
    required this.networkInfo,
  }) : super(ServiceRequestInitial());

  Future<void> getServiceRequests({
    required BuildContext context,
    Map<String, dynamic>? filters,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allRequests = [];
      emit(ServiceRequestLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError("No internet connection"));
      return;
    }

    final result = await remoteDataSource.getAllServiceRequest(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ServiceRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      if (result.data.status!) {
        _allRequests.addAll(result.data.paginatedData!.items);
        _hasMore =
            result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          ServiceRequestLoaded(
            paginatedResponse: PaginatedResponse<ServiceRequestModel>(
              paginatedData: PaginatedData<ServiceRequestModel>(
                items: _allRequests,
              ),
              meta: result.data.meta,
              links: result.data.links,
            ),
            hasMore: _hasMore,
          ),
        );
      } else {
        emit(
          ServiceRequestError(
            result.data.msg ?? 'Failed to load service requests',
          ),
        );
      }
    } else if (result
        is ResponseError<PaginatedResponse<ServiceRequestModel>>) {
      emit(
        ServiceRequestError(
          result.message ?? 'Failed to load service requests',
        ),
      );
    }
  }

  Future<void> getServiceRequestsOfAppointment({
    required BuildContext context,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required String appointmentId,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allRequests = [];
      emit(ServiceRequestLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError("No internet connection"));
      return;
    }

    final result = await remoteDataSource.getAllServiceRequestForAppointment(
      appointmentId: appointmentId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ServiceRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      if (result.data.status!) {
        _allRequests.addAll(result.data.paginatedData!.items);
        _hasMore =
            result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          ServiceRequestLoaded(
            paginatedResponse: PaginatedResponse<ServiceRequestModel>(
              paginatedData: PaginatedData<ServiceRequestModel>(
                items: _allRequests,
              ),
              meta: result.data.meta,
              links: result.data.links,
            ),
            hasMore: _hasMore,
          ),
        );
      } else {
        emit(
          ServiceRequestError(
            result.data.msg ?? 'Failed to load service requests',
          ),
        );
      }
    } else if (result
        is ResponseError<PaginatedResponse<ServiceRequestModel>>) {
      emit(
        ServiceRequestError(
          result.message ?? 'Failed to load service requests',
        ),
      );
    }
  }

  Future<void> getServiceRequestDetails(
    String serviceId,
    BuildContext context,
  ) async {
    emit(ServiceRequestLoading(isDetailsLoading: true));

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ServiceRequestError('No internet connection'));
      return;
    }
    final result = await remoteDataSource.getDetailsServiceRequest(
      serviceId: serviceId,
    );

    if (result is Success<ServiceRequestModel>) {
      emit(
        ServiceRequestLoaded(
          serviceRequestDetails: result.data,
          hasMore: _hasMore,
          paginatedResponse:
              state is ServiceRequestLoaded
                  ? (state as ServiceRequestLoaded).paginatedResponse
                  : null,
        ),
      );
    } else {
      emit(ServiceRequestError('Failed to load service request details'));
    }
  }

  void clearDetails() {
    if (state is ServiceRequestLoaded) {
      emit(
        ServiceRequestLoaded(
          paginatedResponse: (state as ServiceRequestLoaded).paginatedResponse,
          hasMore: _hasMore,
        ),
      );
    }
  }
}
