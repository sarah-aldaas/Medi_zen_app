part of 'clinic_cubit.dart';

@immutable
sealed class ClinicState {}

final class ClinicInitial extends ClinicState {}

class ClinicLoading extends ClinicState {}

class ClinicSuccess extends ClinicState {
  final PaginatedResponse<ClinicModel> paginatedResponse;
  ClinicSuccess({
    required this.paginatedResponse,
  });
}

class DoctorsOfClinicSuccess extends ClinicState {
  final PaginatedResponse<DoctorModel> paginatedResponse;
  DoctorsOfClinicSuccess({
    required this.paginatedResponse,
  });
}

class ClinicError extends ClinicState {
  final String error;

  ClinicError({required this.error});
}