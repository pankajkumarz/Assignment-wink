import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final int age;
  final String city;
  final String role;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.age,
    required this.city,
    required this.role,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        age,
        city,
        role,
        preferences,
        createdAt,
        updatedAt,
      ];

  User copyWith({
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
    return User(
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

  // Validation methods
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool get isValidAge {
    return age >= 13 && age <= 120;
  }

  bool get isMinor {
    return age < 18;
  }

  bool get isValidName {
    return name.trim().length >= 2 && name.trim().length <= 50;
  }

  bool get isValidPhone {
    if (phone == null) return true; // Phone is optional
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
    return phoneRegex.hasMatch(phone!);
  }

  bool get isValidCity {
    return city.trim().length >= 2 && city.trim().length <= 50;
  }

  bool get isCitizen => role == 'citizen';
  bool get isAuthority => role == 'authority';
  bool get isAdmin => role == 'admin';

  // Complete validation
  bool get isValid {
    return isValidEmail &&
        isValidAge &&
        isValidName &&
        isValidPhone &&
        isValidCity;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'city': city,
      'role': role,
      'isActive': isActive,
      'preferences': preferences.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      age: json['age'] ?? 0,
      city: json['city'] ?? '',
      role: json['role'] ?? 'citizen',
      isActive: json['isActive'] ?? true,
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class UserPreferences extends Equatable {
  final String language;
  final String theme;
  final NotificationSettings notifications;
  final bool whatsappEnabled;

  const UserPreferences({
    required this.language,
    required this.theme,
    required this.notifications,
    required this.whatsappEnabled,
  });

  @override
  List<Object> get props => [language, theme, notifications, whatsappEnabled];

  UserPreferences copyWith({
    String? language,
    String? theme,
    NotificationSettings? notifications,
    bool? whatsappEnabled,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'notifications': notifications.toJson(),
      'whatsappEnabled': whatsappEnabled,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'system',
      notifications: NotificationSettings.fromJson(json['notifications'] ?? {}),
      whatsappEnabled: json['whatsappEnabled'] ?? false,
    );
  }
}

class NotificationSettings extends Equatable {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool whatsappEnabled;
  final bool statusUpdates;
  final bool alerts;

  const NotificationSettings({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.whatsappEnabled,
    required this.statusUpdates,
    required this.alerts,
  });

  @override
  List<Object> get props => [
        pushEnabled,
        emailEnabled,
        whatsappEnabled,
        statusUpdates,
        alerts,
      ];

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? whatsappEnabled,
    bool? statusUpdates,
    bool? alerts,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      statusUpdates: statusUpdates ?? this.statusUpdates,
      alerts: alerts ?? this.alerts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'whatsappEnabled': whatsappEnabled,
      'statusUpdates': statusUpdates,
      'alerts': alerts,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      whatsappEnabled: json['whatsappEnabled'] ?? false,
      statusUpdates: json['statusUpdates'] ?? true,
      alerts: json['alerts'] ?? true,
    );
  }
}