import 'package:equatable/equatable.dart';

enum AlertType {
  emergency,
  maintenance,
  weather,
  traffic,
  community,
  safety,
  water,
  electricity,
  other
}

enum AlertPriority {
  critical,
  high,
  medium,
  low
}

class CommunityAlert extends Equatable {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final AlertPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? location;
  final DateTime? expiresAt;

  const CommunityAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.location,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'location': location,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
    };
  }

  factory CommunityAlert.fromJson(Map<String, dynamic> json) {
    return CommunityAlert(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.other,
      ),
      priority: AlertPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AlertPriority.medium,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
      location: json['location'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'])
          : null,
    );
  }

  CommunityAlert copyWith({
    String? id,
    String? title,
    String? description,
    AlertType? type,
    AlertPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? location,
    DateTime? expiresAt,
  }) {
    return CommunityAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isCritical => priority == AlertPriority.critical;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        priority,
        timestamp,
        isRead,
        imageUrl,
        location,
        expiresAt,
      ];
}