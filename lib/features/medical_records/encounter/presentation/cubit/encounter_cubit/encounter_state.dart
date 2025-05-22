part of 'encounter_cubit.dart';

@immutable
sealed class EncounterState {}

final class EncounterInitial extends EncounterState {}

class EncounterLoading extends EncounterState {
  final bool isLoadMore;

  EncounterLoading({this.isLoadMore = false});
}

class EncountersSuccess extends EncounterState {
  final bool hasMore;
  final PaginatedResponse<EncounterModel> paginatedResponse;

  EncountersSuccess({required this.paginatedResponse, required this.hasMore});
}

class EncounterOfAppointmentSuccess extends EncounterState {
  final EncounterModel encounterModel;

  EncounterOfAppointmentSuccess({required this.encounterModel});
}

class EncounterDetailsSuccess extends EncounterState {
  final EncounterModel encounterModel;

  EncounterDetailsSuccess({required this.encounterModel});
}

class EncounterError extends EncounterState {
  final String error;

  EncounterError({required this.error});
}
