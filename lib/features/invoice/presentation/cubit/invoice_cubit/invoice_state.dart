part of 'invoice_cubit.dart';

@immutable
sealed class InvoiceState {
  const InvoiceState();
}

final class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {
  final bool isLoadMore;

  const InvoiceLoading({this.isLoadMore = false});
}

class InvoiceAppointmentsSuccess extends InvoiceState {
  final bool hasMore;
  final PaginatedResponse<AppointmentModel> paginatedResponse;

  const InvoiceAppointmentsSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });
}

class InvoiceDetailsSuccess extends InvoiceState {
  final InvoiceModel invoice;

  const InvoiceDetailsSuccess({
    required this.invoice,
  });
}

class InvoiceError extends InvoiceState {
  final String error;

  const InvoiceError({required this.error});
}