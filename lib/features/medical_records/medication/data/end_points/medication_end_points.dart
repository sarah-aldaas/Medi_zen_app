class MedicationEndPoints {
  static String getAllMedication() => "/patient/my-medications";

  static String getAllMedicationForAppointment({required String appointmentId}) => "/patient/appointments/$appointmentId/medications";

  static String getAllMedicationForMedicationRequest({required String medicationRequestId}) => "/patient/medication-requests/$medicationRequestId/medications";

  static String getDetailsMedication({required String medicationId}) => "/patient/medications/$medicationId";
}
