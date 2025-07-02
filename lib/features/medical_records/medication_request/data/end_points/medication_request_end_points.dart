class MedicationRequestEndPoints {
  static String getAllMedicationRequest() => "/patient/my-medication-requests";

  static String getAllMedicationRequestForAppointment({required String appointmentId}) => "/patient/appointments/$appointmentId/medication-requests";

  static String getAllMedicationRequestForCondition({required String conditionId}) => "/patient/conditions/$conditionId/medication-requests";

  static String getDetailsMedicationRequest({required String medicationRequestId}) => "/patient/medication-requests/$medicationRequestId";
}
