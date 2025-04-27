import 'doctor.dart';

abstract class DoctorState {}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<Doctor> doctors;

  DoctorLoaded(this.doctors);
}

class DoctorError extends DoctorState {
  final String errorMessage;

  DoctorError(this.errorMessage);
}
