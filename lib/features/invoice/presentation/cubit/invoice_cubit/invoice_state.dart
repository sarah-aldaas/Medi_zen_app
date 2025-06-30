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
  final List<AppointmentModel> paidAppointments;
  final List<AppointmentModel> unpaidAppointments;
  final bool hasMorePaid;
  final bool hasMoreUnpaid;

  const InvoiceAppointmentsSuccess({
    required this.paidAppointments,
    required this.unpaidAppointments,
    required this.hasMorePaid,
    required this.hasMoreUnpaid,
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