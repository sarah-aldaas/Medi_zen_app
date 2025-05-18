part of 'appointment_cubit.dart';

@immutable
sealed class AppointmentState {
  const AppointmentState();
}

final class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {
  final bool isLoadMore;

  const AppointmentLoading({this.isLoadMore = false});
}

class CreateAppointmentSuccess extends AppointmentState {}

class SlotsAppointmentLoading extends AppointmentState {}

class DaysWorkDoctorLoading extends AppointmentState {}

class AppointmentSuccess extends AppointmentState {
  final bool hasMore;
  final PaginatedResponse<AppointmentModel> paginatedResponse;

  const AppointmentSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });
}

class AppointmentDetailsSuccess extends AppointmentState {
  final AppointmentModel appointmentModel;

  const AppointmentDetailsSuccess({
    required this.appointmentModel,
  });
}

class SlotsAppointmentSuccess extends AppointmentState {
  final List<SlotModel>? listSlots;

  const SlotsAppointmentSuccess({
    required this.listSlots,
  });
}

class DaysWorkDoctorSuccess extends AppointmentState {
  final DaysWorkDoctorModel days;

  const DaysWorkDoctorSuccess({
    required this.days,
  });
}

class AppointmentError extends AppointmentState {
  final String error;

  const AppointmentError({required this.error});
}
