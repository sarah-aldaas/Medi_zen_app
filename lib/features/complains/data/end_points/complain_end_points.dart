class ComplainEndPoints {
  static String getDetailsComplain({required String complainId}) => "/patient/complaints/$complainId";

  static String deleteComplain({required String complainId}) => "/patient/complaints/$complainId";

  static String createComplain({required String appointmentId}) => "/patient/appointments/$appointmentId/complaints";

  static String getAllComplain() => "/patient/my-complaints";

  static String getAllComplainOfAppointment({required String appointmentId}) => "/patient/appointments/$appointmentId/my-complaints";

  static String getResponseOfComplain({required String complainId}) => "/patient/complaints/$complainId/responses";

  static String responseOnComplain({required String complainId}) => "/patient/complaints/$complainId/responses";

  static String closeComplain({required String complainId}) => "/patient/complaints/$complainId/close";
}
