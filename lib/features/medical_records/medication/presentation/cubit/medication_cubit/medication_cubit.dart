import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:meta/meta.dart';
import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../data/data_source/medication_remote_data_source.dart';
import '../../../data/models/medication_model.dart';

part 'medication_state.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final MedicationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MedicationCubit({required this.remoteDataSource, required this.networkInfo})
      : super(MedicationInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<MedicationModel> _allMedications = [];

  Future<void> getAllMedications({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedications = [];
      emit(MedicationLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(MedicationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getAllMedication(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<MedicationModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allMedications.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationModel>(
            paginatedData: PaginatedData<MedicationModel>(items: _allMedications),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(MedicationError(error: result.data.msg ?? 'Failed to fetch medications'));
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationModel>>) {
      emit(MedicationError(error: result.message ?? 'Failed to fetch medications'));
    }
  }

  Future<void> getMedicationsForAppointment({
    required String appointmentId,
    required String medicationRequestId,
    required String conditionId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedications = [];
      emit(MedicationLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllMedicationForAppointment(
      appointmentId: appointmentId,
      conditionId: conditionId,
      medicationRequestId: medicationRequestId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<MedicationModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allMedications.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationModel>(
            paginatedData: PaginatedData<MedicationModel>(items: _allMedications),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(MedicationError(error: result.data.msg ?? 'Failed to fetch medications'));
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationModel>>) {
      emit(MedicationError(error: result.message ?? 'Failed to fetch medications'));
    }
  }

  Future<void> getMedicationDetails({
    required String medicationId,
    required BuildContext context,
  }) async {
    emit(MedicationLoading());

    final result = await remoteDataSource.getDetailsMedication(medicationId: medicationId);
    if (result is Success<MedicationModel>) {
      if (result.data.name == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(MedicationDetailsSuccess(medication: result.data));
    } else if (result is ResponseError<MedicationModel>) {
      emit(MedicationError(error: result.message ?? 'Failed to fetch medication details'));
    }
  }

  Future<void> getAllMedicationForMedicationRequest({
    required String medicationRequestId,
    required String conditionId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allMedications = [];
      emit(MedicationLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(MedicationError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final result = await remoteDataSource.getAllMedicationForMedicationRequest(
      medicationRequestId: medicationRequestId,
      conditionId: conditionId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<MedicationModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allMedications.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(MedicationSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<MedicationModel>(
            paginatedData: PaginatedData<MedicationModel>(items: _allMedications),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(MedicationError(error: result.data.msg ?? 'Failed to fetch medications'));
      }
    } else if (result is ResponseError<PaginatedResponse<MedicationModel>>) {
      emit(MedicationError(error: result.message ?? 'Failed to fetch medications'));
    }
  }

}