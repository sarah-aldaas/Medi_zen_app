class DiagnosticReportEndPoints {
  static String getDetailsDiagnosticReport({
    required String diagnosticReportId,
  }) => "/patient/diagnostic-reports/$diagnosticReportId";

  static String getAllDiagnosticReport() => "/patient/my-diagnostic-reports";

  static String getAllDiagnosticReportOfAppointment({
    required String appointmentId,
  }) => "/patient/appointments/$appointmentId/diagnostic-reports";

  static String getAllDiagnosticReportOfCondition({
    required String conditionId,
  }) => "/patient/conditions/$conditionId/diagnostic-report";
}
