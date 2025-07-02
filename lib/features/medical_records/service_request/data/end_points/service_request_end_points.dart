class ServiceRequestEndPoints {
  static String getAllServiceRequest() => "/patient/my-service-requests";

  static String getAllServiceRequestForAppointment({required String appointmentId}) => "/patient/appointments/$appointmentId/my-service-requests";

  static String getDetailsService({required String serviceId}) => "/patient/my-service-requests/$serviceId";
}
