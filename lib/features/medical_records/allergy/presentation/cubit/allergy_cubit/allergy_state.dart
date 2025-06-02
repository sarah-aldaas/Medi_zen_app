part of 'allergy_cubit.dart';

@immutable
sealed class AllergyState {}

final class AllergyInitial extends AllergyState {}

class AllergyLoading extends AllergyState {
  final bool isLoadMore;

  AllergyLoading({this.isLoadMore = false});
}

class AllergiesSuccess extends AllergyState {
  final bool hasMore;
  final PaginatedResponse<AllergyModel> paginatedResponse;

  AllergiesSuccess({required this.paginatedResponse, required this.hasMore});
}

class AllergiesOfAppointmentSuccess extends AllergyState {
  final bool hasMore;
  final PaginatedResponse<AllergyModel> paginatedResponse;

  AllergiesOfAppointmentSuccess({required this.paginatedResponse, required this.hasMore});
}

class AllergyDetailsSuccess extends AllergyState {
  final AllergyModel allergyModel;

  AllergyDetailsSuccess({required this.allergyModel});
}

class AllergyError extends AllergyState {
  final String error;

  AllergyError({required this.error});
}
