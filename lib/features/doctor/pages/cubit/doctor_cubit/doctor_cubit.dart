import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../data/datasource/doctor_remote_datasource.dart';
import '../../../data/model/doctor_model.dart';

part 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  List<DoctorModel> allDoctors = [];

  DoctorCubit({
    required this.remoteDataSource,
    required this.networkInfo,
  }) : super(DoctorInitial());

  Future<void> getDoctorsOfClinic({
    required String clinicId,
    required BuildContext context,
  }) async {
    if (isLoading) return;
    isLoading = true;

    // Check internet connectivity
    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed(AppRouter.noInternet.name);
    //   emit(DoctorError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   isLoading = false;
    //   return;
    // }

    try {
      final result = await remoteDataSource.getDoctorsOfClinic(
        clinicId: clinicId,
        page: currentPage,
        perPage: 4,
      );

      if (result is Success<PaginatedResponse<DoctorModel>>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        final newDoctors = result.data.paginatedData?.items ?? [];
        allDoctors.addAll(newDoctors);

        final totalPages = result.data.meta?.lastPage ?? 1;
        hasMore = currentPage < totalPages;
        if (hasMore) {
          currentPage++;
        }

        emit(
          LoadedDoctorsOfClinicSuccess(
            allDoctors: allDoctors,
            hasMore: hasMore,
          ),
        );
      } else if (result is ResponseError<PaginatedResponse<DoctorModel>>) {
        emit(DoctorError(error: result.message ?? 'Failed to fetch doctors'));
      }
    } finally {
      isLoading = false;
    }
  }
}