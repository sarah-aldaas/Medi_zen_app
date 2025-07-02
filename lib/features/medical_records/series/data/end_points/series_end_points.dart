class SeriesEndPoints {
  static String getDetailsSeries({required String serviceId, required String imagingStudyId, required String seriesId}) =>
      "/patient/my-service-requests/$serviceId/imaging-studies/$imagingStudyId/series/$seriesId";

  static String getAllSeries({required String serviceId, required String imagingStudyId}) =>
      "/patient/my-service-requests/$serviceId/imaging-studies/$imagingStudyId/series";
}
