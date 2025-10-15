import 'package:flutter/foundation.dart';

import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_remote_data_source.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource _remoteDataSource;

  AlertRepositoryImpl({
    required AlertRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Alert>> getAlertsForLocation(
    String city,
    double latitude,
    double longitude,
  ) async {
    try {
      final alertModels = await _remoteDataSource.getAlertsForLocation(
        city,
        latitude,
        longitude,
      );
      
      if (kDebugMode) {
        print('AlertRepository: Retrieved ${alertModels.length} alerts for $city');
      }
      
      return alertModels;
    } catch (e) {
      if (kDebugMode) {
        print('AlertRepository: Error getting alerts for location: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<Alert>> getEmergencyAlerts(String city) async {
    try {
      final alertModels = await _remoteDataSource.getEmergencyAlerts(city);
      
      if (kDebugMode) {
        print('AlertRepository: Retrieved ${alertModels.length} emergency alerts for $city');
      }
      
      return alertModels;
    } catch (e) {
      if (kDebugMode) {
        print('AlertRepository: Error getting emergency alerts: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<Alert>> getCivicNews(String city) async {
    try {
      final alertModels = await _remoteDataSource.getCivicNews(city);
      
      if (kDebugMode) {
        print('AlertRepository: Retrieved ${alertModels.length} civic news items for $city');
      }
      
      return alertModels;
    } catch (e) {
      if (kDebugMode) {
        print('AlertRepository: Error getting civic news: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<List<Alert>> watchAlertsForLocation(
    String city,
    double latitude,
    double longitude,
  ) {
    try {
      return _remoteDataSource.watchAlertsForLocation(
        city,
        latitude,
        longitude,
      );
    } catch (e) {
      if (kDebugMode) {
        print('AlertRepository: Error watching alerts for location: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<Alert>> getAlertsByType(String city, String type) async {
    try {
      // For now, we'll filter by type after getting all alerts
      // In a real implementation, you'd add type filtering to the data source
      final allAlerts = await _remoteDataSource.getAlertsForLocation(
        city,
        0.0, // Default coordinates for city-wide alerts
        0.0,
      );
      
      final filteredAlerts = allAlerts.where((alert) => alert.type == type).toList();
      
      if (kDebugMode) {
        print('AlertRepository: Retrieved ${filteredAlerts.length} alerts of type $type for $city');
      }
      
      return filteredAlerts;
    } catch (e) {
      if (kDebugMode) {
        print('AlertRepository: Error getting alerts by type: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<Alert>> getAlertsByPriority(String city, String priority) async {
    try {
      // For now, we'll filter by priority after getting all alerts
      // In a real implementation, you'd add priority filtering to the data source
      final allAlerts = await _remoteDataSource.getAlertsForLocation(
        city,
        0.0, // Default coordinates for city-wide alerts
        0.0,
      );
      
      final filteredAlerts = allAlerts.where((alert) => alert.priority == priority).toList();
      
      if (kDebugMode) {
        print('AlertRepository: Retrieved ${filteredAlerts.length} alerts with priority $priority for $city');
      }
      
      return filteredAlerts;
    } catch (e) {
      if (kDebugMode) {
        print('AlertRepository: Error getting alerts by priority: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Alert?> getAlertById(String alertId) async {
    try {
      // This would require a separate method in the data source
      // For now, we'll return null as this is a placeholder implementation
      if (kDebugMode) {
        print('AlertRepository: Getting alert by ID: $alertId (not implemented)');
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('AlertRepository: Error getting alert by ID: $e');
      }
      rethrow;
    }
  }
}