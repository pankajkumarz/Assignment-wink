import 'package:equatable/equatable.dart';
import 'location_model.dart';

class IssueModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String reporterId;
  final LocationModel location;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedTo;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  const IssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.reporterId,
    required this.location,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    this.resolvedBy,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'reporterId': reporterId,
      'location': location.toMap(),
      'imageUrls': imageUrls,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'assignedTo': assignedTo,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.millisecondsSinceEpoch,
    };
  }

  factory IssueModel.fromMap(Map<String, dynamic> map) {
    return IssueModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      priority: map['priority'] ?? 'Medium',
      status: map['status'] ?? 'submitted',
      reporterId: map['reporterId'] ?? '',
      location: LocationModel.fromMap(map['location'] ?? {}),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      assignedTo: map['assignedTo'],
      resolvedBy: map['resolvedBy'],
      resolvedAt: map['resolvedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['resolvedAt'])
          : null,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'acknowledged':
        return 'Acknowledged';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [
        id, title, description, category, priority, status, reporterId,
        location, imageUrls, createdAt, updatedAt, assignedTo, resolvedBy, resolvedAt
      ];
}