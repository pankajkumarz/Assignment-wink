import 'package:equatable/equatable.dart';
import 'geo_location.dart';

class Alert extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type;
  final String severity;
  final GeoArea affectedArea;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String>? alternateRoutes;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.affectedArea,
    required this.startDate,
    this.endDate,
    this.alternateRoutes,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        severity,
        affectedArea,
        startDate,
        endDate,
        alternateRoutes,
        isActive,
        createdBy,
        createdAt,
      ];

  Alert copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? severity,
    GeoArea? affectedArea,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? alternateRoutes,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      affectedArea: affectedArea ?? this.affectedArea,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alternateRoutes: alternateRoutes ?? this.alternateRoutes,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class GeoArea extends Equatable {
  final GeoLocation center;
  final double radius; // in meters
  final List<GeoLocation>? polygon; // for complex shapes

  const GeoArea({
    required this.center,
    required this.radius,
    this.polygon,
  });

  @override
  List<Object?> get props => [center, radius, polygon];

  GeoArea copyWith({
    GeoLocation? center,
    double? radius,
    List<GeoLocation>? polygon,
  }) {
    return GeoArea(
      center: center ?? this.center,
      radius: radius ?? this.radius,
      polygon: polygon ?? this.polygon,
    );
  }
}