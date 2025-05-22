class ReactionEndPoints {
  static String getSpecificReaction({required String allergyId, required String reactionId}) => "/patient/allergies/$allergyId/reactions/$reactionId";

  static String getAllReactionOfAppointment({required String appointmentId, required String allergyId}) =>
      "/patient/appointments/$appointmentId/allergies/$allergyId/reactions";
}
