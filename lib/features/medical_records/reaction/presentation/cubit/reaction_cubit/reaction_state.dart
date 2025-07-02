part of 'reaction_cubit.dart';

@immutable
sealed class ReactionState {}

final class ReactionInitial extends ReactionState {}

class ReactionLoading extends ReactionState {
  final bool isLoadMore;

  ReactionLoading({this.isLoadMore = false});
}

class ReactionsOfAppointmentSuccess extends ReactionState {
  final bool hasMore;
  final PaginatedResponse<ReactionModel> paginatedResponse;

  ReactionsOfAppointmentSuccess({required this.paginatedResponse, required this.hasMore});
}

class ReactionDetailsSuccess extends ReactionState {
  final ReactionModel reactionModel;

  ReactionDetailsSuccess({required this.reactionModel});
}

class ReactionError extends ReactionState {
  final String error;

  ReactionError({required this.error});
}
