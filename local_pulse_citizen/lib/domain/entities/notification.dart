import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        data,
        isRead,
        createdAt,
        readAt,
      ];

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

// Notification types
class NotificationTypes {
  static const String issueStatusUpdate = 'issue_status_update';
  static const String issueAssigned = 'issue_assigned';
  static const String issueResolved = 'issue_resolved';
  static const String newAlert = 'new_alert';
  static const String feedbackRequest = 'feedback_request';
  static const String escalation = 'escalation';
  static const String general = 'general';
}