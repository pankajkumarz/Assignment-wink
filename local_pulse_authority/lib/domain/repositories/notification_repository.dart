import '../../core/utils/typedef.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  // Notification CRUD operations
  ResultFuture<String> createNotification({required AppNotification notification});

  ResultFuture<AppNotification> getNotificationById({required String notificationId});

  ResultVoid updateNotification({required AppNotification notification});

  ResultVoid deleteNotification({required String notificationId});

  // Notification queries
  ResultFuture<List<AppNotification>> getNotificationsByUser({
    required String userId,
    int? limit,
    String? lastNotificationId,
  });

  ResultFuture<List<AppNotification>> getUnreadNotifications({
    required String userId,
  });

  ResultFuture<int> getUnreadNotificationCount({required String userId});

  // Real-time streams
  Stream<List<AppNotification>> watchNotificationsByUser({
    required String userId,
  });

  Stream<int> watchUnreadNotificationCount({required String userId});

  // Notification management
  ResultVoid markAsRead({required String notificationId});

  ResultVoid markAllAsRead({required String userId});

  ResultVoid deleteAllNotifications({required String userId});

  // Push notification management
  ResultVoid sendPushNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  });

  ResultVoid sendBulkPushNotifications({
    required List<String> userIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  });

  // FCM token management
  ResultVoid updateFCMToken({
    required String userId,
    required String token,
  });

  ResultVoid removeFCMToken({required String userId});

  // WhatsApp integration
  ResultVoid sendWhatsAppMessage({
    required String userId,
    required String message,
  });

  // Email notifications
  ResultVoid sendEmailNotification({
    required String userId,
    required String subject,
    required String message,
  });
}