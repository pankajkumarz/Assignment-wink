import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';

class AlertService {
  static const String _alertsKey = 'community_alerts';
  static const String _readAlertsKey = 'read_alerts';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get stream of community alerts
  static Stream<List<CommunityAlert>> getAlertsStream() {
    // For now, return a stream from local data
    // In production, this would be a Firestore stream
    return Stream.periodic(const Duration(seconds: 30), (count) {
      return _getCachedAlerts();
    }).asyncMap((future) => future);
  }

  /// Load alerts from cache and generate sample data if empty
  static Future<List<CommunityAlert>> loadAlerts() async {
    try {
      final cachedAlerts = await _getCachedAlerts();
      if (cachedAlerts.isNotEmpty) {
        return cachedAlerts;
      }

      // Generate sample alerts if none exist
      final sampleAlerts = await _generateSampleAlerts();
      await _cacheAlerts(sampleAlerts);
      return sampleAlerts;
    } catch (e) {
      print('Error loading alerts: $e');
      return [];
    }
  }

  /// Mark alert as read
  static Future<bool> markAlertAsRead(String alertId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readAlerts = prefs.getStringList(_readAlertsKey) ?? [];
      
      if (!readAlerts.contains(alertId)) {
        readAlerts.add(alertId);
        await prefs.setStringList(_readAlertsKey, readAlerts);
      }

      // Update the cached alerts
      final alerts = await _getCachedAlerts();
      final updatedAlerts = alerts.map((alert) {
        if (alert.id == alertId) {
          return alert.copyWith(isRead: true);
        }
        return alert;
      }).toList();

      await _cacheAlerts(updatedAlerts);
      return true;
    } catch (e) {
      print('Error marking alert as read: $e');
      return false;
    }
  }

  /// Get unread alerts count
  static Future<int> getUnreadCount() async {
    try {
      final alerts = await loadAlerts();
      return alerts.where((alert) => !alert.isRead && !alert.isExpired).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Subscribe to specific alert types
  static Future<void> subscribeToAlertTypes(List<AlertType> types) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeNames = types.map((type) => type.name).toList();
      await prefs.setStringList('subscribed_alert_types', typeNames);
    } catch (e) {
      print('Error subscribing to alert types: $e');
    }
  }

  /// Get subscribed alert types
  static Future<List<AlertType>> getSubscribedTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeNames = prefs.getStringList('subscribed_alert_types') ?? 
          AlertType.values.map((type) => type.name).toList();
      
      return typeNames.map((name) {
        return AlertType.values.firstWhere(
          (type) => type.name == name,
          orElse: () => AlertType.other,
        );
      }).toList();
    } catch (e) {
      print('Error getting subscribed types: $e');
      return AlertType.values;
    }
  }

  /// Clear all alerts
  static Future<void> clearAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_alertsKey);
      await prefs.remove(_readAlertsKey);
    } catch (e) {
      print('Error clearing alerts: $e');
    }
  }

  /// Get cached alerts from local storage
  static Future<List<CommunityAlert>> _getCachedAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getString(_alertsKey);
      final readAlerts = prefs.getStringList(_readAlertsKey) ?? [];

      if (alertsJson != null) {
        final List<dynamic> alertsList = jsonDecode(alertsJson);
        return alertsList.map((alertData) {
          final alert = CommunityAlert.fromJson(alertData);
          return alert.copyWith(isRead: readAlerts.contains(alert.id));
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error getting cached alerts: $e');
      return [];
    }
  }

  /// Cache alerts to local storage
  static Future<void> _cacheAlerts(List<CommunityAlert> alerts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = jsonEncode(alerts.map((alert) => alert.toJson()).toList());
      await prefs.setString(_alertsKey, alertsJson);
    } catch (e) {
      print('Error caching alerts: $e');
    }
  }

  /// Generate sample alerts for demonstration
  static Future<List<CommunityAlert>> _generateSampleAlerts() async {
    final random = Random();
    final now = DateTime.now();

    final sampleAlerts = [
      CommunityAlert(
        id: 'alert_1',
        title: 'Water Main Break - Downtown Area',
        description: 'A major water main break has occurred on Main Street between 1st and 3rd Avenue. Water service may be interrupted for 4-6 hours. Avoid the area if possible.',
        type: AlertType.water,
        priority: AlertPriority.high,
        timestamp: now.subtract(const Duration(hours: 2)),
        location: 'Main Street, Downtown',
        expiresAt: now.add(const Duration(hours: 4)),
      ),
      CommunityAlert(
        id: 'alert_2',
        title: 'Scheduled Road Maintenance',
        description: 'Oak Avenue will be closed for repaving from 6 AM to 4 PM tomorrow. Please use alternate routes.',
        type: AlertType.maintenance,
        priority: AlertPriority.medium,
        timestamp: now.subtract(const Duration(hours: 8)),
        location: 'Oak Avenue',
        expiresAt: now.add(const Duration(days: 1)),
      ),
      CommunityAlert(
        id: 'alert_3',
        title: 'Severe Weather Warning',
        description: 'Heavy thunderstorms expected this evening. Possible flooding in low-lying areas. Stay indoors and avoid unnecessary travel.',
        type: AlertType.weather,
        priority: AlertPriority.critical,
        timestamp: now.subtract(const Duration(minutes: 30)),
        expiresAt: now.add(const Duration(hours: 12)),
      ),
      CommunityAlert(
        id: 'alert_4',
        title: 'Community Meeting - Budget Discussion',
        description: 'Join us for the monthly community meeting to discuss the upcoming budget proposals. Your input is valuable!',
        type: AlertType.community,
        priority: AlertPriority.low,
        timestamp: now.subtract(const Duration(days: 1)),
        location: 'City Hall, Conference Room A',
        expiresAt: now.add(const Duration(days: 3)),
      ),
      CommunityAlert(
        id: 'alert_5',
        title: 'Power Outage - Elm Street',
        description: 'Electrical crews are working to restore power to the Elm Street area. Estimated restoration time is 2 hours.',
        type: AlertType.electricity,
        priority: AlertPriority.high,
        timestamp: now.subtract(const Duration(minutes: 45)),
        location: 'Elm Street Neighborhood',
        expiresAt: now.add(const Duration(hours: 3)),
      ),
    ];

    return sampleAlerts;
  }

  /// Add a new alert (for testing purposes)
  static Future<void> addAlert(CommunityAlert alert) async {
    try {
      final alerts = await _getCachedAlerts();
      alerts.insert(0, alert); // Add to beginning
      await _cacheAlerts(alerts);
    } catch (e) {
      print('Error adding alert: $e');
    }
  }
}