import 'package:bloc/bloc.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/profile/data/data_sources/profile_remote_data_sources.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/profile_state.dart';

import '../../../../base/constant/storage_key.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/services/storage/storage_service.dart';



class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.remoteDataSource}) : super(ProfileState.initial());

  final ProfileRemoteDataSource remoteDataSource;

  Future<void> fetchMyProfile() async {
    emit(ProfileState.loading());
    try {
      final result = await remoteDataSource.getMyProfile();
      result.fold(
        success: (PatientModel patient) {
          serviceLocator<StorageService>().savePatient(
            StorageKey.patientModel,patient,
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

  Future<void> updateMyProfile({required PatientModel patientModel}) async {
    emit(ProfileState.loading());
    try {
      final result = await remoteDataSource.updateMyProfile(patientModel: patientModel);
      result.fold(
        success: (PatientModel updatedPatient) {
          emit(ProfileState.success(updatedPatient));
        },
        error: (String? message, int? code, PatientModel? data) {
          emit(ProfileState.error(message ?? 'Failed to update profile'));
        },
      );
    } catch (e) {
      emit(ProfileState.error('Unexpected error: ${e.toString()}'));
    }
  }
}