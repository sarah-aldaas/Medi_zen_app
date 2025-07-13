class MedicationRequestEndPoints {
  static String getAllMedicationRequest() => "/patient/my-medication-requests";

  static String getAllMedicationRequestForAppointment({required String appointmentId,required String conditionId}) => "/patient/appointments/$appointmentId/conditions/$conditionId/medication-requests";

  static String getAllMedicationRequestForCondition({required String conditionId}) => "/patient/conditions/$conditionId/my-medication-requests";

  static String getDetailsMedicationRequest({required String medicationRequestId}) => "/patient/medication-requests/$medicationRequestId";
}
