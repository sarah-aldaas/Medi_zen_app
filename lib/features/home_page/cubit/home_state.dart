
part of "home_cubit.dart";
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ClinicModel> clinics;
  final int currentImage;

  HomeLoaded(this.clinics, this.currentImage);
}

class HomeError extends HomeState {
  final String errorMessage;

  HomeError(this.errorMessage);
}