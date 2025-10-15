import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      // Request permission for notifications
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('Notification permission status: ${settings.authorizationStatus}');
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      if (kDebugMode) {
        print('Notification service initialized successfully');
      }
    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) {
        print('Notification service initialization error: $e');
      }
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );
  }

  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic $topic: $e');
      }
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic $topic: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.notification?.title}');
    }

    // Show local notification when app is in foreground
    _showLocalNotification(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.data}');
    }

    // Handle navigation based on notification data
    _handleNotificationNavigation(message.data);
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print('Local notification tapped: ${response.payload}');
    }

    // Handle navigation based on payload
    if (response.payload != null) {
      // Parse payload and navigate accordingly
      // This would typically involve using a navigation service
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'local_pulse_channel',
      'Local Pulse Notifications',
      channelDescription: 'Notifications for Local Pulse app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Local Pulse',
      message.notification?.body ?? 'You have a new update',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Handle different types of notifications
    final type = data['type'] as String?;
    final issueId = data['issueId'] as String?;

    switch (type) {
      case 'issue_status_update':
        if (issueId != null) {
          // Navigate to issue detail page
          // This would typically use a navigation service
          if (kDebugMode) {
            print('Navigate to issue: $issueId');
          }
        }
        break;
      case 'new_alert':
        // Navigate to alerts page
        if (kDebugMode) {
          print('Navigate to alerts');
        }
        break;
      default:
        // Navigate to home
        if (kDebugMode) {
          print('Navigate to home');
        }
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'local_pulse_channel',
      'Local Pulse Notifications',
      channelDescription: 'Notifications for Local Pulse app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showTestNotification() async {
    await showNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Local Pulse',
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}