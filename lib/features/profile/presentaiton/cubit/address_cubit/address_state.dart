part of 'address_cubit.dart';

@immutable
sealed class AddressState {}

final class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {
  final bool isFirstFetch;
  final bool isLoadingMore;

  AddressLoading({this.isFirstFetch = false, this.isLoadingMore = false});
}

class AddressSuccess extends AddressState {
  final PaginatedResponse<AddressModel> paginatedResponse;
  final bool isLoadingMore;

  AddressSuccess({required this.paginatedResponse, this.isLoadingMore = false});
}

class AddressError extends AddressState {
  final String error;

  AddressError({required this.error});
}
