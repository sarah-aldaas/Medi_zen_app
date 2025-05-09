part of 'telecom_cubit.dart';

abstract class TelecomState {}

class TelecomInitial extends TelecomState {}

class TelecomLoading extends TelecomState {}

class TelecomSuccess extends TelecomState {
  final List<TelecomModel> telecoms;

  TelecomSuccess({this.telecoms = const []});
}

class TelecomError extends TelecomState {
  final String error;

  TelecomError({required this.error});
}