import 'package:bloc/bloc.dart';
import 'package:medizen_app/features/doctor/data/model/doctor_model.dart';
import 'package:meta/meta.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/datasources/clinic_remote_datasources.dart';
import '../../../data/models/clinic_model.dart';

part 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  final ClinicRemoteDataSource remoteDataSource;

  ClinicCubit({required this.remoteDataSource}) : super(ClinicInitial());

  Future<void> fetchClinics() async {
    emit(ClinicLoading());
    final result = await remoteDataSource.getAllClinics();
    if (result is Success<PaginatedResponse<ClinicModel>>) {
      emit(ClinicSuccess(paginatedResponse: result.data));
    } else if (result is ResponseError<PaginatedResponse<ClinicModel>>) {
      emit(ClinicError(error: result.message ?? 'Failed to fetch Clinics'));
    }
  }

  Future<ClinicModel?> getSpecificClinic({required String id}) async {
    emit(ClinicLoading());
    final result = await remoteDataSource.getSpecificClinic(id: id);
    if (result is Success<ClinicModel>) {
      return result.data;
    } else if (result is ResponseError<ClinicModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch clinic details');
      emit(ClinicError(error: result.message ?? 'Failed to fetch clinic details'));
      return null;
    }
    return null;
  }

  Future<void> getDoctorsOfClinic({required String clinicId}) async {
    emit(ClinicLoading());
    final result = await remoteDataSource.getDoctorsOfClinic(clinicId: clinicId);
    if (result is Success<PaginatedResponse<DoctorModel>>) {
      emit(DoctorsOfClinicSuccess(paginatedResponse: result.data));
    } else if (result is ResponseError<PaginatedResponse<DoctorModel>>) {
      emit(ClinicError(error: result.message ?? 'Failed to fetch doctors of clinic'));
    }
  }
}
