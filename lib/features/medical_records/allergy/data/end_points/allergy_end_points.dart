class AllergyEndPoints {
  static String getAllMyAllergies = "/patient/my-allergies";

  static String getSpecificAllergy({required String allergyId}) => "/patient/allergies/$allergyId";

  static String getAllMyAllergiesOfAppointment({required String appointmentId}) => "/patient/appointments/$appointmentId/allergies";
}
