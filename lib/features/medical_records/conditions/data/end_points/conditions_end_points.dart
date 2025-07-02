class ConditionsEndPoints {
  static String getAllConditions() => "/patient/my-conditions";

  static String getAllConditionsForAppointment({required String appointmentId}) => "/patient/appointments/$appointmentId/conditions";

  static String getDetailsCondition({required String conditionId}) => "/patient/conditions/$conditionId";
}
