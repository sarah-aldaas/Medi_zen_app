import '../../clinic_model.dart';

abstract class ClinicsState {}

class ClinicsInitial extends ClinicsState {}

class ClinicsLoading extends ClinicsState {}

class ClinicsLoaded extends ClinicsState {
  final List<Clinic> clinics;

  ClinicsLoaded({required this.clinics});
}

class ClinicsError extends ClinicsState {
  final String? message;

  ClinicsError({this.message});
}
