class DiagnosticReportEndPoints {
  static String getDetailsDiagnosticReport({
    required String diagnosticReportId,
  }) => "/patient/diagnostic-reports/$diagnosticReportId";

  static String getAllDiagnosticReport() => "/patient/my-diagnostic-reports";

  static String getAllDiagnosticReportOfAppointment({
    required String appointmentId,
    required String conditionId,
  }) => "/patient/appointments/$appointmentId/conditions/$conditionId/diagnostic-reports";

  static String getAllDiagnosticReportOfCondition({
    required String conditionId,
  }) => "/patient/conditions/$conditionId/my-diagnostic-reports";
}
