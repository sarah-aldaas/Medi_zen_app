part of 'complain_cubit.dart';

sealed class ComplainState {
  const ComplainState();
}

final class ComplainInitial extends ComplainState {}

class ComplainLoading extends ComplainState {
  final bool isLoadMore;

  const ComplainLoading({this.isLoadMore = false});
}

class ComplainSuccess extends ComplainState {
  final bool hasMore;
  final PaginatedResponse<ComplainModel> paginatedResponse;

  const ComplainSuccess({required this.paginatedResponse, required this.hasMore});
}

class ComplainDetailsSuccess extends ComplainState {
  final ComplainModel complain;

  const ComplainDetailsSuccess({required this.complain});
}

class ComplainResponsesSuccess extends ComplainState {
  final List<ComplainResponseModel> responses;

  const ComplainResponsesSuccess({required this.responses});
}

class ComplainActionSuccess extends ComplainState {
  final String message;
  final bool isCloseAction;

  const ComplainActionSuccess({required this.message, this.isCloseAction = false});
}

class ComplainError extends ComplainState {
  final String error;

  const ComplainError({required this.error});
}
