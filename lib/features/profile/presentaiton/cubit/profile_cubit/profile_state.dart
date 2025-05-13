part of 'profile_cubit.dart';
enum ProfileStatus { initial, loading, success, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final PatientModel? patient;
  final String errorMessage;

  const ProfileState({
    required this.status,
    this.patient,
    this.errorMessage = '',
  });

  factory ProfileState.initial() {
    return const ProfileState(status: ProfileStatus.initial);
  }

  factory ProfileState.loading() {
    return const ProfileState(status: ProfileStatus.loading);
  }

  factory ProfileState.success(PatientModel? patient) {
    return ProfileState(status: ProfileStatus.success, patient: patient);
  }

  factory ProfileState.error(String errorMessage) {
    return ProfileState(status: ProfileStatus.error, errorMessage: errorMessage);
  }

  @override
  List<Object?> get props => [status, patient, errorMessage];
}