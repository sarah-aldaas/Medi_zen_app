import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/medication_request_remote_data_source.dart';
import '../../../data/models/medication_request_model.dart';

part 'medication_request_state.dart';

class MedicationRequestCubit extends Cubit<MedicationRequestState> {
  final MedicationRequestRemoteDataSource remoteDataSource;

  MedicationRequestCubit({
    required this.remoteDataSource,
  }) : super(MedicationRequestInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<MedicationRequestModel> _allMedicationRequests = [];

  Future<void> getAllMedicationRequests({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedicationRequests = [];
      emit(MedicationRequestLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }
    final result = await remoteDataSource.getAllMedicationRequest(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<MedicationRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allMedicationRequests.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationRequestSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationRequestModel>(
            paginatedData: PaginatedData<MedicationRequestModel>(
              items: _allMedicationRequests,
            ),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(MedicationRequestError(
            error: result.data.msg ?? 'Failed to fetch medication requests'));
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationRequestModel>>) {
      emit(MedicationRequestError(
          error: result.message ?? 'Failed to fetch medication requests'));
    }
  }

  Future<void> getMedicationRequestsForAppointment({
    required String appointmentId,
    required String conditionId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedicationRequests = [];
      emit(MedicationRequestLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllMedicationRequestForAppointment(
      appointmentId: appointmentId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10, conditionId: conditionId,
    );

    if (result is Success<PaginatedResponse<MedicationRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allMedicationRequests.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationRequestSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationRequestModel>(
            paginatedData: PaginatedData<MedicationRequestModel>(
              items: _allMedicationRequests,
            ),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(MedicationRequestError(
            error: result.data.msg ?? 'Failed to fetch medication requests'));
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationRequestModel>>) {
      emit(MedicationRequestError(
          error: result.message ?? 'Failed to fetch medication requests'));
    }
  }

  Future<void> getMedicationRequestDetails({
    required String medicationRequestId,
    required BuildContext context,
  }) async {
    emit(MedicationRequestLoading());
    final result = await remoteDataSource.getDetailsMedicationRequest(
      medicationRequestId: medicationRequestId,
    );

    if (result is Success<MedicationRequestModel>) {
      if (result.data.statusReason == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(MedicationRequestDetailsSuccess(medicationRequest: result.data));
    } else if (result is ResponseError<MedicationRequestModel>) {
      emit(MedicationRequestError(
          error: result.message ?? 'Failed to fetch medication request details'));
    }
  }

  Future<void> getMedicationRequestForCondition({
    required String conditionId,
    required BuildContext context,
    Map<String, dynamic>? filters,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedicationRequests = [];
      emit(MedicationRequestLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }
    final result = await remoteDataSource.getAllMedicationRequestForCondition(
      conditionId: conditionId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<MedicationRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allMedicationRequests.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationRequestSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationRequestModel>(
            paginatedData: PaginatedData<MedicationRequestModel>(
              items: _allMedicationRequests,
            ),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(MedicationRequestError(
            error: result.data.msg ?? 'Failed to fetch medication requests'));
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationRequestModel>>) {
      emit(MedicationRequestError(
          error: result.message ?? 'Failed to fetch medication requests'));
    }
  }

}