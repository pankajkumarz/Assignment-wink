import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/alert.dart';
import '../domain/entities/geo_location.dart';

class AlertService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Uuid _uuid = Uuid();

  /// Send a new alert to citizens
  static Future<String> sendAlert({
    required String title,
    required String message,
    required String type,
    required String priority,
    required GeoLocation location,
    required String city,
    required double radiusKm,
    DateTime? expiresAt,
    String? category,
    List<String>? tags,
    String? actionUrl,
    String? imageUrl,
    required String createdBy,
  }) async {
    try {
      final alertId = _uuid.v4();
      final now = DateTime.now();

      final alertData = {
        'title': title,
        'message': message,
        'type': type,
        'priority': priority,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': location.address,
          'city': location.city,
        },
        'city': city,
        'radiusKm': radiusKm,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
        'category': category,
        'tags': tags ?? [],
        'actionUrl': actionUrl,
        'imageUrl': imageUrl,
        'createdBy': createdBy,
        'estimatedAffectedPeople': _estimateAffectedPeople(radiusKm),
      };

      await _firestore.collection('alerts').doc(alertId).set(alertData);

      // Send push notifications to affected users
      await _sendPushNotifications(alertId, title, message, location, radiusKm, priority);

      return alertId;
    } catch (e) {
      throw Exception('Failed to send alert: $e');
    }
  }

  /// Get all alerts created by authorities
  static Stream<List<Alert>> getAlertsStream() {
    return _firestore
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _alertFromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// Get active alerts only
  static Stream<List<Alert>> getActiveAlertsStream() {
    return _firestore
        .collection('alerts')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _alertFromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// Get alerts by priority
  static Stream<List<Alert>> getAlertsByPriority(String priority) {
    return _firestore
        .collection('alerts')
        .where('priority', isEqualTo: priority)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _alertFromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// Update alert status
  static Future<void> updateAlertStatus(String alertId, bool isActive) async {
    await _firestore.collection('alerts').doc(alertId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete alert
  static Future<void> deleteAlert(String alertId) async {
    await _firestore.collection('alerts').doc(alertId).delete();
  }

  /// Get alert statistics
  static Future<Map<String, int>> getAlertStatistics() async {
    final allAlerts = await _firestore.collection('alerts').get();
    
    final stats = <String, int>{
      'total': allAlerts.docs.length,
      'active': 0,
      'expired': 0,
      'emergency': 0,
      'high': 0,
      'medium': 0,
      'low': 0,
    };

    final now = DateTime.now();

    for (final doc in allAlerts.docs) {
      final data = doc.data();
      final isActive = data['isActive'] ?? false;
      final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
      final priority = data['priority'] ?? 'medium';

      if (isActive) {
        if (expiresAt != null && now.isAfter(expiresAt)) {
          stats['expired'] = (stats['expired'] ?? 0) + 1;
        } else {
          stats['active'] = (stats['active'] ?? 0) + 1;
        }
      }

      stats[priority] = (stats[priority] ?? 0) + 1;
    }

    return stats;
  }

  /// Send emergency alert (high priority, immediate)
  static Future<String> sendEmergencyAlert({
    required String title,
    required String message,
    required GeoLocation location,
    required String city,
    required double radiusKm,
    required String createdBy,
    String? actionUrl,
  }) async {
    return await sendAlert(
      title: title,
      message: message,
      type: 'emergency',
      priority: 'emergency',
      location: location,
      city: city,
      radiusKm: radiusKm,
      category: 'emergency',
      tags: ['emergency', 'urgent'],
      actionUrl: actionUrl,
      createdBy: createdBy,
    );
  }

  /// Send traffic alert
  static Future<String> sendTrafficAlert({
    required String title,
    required String message,
    required GeoLocation location,
    required String city,
    required double radiusKm,
    required String createdBy,
    DateTime? expiresAt,
    List<String>? alternateRoutes,
  }) async {
    return await sendAlert(
      title: title,
      message: message,
      type: 'traffic',
      priority: 'medium',
      location: location,
      city: city,
      radiusKm: radiusKm,
      expiresAt: expiresAt,
      category: 'traffic',
      tags: alternateRoutes != null ? ['traffic', 'routes'] : ['traffic'],
      createdBy: createdBy,
    );
  }

  /// Send weather alert
  static Future<String> sendWeatherAlert({
    required String title,
    required String message,
    required GeoLocation location,
    required String city,
    required double radiusKm,
    required String priority,
    required String createdBy,
    DateTime? expiresAt,
  }) async {
    return await sendAlert(
      title: title,
      message: message,
      type: 'weather',
      priority: priority,
      location: location,
      city: city,
      radiusKm: radiusKm,
      expiresAt: expiresAt,
      category: 'weather',
      tags: ['weather', 'safety'],
      createdBy: createdBy,
    );
  }

  /// Convert Firestore document to Alert entity
  static Alert _alertFromFirestore(String id, Map<String, dynamic> data) {
    return Alert(
      id: id,
      title: data['title'] ?? 'Unknown Alert',
      message: data['message'] ?? 'No message provided',
      type: data['type'] ?? 'general',
      priority: data['priority'] ?? 'medium',
      location: GeoLocation(
        latitude: (data['location']?['latitude'] ?? 0.0).toDouble(),
        longitude: (data['location']?['longitude'] ?? 0.0).toDouble(),
        address: data['location']?['address'] ?? 'Unknown Address',
        city: data['location']?['city'] ?? 'Unknown City',
      ),
      city: data['city'] ?? 'Unknown City',
      radiusKm: (data['radiusKm'] ?? 5.0).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      category: data['category'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      actionUrl: data['actionUrl'],
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? 'Unknown',
      estimatedAffectedPeople: data['estimatedAffectedPeople'],
    );
  }

  /// Estimate affected people based on radius (rough calculation)
  static int _estimateAffectedPeople(double radiusKm) {
    // Rough estimate: 1000 people per square km in urban areas
    final areaKm2 = 3.14159 * radiusKm * radiusKm;
    return (areaKm2 * 1000).round();
  }

  /// Send push notifications to affected users (placeholder)
  static Future<void> _sendPushNotifications(
    String alertId,
    String title,
    String message,
    GeoLocation location,
    double radiusKm,
    String priority,
  ) async {
    // TODO: Implement actual push notification logic
    // This would typically involve:
    // 1. Finding users within the radius
    // 2. Getting their FCM tokens
    // 3. Sending push notifications via Firebase Cloud Messaging
    
    print('Sending push notifications for alert: $alertId');
    print('Title: $title');
    print('Message: $message');
    print('Priority: $priority');
    print('Estimated reach: ${_estimateAffectedPeople(radiusKm)} people');
  }
}