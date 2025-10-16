import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool issueUpdates;
  final bool communityAlerts;
  final bool maintenanceNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationSettings({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.issueUpdates = true,
    this.communityAlerts = true,
    this.maintenanceNotifications = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'issueUpdates': issueUpdates,
      'communityAlerts': communityAlerts,
      'maintenanceNotifications': maintenanceNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['pushNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      issueUpdates: json['issueUpdates'] ?? true,
      communityAlerts: json['communityAlerts'] ?? true,
      maintenanceNotifications: json['maintenanceNotifications'] ?? false,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? issueUpdates,
    bool? communityAlerts,
    bool? maintenanceNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      issueUpdates: issueUpdates ?? this.issueUpdates,
      communityAlerts: communityAlerts ?? this.communityAlerts,
      maintenanceNotifications: maintenanceNotifications ?? this.maintenanceNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

class NotificationPreferencesService {
  static const String _preferencesKey = 'notification_preferences';

  /// Load notification settings from local storage
  static Future<NotificationSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_preferencesKey);
      
      if (settingsJson != null) {
        final settingsData = jsonDecode(settingsJson);
        return NotificationSettings.fromJson(settingsData);
      }
      
      // Return default settings if none exist
      return const NotificationSettings();
    } catch (e) {
      print('Error loading notification settings: $e');
      return const NotificationSettings();
    }
  }

  /// Save notification settings to local storage
  static Future<bool> saveSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      await prefs.setString(_preferencesKey, settingsJson);
      return true;
    } catch (e) {
      print('Error saving notification settings: $e');
      return false;
    }
  }

  /// Toggle a specific notification setting
  static Future<bool> toggleSetting(String settingKey, bool value) async {
    try {
      final currentSettings = await loadSettings();
      
      NotificationSettings updatedSettings;
      switch (settingKey) {
        case 'pushNotifications':
          updatedSettings = currentSettings.copyWith(pushNotifications: value);
          break;
        case 'emailNotifications':
          updatedSettings = currentSettings.copyWith(emailNotifications: value);
          break;
        case 'issueUpdates':
          updatedSettings = currentSettings.copyWith(issueUpdates: value);
          break;
        case 'communityAlerts':
          updatedSettings = currentSettings.copyWith(communityAlerts: value);
          break;
        case 'maintenanceNotifications':
          updatedSettings = currentSettings.copyWith(maintenanceNotifications: value);
          break;
        case 'soundEnabled':
          updatedSettings = currentSettings.copyWith(soundEnabled: value);
          break;
        case 'vibrationEnabled':
          updatedSettings = currentSettings.copyWith(vibrationEnabled: value);
          break;
        default:
          return false;
      }
      
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('Error toggling setting $settingKey: $e');
      return false;
    }
  }

  /// Clear all notification preferences
  static Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_preferencesKey);
    } catch (e) {
      print('Error clearing notification settings: $e');
    }
  }

  /// Get a specific setting value
  static Future<bool> getSetting(String settingKey) async {
    try {
      final settings = await loadSettings();
      switch (settingKey) {
        case 'pushNotifications':
          return settings.pushNotifications;
        case 'emailNotifications':
          return settings.emailNotifications;
        case 'issueUpdates':
          return settings.issueUpdates;
        case 'communityAlerts':
          return settings.communityAlerts;
        case 'maintenanceNotifications':
          return settings.maintenanceNotifications;
        case 'soundEnabled':
          return settings.soundEnabled;
        case 'vibrationEnabled':
          return settings.vibrationEnabled;
        default:
          return false;
      }
    } catch (e) {
      print('Error getting setting $settingKey: $e');
      return false;
    }
  }
}