class EncounterEndPoints {
  static String getAllMyEncounter = "/patient/my-encounters";

  static String getSpecificEncounter({required String encounterId}) => "/patient/encounter/$encounterId";

  static String getAllMyEncounterOfAppointment({required String appointmentId}) => "/patient/appointments/$appointmentId/encounter";
}
