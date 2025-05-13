part of 'address_cubit.dart';

@immutable
sealed class AddressState {}

final class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressSuccess extends AddressState {
  final PaginatedResponse<AddressModel> paginatedResponse;

  AddressSuccess({
    required this.paginatedResponse,
  });
}
class AddressError extends AddressState {
  final String error;

  AddressError({required this.error});
}