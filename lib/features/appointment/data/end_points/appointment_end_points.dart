class AppointmentEndPoints {
  static String getSlots({required String practitionerId, required String date}) => "/patient/slots/generate?practitioner_id=$practitionerId&date=$date";
  static String getDaysWorkDoctor({required String doctorId}) => "/patient/get-days/$doctorId";

  static String getMyAppointment() => "/patient/my-appointments-patient";

  static String getDetailsAppointment({required String id}) => "/patient/appointments/$id";

  static String createAppointment() => "/patient/appointments";

  static String updateAppointment({required String id}) => "/patient/appointments/$id/update";

  static String cancelAppointment({required String id}) => "/patient/appointments/$id/cancel";
}
