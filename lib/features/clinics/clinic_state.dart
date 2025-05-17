import '../home_page/cubit/clinic.dart';

abstract class ClinicsState {}

class ClinicsInitial extends ClinicsState {}

class ClinicsLoading extends ClinicsState {}

class ClinicsLoaded extends ClinicsState {
  final List<Clinic> clinics;

  ClinicsLoaded({required this.clinics});
}

class ClinicsError extends ClinicsState {
  final String error;

  ClinicsError({required this.error});
}
