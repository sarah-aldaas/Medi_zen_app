import '../../data/models/telecom_model.dart';

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
