import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../data/datasources/clinic_remote_datasources.dart';
import '../../../data/models/clinic_model.dart';

part 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  final ClinicRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  String? currentSearchQuery;
  List<ClinicModel> allClinics = [];
  bool _isClosed = false;

  ClinicCubit({
    required this.remoteDataSource,
    required this.networkInfo,
  }) : super(ClinicInitial());

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  Future<void> fetchClinics({
    required BuildContext context,
    String? searchQuery,
    bool loadMore = false,
  }) async {
    if (isLoading) return;
    isLoading = true;



    if (!loadMore) {
      currentPage = 1;
      hasMore = true;
      currentSearchQuery = searchQuery;
      allClinics.clear();
      emit(ClinicLoading(isInitialLoad: true));
    } else {
      if (!hasMore) {
        isLoading = false;
        return;
      }
      currentPage++;
    }


    // Check internet connectivity for initial load
    if (!loadMore) {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        context.pushNamed(AppRouter.noInternet.name);
        emit(ClinicError(error: 'No internet connection'));
        ShowToast.showToastError(message: 'No internet connection. Please check your network.');
        isLoading = false;
        return;
      }
    }
    try {
      final result = await remoteDataSource.getAllClinics(
        searchQuery: currentSearchQuery,
        page: currentPage,
        perPage: 15,
      );

      if (result is Success<PaginatedResponse<ClinicModel>>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        if (!result.data.status! || result.data.paginatedData == null) {
          hasMore = false;
          emit(
            allClinics.isEmpty
                ? ClinicEmpty(message: result.data.msg!)
                : ClinicSuccess(clinics: allClinics),
          );
          isLoading = false;
          return;
        }

        final newClinics = result.data.paginatedData!.items;

        final newUniqueClinics = newClinics
            .where(
              (newClinic) => !allClinics.any(
                (existingClinic) => existingClinic.id == newClinic.id,
          ),
        )
            .toList();

        allClinics.addAll(newUniqueClinics);
        hasMore = newClinics.length >= 15;

        emit(ClinicSuccess(clinics: allClinics));
      } else if (result is ResponseError<PaginatedResponse<ClinicModel>>) {
        emit(ClinicError(error: result.message ?? 'Failed to fetch Clinics'));
        if (loadMore) currentPage--;
      }
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchClinicsHomePage({
    required BuildContext context,
    String? searchQuery,
    bool loadMore = false,
  }) async {
    if (isLoading) return;
    isLoading = true;



    if (!loadMore) {
      currentPage = 1;
      hasMore = true;
      currentSearchQuery = searchQuery;
      allClinics.clear();
      emit(ClinicLoading(isInitialLoad: true));
    } else {
      if (!hasMore) {
        isLoading = false;
        return;
      }
      currentPage++;
    }
// Check internet connectivity for initial load
    if (!loadMore) {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        context.pushNamed(AppRouter.noInternet.name);
        emit(ClinicError(error: 'No internet connection'));
        ShowToast.showToastError(message: 'No internet connection. Please check your network.');
        isLoading = false;
        return;
      }
    }

    try {
      final result = await remoteDataSource.getAllClinics(
        searchQuery: currentSearchQuery,
        page: currentPage,
        perPage: 8,
      );

      if (result is Success<PaginatedResponse<ClinicModel>>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        if (!result.data.status! || result.data.paginatedData == null) {
          hasMore = false;
          emit(
            allClinics.isEmpty
                ? ClinicEmpty(message: result.data.msg!)
                : ClinicSuccess(clinics: allClinics),
          );
          isLoading = false;
          return;
        }

        final newClinics = result.data.paginatedData!.items;

        final newUniqueClinics = newClinics
            .where(
              (newClinic) => !allClinics.any(
                (existingClinic) => existingClinic.id == newClinic.id,
          ),
        )
            .toList();

        allClinics.addAll(newUniqueClinics);
        hasMore = newClinics.length >= 8;

        emit(ClinicSuccess(clinics: allClinics));
      } else if (result is ResponseError<PaginatedResponse<ClinicModel>>) {
        emit(ClinicError(error: result.message ?? 'Failed to fetch Clinics'));
        if (loadMore) currentPage--;
      }
    } finally {
      isLoading = false;
    }
  }

  Future<void> getSpecificClinic({
    required String id,
    required BuildContext context, // Add context parameter
  }) async {
    if (_isClosed) return;

    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;
    emit(ClinicLoading());

    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ClinicError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    try {
      final result = await remoteDataSource.getSpecificClinic(id: id);
      if (_isClosed) return;

      if (result is Success<ClinicModel>) {
        emit(ClinicLoadedSuccess(clinic: result.data));
      } else if (result is ResponseError<ClinicModel>) {
        ShowToast.showToastError(
          message: result.message ?? 'Failed to fetch clinic details',
        );
        emit(
          ClinicError(
            error: result.message ?? 'Failed to fetch clinic details',
          ),
        );
      }
    } catch (e) {
      if (!_isClosed) {
        emit(ClinicError(error: 'An unexpected error occurred'));
      }
    }
  }
}