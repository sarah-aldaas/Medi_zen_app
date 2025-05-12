class ClinicEndPoints {
  static String getAllClinics = "/clinics";

  static String getSpecificClinics({required String id}) => "/clinics/$id";

  static String getDoctorsOfClinic({required String clinicId}) => "/patient/clinics/$clinicId/doctors";
}
