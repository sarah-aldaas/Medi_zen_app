part of 'conditions_cubit.dart';


sealed class ConditionsState {
  const ConditionsState();
}

final class ConditionsInitial extends ConditionsState {}

class ConditionsLoading extends ConditionsState {
  final bool isLoadMore;

  const ConditionsLoading({this.isLoadMore = false});
}

class ConditionsSuccess extends ConditionsState {
  final bool hasMore;
  final PaginatedResponse<ConditionsModel> paginatedResponse;

  const ConditionsSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });
}

class ConditionDetailsSuccess extends ConditionsState {
  final ConditionsModel condition;

  const ConditionDetailsSuccess({
    required this.condition,
  });
}

class ConditionsError extends ConditionsState {
  final String error;

  const ConditionsError({required this.error});
}