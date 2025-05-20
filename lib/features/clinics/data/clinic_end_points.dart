class ClinicEndPoints {
  static String getAllClinics = "/clinics";

  static String getSpecificClinics({required String id}) => "/clinics/$id";

}
