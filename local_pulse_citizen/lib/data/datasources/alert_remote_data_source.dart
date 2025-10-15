import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/alert_model.dart';

abstract class AlertRemoteDataSource {
  Future<List<AlertModel>> getAlertsForLocation(String city, double latitude, double longitude);
  Future<List<AlertModel>> getEmergencyAlerts(String city);
  Future<List<AlertModel>> getCivicNews(String city);
  Stream<List<AlertModel>> watchAlertsForLocation(String city, double latitude, double longitude);
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  final FirebaseFirestore _firestore;

  AlertRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<AlertModel>> getAlertsForLocation(
    String city,
    double latitude,
    double longitude,
  ) async {
    try {
      // Query alerts for the specific city and within a certain radius
      final query = await _firestore
          .collection('alerts')
          .where('city', isEqualTo: city)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final alerts = query.docs
          .map((doc) => AlertModel.fromFirestore(doc))
          .where((alert) => _isWithinRadius(
                latitude,
                longitude,
                alert.location.latitude,
                alert.location.longitude,
                alert.radiusKm,
              ))
          .toList();

      if (kDebugMode) {
        print('Retrieved ${alerts.length} alerts for location: $city');
      }

      return alerts;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting alerts for location: $e');
      }
      throw Exception('Failed to get alerts for location: $e');
    }
  }

  @override
  Future<List<AlertModel>> getEmergencyAlerts(String city) async {
    try {
      final query = await _firestore
          .collection('alerts')
          .where('city', isEqualTo: city)
          .where('type', isEqualTo: 'emergency')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final alerts = query.docs
          .map((doc) => AlertModel.fromFirestore(doc))
          .toList();

      if (kDebugMode) {
        print('Retrieved ${alerts.length} emergency alerts for: $city');
      }

      return alerts;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting emergency alerts: $e');
      }
      throw Exception('Failed to get emergency alerts: $e');
    }
  }

  @override
  Future<List<AlertModel>> getCivicNews(String city) async {
    try {
      final query = await _firestore
          .collection('alerts')
          .where('city', isEqualTo: city)
          .where('type', isEqualTo: 'news')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      final alerts = query.docs
          .map((doc) => AlertModel.fromFirestore(doc))
          .toList();

      if (kDebugMode) {
        print('Retrieved ${alerts.length} civic news items for: $city');
      }

      return alerts;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting civic news: $e');
      }
      throw Exception('Failed to get civic news: $e');
    }
  }

  @override
  Stream<List<AlertModel>> watchAlertsForLocation(
    String city,
    double latitude,
    double longitude,
  ) {
    try {
      return _firestore
          .collection('alerts')
          .where('city', isEqualTo: city)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        final alerts = snapshot.docs
            .map((doc) => AlertModel.fromFirestore(doc))
            .where((alert) => _isWithinRadius(
                  latitude,
                  longitude,
                  alert.location.latitude,
                  alert.location.longitude,
                  alert.radiusKm,
                ))
            .toList();

        if (kDebugMode) {
          print('Real-time alerts update: ${alerts.length} alerts');
        }

        return alerts;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error watching alerts for location: $e');
      }
      throw Exception('Failed to watch alerts for location: $e');
    }
  }

  /// Calculate if a point is within the specified radius of an alert
  bool _isWithinRadius(
    double userLat,
    double userLng,
    double alertLat,
    double alertLng,
    double radiusKm,
  ) {
    // Simple distance calculation using Haversine formula
    const double earthRadiusKm = 6371.0;
    
    final double dLat = _degreesToRadians(alertLat - userLat);
    final double dLng = _degreesToRadians(alertLng - userLng);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        userLat.cos() * alertLat.cos() * (dLng / 2).sin() * (dLng / 2).sin();
    
    final double c = 2 * a.sqrt().asin();
    final double distance = earthRadiusKm * c;
    
    return distance <= radiusKm;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }
}

extension on double {
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}