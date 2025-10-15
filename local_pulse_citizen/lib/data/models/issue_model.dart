import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/typedef.dart';
import '../../domain/entities/issue.dart';
import '../../domain/entities/geo_location.dart';

class IssueModel extends Issue {
  const IssueModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.subcategory,
    required super.priority,
    required super.status,
    required super.location,
    required super.images,
    required super.reporterId,
    super.assignedTo,
    super.department,
    super.estimatedResolution,
    super.actualResolution,
    super.feedback,
    required super.createdAt,
    required super.updatedAt,
  });

  factory IssueModel.fromMap(DataMap map) {
    return IssueModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      priority: map['priority'] ?? 'medium',
      status: map['status'] ?? 'submitted',
      location: GeoLocationModel.fromMap(map['location'] ?? {}),
      images: List<String>.from(map['images'] ?? []),
      reporterId: map['reporterId'] ?? '',
      assignedTo: map['assignedTo'],
      department: map['department'],
      estimatedResolution: map['estimatedResolution'] != null
          ? (map['estimatedResolution'] as Timestamp).toDate()
          : null,
      actualResolution: map['actualResolution'] != null
          ? (map['actualResolution'] as Timestamp).toDate()
          : null,
      feedback: map['feedback'] != null
          ? IssueFeedbackModel.fromMap(map['feedback'])
          : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory IssueModel.fromEntity(Issue issue) {
    return IssueModel(
      id: issue.id,
      title: issue.title,
      description: issue.description,
      category: issue.category,
      subcategory: issue.subcategory,
      priority: issue.priority,
      status: issue.status,
      location: issue.location,
      images: issue.images,
      reporterId: issue.reporterId,
      assignedTo: issue.assignedTo,
      department: issue.department,
      estimatedResolution: issue.estimatedResolution,
      actualResolution: issue.actualResolution,
      feedback: issue.feedback,
      createdAt: issue.createdAt,
      updatedAt: issue.updatedAt,
    );
  }

  DataMap toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'priority': priority,
      'status': status,
      'location': GeoLocationModel.fromEntity(location).toMap(),
      'images': images,
      'reporterId': reporterId,
      'assignedTo': assignedTo,
      'department': department,
      'estimatedResolution': estimatedResolution != null
          ? Timestamp.fromDate(estimatedResolution!)
          : null,
      'actualResolution': actualResolution != null
          ? Timestamp.fromDate(actualResolution!)
          : null,
      'feedback': feedback != null
          ? IssueFeedbackModel.fromEntity(feedback!).toMap()
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class GeoLocationModel extends GeoLocation {
  const GeoLocationModel({
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.city,
  });

  factory GeoLocationModel.fromMap(DataMap map) {
    return GeoLocationModel(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
      city: map['city'] ?? '',
    );
  }

  factory GeoLocationModel.fromEntity(GeoLocation location) {
    return GeoLocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      city: location.city,
    );
  }

  @override
  DataMap toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
    };
  }
}

class IssueFeedbackModel extends IssueFeedback {
  const IssueFeedbackModel({
    required super.rating,
    super.comment,
    required super.submittedAt,
  });

  factory IssueFeedbackModel.fromMap(DataMap map) {
    return IssueFeedbackModel(
      rating: map['rating'] ?? 0,
      comment: map['comment'],
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory IssueFeedbackModel.fromEntity(IssueFeedback feedback) {
    return IssueFeedbackModel(
      rating: feedback.rating,
      comment: feedback.comment,
      submittedAt: feedback.submittedAt,
    );
  }

  DataMap toMap() {
    return {
      'rating': rating,
      'comment': comment,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }
}