class MedicationEndPoints {
  static String getAllMedication() => "/patient/my-medications";

  static String getAllMedicationForAppointment({required String appointmentId,required String medicationRequestId,required String conditionId}) => "/patient/appointments/$appointmentId/conditions/$conditionId/medication-requests/$medicationRequestId/medications";

  static String getAllMedicationForMedicationRequest({required String medicationRequestId,required String conditionId}) => "/patient/conditions/$conditionId/medication-requests/$medicationRequestId/my-medications";

  static String getDetailsMedication({required String medicationId}) => "/patient/medications/$medicationId";
}
