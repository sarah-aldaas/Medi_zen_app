part of 'appointment_cubit.dart';

@immutable
sealed class AppointmentState {}

final class AppointmentInitial extends AppointmentState {}
class AppointmentLoading extends AppointmentState {}

class AppointmentSuccess extends AppointmentState {
  final PaginatedResponse<AppointmentModel> paginatedResponse;

  AppointmentSuccess({
    required this.paginatedResponse,
  });
}


class SlotsAppointmentSuccess extends AppointmentState {
  final List<SlotModel> listSlots;

  SlotsAppointmentSuccess({
    required this.listSlots,
  });
}

class AppointmentError extends AppointmentState {
  final String error;

  AppointmentError({required this.error});
}