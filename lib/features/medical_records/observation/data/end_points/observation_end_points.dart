class ObservationEndPoints {
  static String getDetailsObservation({required String serviceId,required String observationId}) => "/patient/my-service-requests/$serviceId/observations/$observationId";
}
