import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/data/models/public_response_model.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/profile/data/data_sources/profile_remote_data_sources.dart';

import '../../../../../base/constant/storage_key.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/di/injection_container_common.dart';
import '../../../../../base/services/storage/storage_service.dart';
import '../../../data/models/update_profile_request_Model.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Add NetworkInfo dependency

  ProfileCubit({required this.remoteDataSource, required this.networkInfo})
    : super(ProfileState.initial());

  Future<void> fetchMyProfile({required BuildContext context}) async {
    emit(ProfileState.loading());

    // Check internet connectivity
    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed(AppRouter.noInternet.name);
    //   emit(ProfileState.error('No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    try {
      final result = await remoteDataSource.getMyProfile();
      result.fold(
        success: (PatientModel patient) {
          serviceLocator<StorageService>().savePatient(
            StorageKey.patientModel,
            patient,
          );
          emit(ProfileState.success(patient));
        },
        error: (String? message, int? code, PatientModel? data) {
          emit(ProfileState.error(message ?? 'Failed to fetch profile'));
        },
      );
    } catch (e) {
      emit(ProfileState.error('Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> updateMyProfile({
    required UpdateProfileRequestModel updateProfileRequestModel,
    required BuildContext context,
  }) async {
    emit(ProfileState.loadingUpdate());

    try {
      final result = await remoteDataSource.updateMyProfile(
        updateProfileRequestModel: updateProfileRequestModel,
      );
      result.fold(
        success: (PublicResponseModel updatedPatient) {
          if (updatedPatient.msg == "Unauthorized. Please login first.") {
            context.pushReplacementNamed(AppRouter.welcomeScreen.name);
          } else {
            fetchMyProfile(context: context);

            Navigator.of(context).pop();
          }
          emit(ProfileState.success(null));
        },
        error: (String? message, int? code, PublicResponseModel? data) {
          emit(ProfileState.error(message ?? 'Failed to update profile'));
        },
      );
    } catch (e) {
      emit(ProfileState.error('Unexpected error: ${e.toString()}'));
    }
  }
}
