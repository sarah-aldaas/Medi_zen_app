class NotificationEndPoints {
  static String storeFCMToken() => "/patient/device-tokens";

  static String deleteFCMToken() => "/patient/device-tokens/delete-fcm";

  static String getMyNotification() => "/patient/notifications";

  static String makeNotificationAsRead({required String notificationId}) => "/patient/notifications/$notificationId/read";

  static String deleteNotification({required String notificationId}) => "/patient/notifications/$notificationId";
}
