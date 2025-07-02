import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String _tokenKey = 'fcm_token';

  Future<void> init() async {
    await _initNotifications();
    await _requestPermissions();
    await _setupTokenHandling();
    await _setupMessageHandling();
  }

  Future<void> _initNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

      // Initialize with platform-specific implementation
      await plugin.initialize(
        const InitializationSettings(
          android: initializationSettingsAndroid,
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification taps
        },
      );

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel',
        'Default Channel',
        importance: Importance.max,
      );

      await plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    } catch (e) {
      print('Notification initialization error: $e');
    }
  }
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permissions granted');
    }
  }

  Future<void> _setupTokenHandling() async {
    // Get existing token or generate new one
    String? token = await _messaging.getToken();
    await _handleNewToken(token);

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen(_handleNewToken);
  }

  Future<void> _handleNewToken(String? token) async {
    if (token == null) return;

    print('FCM Token: $token');

    // Store locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Send to server
    await _sendTokenToServer(token);
  }

  Future<void> _sendTokenToServer(String token) async {
    // Implement your server communication here
    print('Sending token to server: $token');
    // await http.post(Uri.parse('your-api-endpoint'), body: {'token': token});
  }

  Future<void> _setupMessageHandling() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 App in foreground - message received');
      showNotification(message);
    });

    // Background messages (when app is minimized)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔄 App resumed from background - message opened');
      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    // Print full message details
    print('''
  📨 New FCM Message Received:
  Message ID: ${message.messageId}
  Sent Time: ${message.sentTime?.toIso8601String()}
  From: ${message.from}
  Collapse Key: ${message.collapseKey}
  Message Type: ${message.messageType}
  ''');

    // Print notification payload
    if (message.notification != null) {
      final notification = message.notification!;
      print('''
    📢 Notification Details:
    Title: ${notification.title}
    Body: ${notification.body}
    Android Channel: ${notification.android?.channelId}
    ''');
    }

    // Print data payload
    if (message.data.isNotEmpty) {
      print('    📊 Data Payload:');
      message.data.forEach((key, value) {
        print('      $key: $value');
      });
    }

    // Show notification if it exists
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        importance: Importance.max,
        priority: Priority.high,
      );

      await _notificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: androidPlatformChannelSpecifics,
        ),
      );
    }
  }
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}