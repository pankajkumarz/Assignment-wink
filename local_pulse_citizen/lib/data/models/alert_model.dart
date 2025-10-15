import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/alert.dart';
import '../../domain/entities/geo_location.dart';

class AlertModel extends Alert {
  const AlertModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.priority,
    required super.location,
    required super.city,
    required super.radiusKm,
    required super.isActive,
    required super.createdAt,
    super.expiresAt,
    super.category,
    super.tags,
    super.actionUrl,
    super.imageUrl,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AlertModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      priority: data['priority'] ?? 'medium',
      location: GeoLocation(
        latitude: (data['location']['latitude'] ?? 0.0).toDouble(),
        longitude: (data['location']['longitude'] ?? 0.0).toDouble(),
        address: data['location']['address'] ?? '',
      ),
      city: data['city'] ?? '',
      radiusKm: (data['radiusKm'] ?? 5.0).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      category: data['category'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      actionUrl: data['actionUrl'],
      imageUrl: data['imageUrl'],
    );
  }

  factory AlertModel.fromEntity(Alert alert) {
    return AlertModel(
      id: alert.id,
      title: alert.title,
      message: alert.message,
      type: alert.type,
      priority: alert.priority,
      location: alert.location,
      city: alert.city,
      radiusKm: alert.radiusKm,
      isActive: alert.isActive,
      createdAt: alert.createdAt,
      expiresAt: alert.expiresAt,
      category: alert.category,
      tags: alert.tags,
      actionUrl: alert.actionUrl,
      imageUrl: alert.imageUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': location.address,
      },
      'city': city,
      'radiusKm': radiusKm,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'category': category,
      'tags': tags,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
    };
  }

  AlertModel copyWith({
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
  }) {
    return AlertModel(
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
    );
  }

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
      ];
}