import '../../core/utils/typedef.dart';
import '../entities/alert.dart';
import '../entities/geo_location.dart';

abstract class AlertRepository {
  // Alert CRUD operations
  ResultFuture<String> createAlert({required Alert alert});

  ResultFuture<Alert> getAlertById({required String alertId});

  ResultVoid updateAlert({required Alert alert});

  ResultVoid deleteAlert({required String alertId});

  // Alert queries
  ResultFuture<List<Alert>> getActiveAlerts();

  ResultFuture<List<Alert>> getAlertsByType({required String type});

  ResultFuture<List<Alert>> getAlertsBySeverity({required String severity});

  ResultFuture<List<Alert>> getAlertsByCreator({required String creatorId});

  // Geospatial queries
  ResultFuture<List<Alert>> getAlertsForLocation({
    required GeoLocation location,
  });

  ResultFuture<List<Alert>> getAlertsInArea({
    required GeoLocation center,
    required double radiusInKm,
  });

  // Real-time streams
  Stream<List<Alert>> watchActiveAlerts();

  Stream<List<Alert>> watchAlertsForLocation({
    required GeoLocation location,
  });

  Stream<Alert> watchAlert({required String alertId});

  // Alert management
  ResultVoid activateAlert({required String alertId});

  ResultVoid deactivateAlert({required String alertId});

  ResultVoid extendAlert({
    required String alertId,
    required DateTime newEndDate,
  });

  // Notification management
  ResultVoid sendAlertNotifications({
    required String alertId,
    required List<String> userIds,
  });

  ResultFuture<List<String>> getUsersInAlertArea({
    required String alertId,
  });

  // Analytics
  ResultFuture<Map<String, dynamic>> getAlertAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
}