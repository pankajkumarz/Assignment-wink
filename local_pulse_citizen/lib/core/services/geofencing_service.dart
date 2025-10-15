import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/alert.dart';
import '../../domain/entities/geo_location.dart';
import 'communication_service.dart';

/// Service to handle geofencing and location-based alert delivery
class GeofencingService {
  static GeofencingService? _instance;
  static GeofencingService get instance => _instance ??= GeofencingService._();
  
  GeofencingService._();

  final CommunicationService _communicationService = CommunicationService.instance;
  
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  final List<Alert> _activeAlerts = [];
  final Set<String> _notifiedAlerts = {};

  /// Initialize geofencing service
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled');
        }
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permissions are permanently denied');
        }
        return false;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (kDebugMode) {
        print('Geofencing service initialized successfully');
        print('Current position: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing geofencing service: $e');
      }
      return false;
    }
  }

  /// Start monitoring location for geofencing
  Future<void> startLocationMonitoring() async {
    try {
      if (_positionSubscription != null) {
        await stopLocationMonitoring();
      }

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Update every 100 meters
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          _checkGeofences(position);
        },
        onError: (error) {
          if (kDebugMode) {
            print('Location monitoring error: $error');
          }
        },
      );

      if (kDebugMode) {
        print('Location monitoring started');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting location monitoring: $e');
      }
    }
  }

  /// Stop location monitoring
  Future<void> stopLocationMonitoring() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    
    if (kDebugMode) {
      print('Location monitoring stopped');
    }
  }

  /// Add alerts to monitor for geofencing
  void addAlertsToMonitor(List<Alert> alerts) {
    _activeAlerts.clear();
    _activeAlerts.addAll(alerts.where((alert) => alert.isActive));
    
    if (kDebugMode) {
      print('Added ${_activeAlerts.length} alerts to geofencing monitor');
    }

    // Check current position against new alerts
    if (_currentPosition != null) {
      _checkGeofences(_currentPosition!);
    }
  }

  /// Remove alert from monitoring
  void removeAlertFromMonitor(String alertId) {
    _activeAlerts.removeWhere((alert) => alert.id == alertId);
    _notifiedAlerts.remove(alertId);
    
    if (kDebugMode) {
      print('Removed alert $alertId from geofencing monitor');
    }
  }

  /// Check if current position triggers any geofences
  void _checkGeofences(Position position) {
    for (final alert in _activeAlerts) {
      // Skip if already notified for this alert
      if (_notifiedAlerts.contains(alert.id)) {
        continue;
      }

      // Check if user is within the alert radius
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        alert.location.latitude,
        alert.location.longitude,
      );

      if (distance <= alert.radiusKm) {
        _triggerLocationBasedAlert(alert, position);
      }
    }
  }

  /// Trigger location-based alert notification
  Future<void> _triggerLocationBasedAlert(Alert alert, Position position) async {
    try {
      // Mark as notified to prevent duplicate notifications
      _notifiedAlerts.add(alert.id);

      // Send notification based on alert priority and type
      await _sendLocationBasedNotification(alert, position);

      if (kDebugMode) {
        print('Triggered location-based alert: ${alert.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error triggering location-based alert: $e');
      }
    }
  }

  /// Send location-based notification
  Future<void> _sendLocationBasedNotification(Alert alert, Position position) async {
    try {
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        alert.location.latitude,
        alert.location.longitude,
      );

      String notificationMessage = alert.message;
      
      // Add distance information
      if (distance < 1.0) {
        notificationMessage += '\n\nYou are ${(distance * 1000).round()}m away from this location.';
      } else {
        notificationMessage += '\n\nYou are ${distance.toStringAsFixed(1)}km away from this location.';
      }

      // Add route suggestions for road construction alerts
      if (alert.type == 'road_construction') {
        notificationMessage += '\n\nConsider using alternate routes.';
      }

      // Send via communication service with fallback
      if (alert.type == 'emergency') {
        await _communicationService.sendEmergencyAlert(
          alertTitle: alert.title,
          alertMessage: notificationMessage,
          location: alert.location.address,
          whatsappEnabled: true, // TODO: Get from user preferences
          pushEnabled: true,
          phoneNumber: null, // TODO: Get from user profile
        );
      } else {
        await _communicationService.sendCivicNewsUpdate(
          newsTitle: alert.title,
          newsContent: notificationMessage,
          category: alert.category ?? alert.type,
          whatsappEnabled: true, // TODO: Get from user preferences
          pushEnabled: true,
          phoneNumber: null, // TODO: Get from user profile
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending location-based notification: $e');
      }
    }
  }

  /// Calculate distance between two points in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Get current position
  Position? get currentPosition => _currentPosition;

  /// Check if user is within alert radius
  bool isWithinAlertRadius(Alert alert, {Position? position}) {
    final pos = position ?? _currentPosition;
    if (pos == null) return false;

    final distance = _calculateDistance(
      pos.latitude,
      pos.longitude,
      alert.location.latitude,
      alert.location.longitude,
    );

    return distance <= alert.radiusKm;
  }

  /// Get nearby alerts within specified radius
  List<Alert> getNearbyAlerts({double radiusKm = 5.0, Position? position}) {
    final pos = position ?? _currentPosition;
    if (pos == null) return [];

    return _activeAlerts.where((alert) {
      final distance = _calculateDistance(
        pos.latitude,
        pos.longitude,
        alert.location.latitude,
        alert.location.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Clear notification history (for testing)
  void clearNotificationHistory() {
    _notifiedAlerts.clear();
    if (kDebugMode) {
      print('Cleared notification history');
    }
  }

  /// Get geofencing status
  Map<String, dynamic> getStatus() {
    return {
      'isMonitoring': _positionSubscription != null,
      'currentPosition': _currentPosition != null ? {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      } : null,
      'activeAlerts': _activeAlerts.length,
      'notifiedAlerts': _notifiedAlerts.length,
    };
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopLocationMonitoring();
    _activeAlerts.clear();
    _notifiedAlerts.clear();
    _currentPosition = null;
  }
}