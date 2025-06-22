class ImagingStudyEndPoints {
  static String getDetailsImagingStudy({required String serviceId, required String imagingStudyId}) =>
      "/patient/my-service-requests/$serviceId/imaging-studies/$imagingStudyId";
}
