import 'package:equatable/equatable.dart';
import 'geo_location.dart';

class Alert extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type;
  final String priority;
  final GeoLocation location;
  final String city;
  final double radiusKm;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? category;
  final List<String>? tags;
  final String? actionUrl;
  final String? imageUrl;
  final String createdBy;
  final int? estimatedAffectedPeople;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.location,
    required this.city,
    required this.radiusKm,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
    this.category,
    this.tags,
    this.actionUrl,
    this.imageUrl,
    required this.createdBy,
    this.estimatedAffectedPeople,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        priority,
        location,
        city,
        radiusKm,
        isActive,
        createdAt,
        expiresAt,
        category,
        tags,
        actionUrl,
        imageUrl,
        createdBy,
        estimatedAffectedPeople,
      ];

  Alert copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? priority,
    GeoLocation? location,
    String? city,
    double? radiusKm,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? category,
    List<String>? tags,
    String? actionUrl,
    String? imageUrl,
    String? createdBy,
    int? estimatedAffectedPeople,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      city: city ?? this.city,
      radiusKm: radiusKm ?? this.radiusKm,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      estimatedAffectedPeople: estimatedAffectedPeople ?? this.estimatedAffectedPeople,
    );
  }

  // Helper methods
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isEmergency => priority == 'emergency' || priority == 'critical';
  
  bool get isHighPriority => priority == 'high' || isEmergency;

  Duration get timeRemaining {
    if (expiresAt == null) return Duration.zero;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  String get priorityDisplayName {
    switch (priority.toLowerCase()) {
      case 'emergency':
        return 'EMERGENCY';
      case 'critical':
        return 'CRITICAL';
      case 'high':
        return 'HIGH';
      case 'medium':
        return 'MEDIUM';
      case 'low':
        return 'LOW';
      default:
        return priority.toUpperCase();
    }
  }

  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'weather':
        return 'Weather Alert';
      case 'traffic':
        return 'Traffic Alert';
      case 'emergency':
        return 'Emergency Alert';
      case 'maintenance':
        return 'Maintenance Notice';
      case 'event':
        return 'Event Notification';
      case 'safety':
        return 'Safety Alert';
      default:
        return 'General Alert';
    }
  }
}