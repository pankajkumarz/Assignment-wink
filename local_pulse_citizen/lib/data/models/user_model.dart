import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/typedef.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    required super.age,
    required super.city,
    required super.role,
    required super.preferences,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromMap(DataMap map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      age: map['age'] ?? 0,
      city: map['city'] ?? '',
      role: map['role'] ?? 'citizen',
      preferences: UserPreferencesModel.fromMap(
        map['preferences'] ?? <String, dynamic>{},
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      age: user.age,
      city: user.city,
      role: user.role,
      preferences: user.preferences,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  DataMap toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'age': age,
      'city': city,
      'role': role,
      'preferences': UserPreferencesModel.fromEntity(preferences).toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    int? age,
    String? city,
    String? role,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      city: city ?? this.city,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    required super.language,
    required super.theme,
    required super.notifications,
    required super.whatsappEnabled,
  });

  factory UserPreferencesModel.fromMap(DataMap map) {
    return UserPreferencesModel(
      language: map['language'] ?? 'en',
      theme: map['theme'] ?? 'system',
      notifications: NotificationSettingsModel.fromMap(
        map['notifications'] ?? <String, dynamic>{},
      ),
      whatsappEnabled: map['whatsappEnabled'] ?? false,
    );
  }

  factory UserPreferencesModel.fromEntity(UserPreferences preferences) {
    return UserPreferencesModel(
      language: preferences.language,
      theme: preferences.theme,
      notifications: preferences.notifications,
      whatsappEnabled: preferences.whatsappEnabled,
    );
  }

  DataMap toMap() {
    return {
      'language': language,
      'theme': theme,
      'notifications': NotificationSettingsModel.fromEntity(notifications).toMap(),
      'whatsappEnabled': whatsappEnabled,
    };
  }
}

class NotificationSettingsModel extends NotificationSettings {
  const NotificationSettingsModel({
    required super.pushEnabled,
    required super.emailEnabled,
    required super.whatsappEnabled,
    required super.statusUpdates,
    required super.alerts,
  });

  factory NotificationSettingsModel.fromMap(DataMap map) {
    return NotificationSettingsModel(
      pushEnabled: map['pushEnabled'] ?? true,
      emailEnabled: map['emailEnabled'] ?? true,
      whatsappEnabled: map['whatsappEnabled'] ?? false,
      statusUpdates: map['statusUpdates'] ?? true,
      alerts: map['alerts'] ?? true,
    );
  }

  factory NotificationSettingsModel.fromEntity(NotificationSettings settings) {
    return NotificationSettingsModel(
      pushEnabled: settings.pushEnabled,
      emailEnabled: settings.emailEnabled,
      whatsappEnabled: settings.whatsappEnabled,
      statusUpdates: settings.statusUpdates,
      alerts: settings.alerts,
    );
  }

  DataMap toMap() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'whatsappEnabled': whatsappEnabled,
      'statusUpdates': statusUpdates,
      'alerts': alerts,
    };
  }
}