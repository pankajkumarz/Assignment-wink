part of 'issues_bloc.dart';

abstract class IssuesEvent extends Equatable {
  const IssuesEvent();

  @override
  List<Object?> get props => [];
}

class IssueCreateRequested extends IssuesEvent {
  const IssueCreateRequested({
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.priority,
    required this.location,
    required this.images,
    required this.reporterId,
  });

  final String title;
  final String description;
  final String category;
  final String subcategory;
  final String priority;
  final GeoLocation location;
  final List<File> images;
  final String reporterId;

  @override
  List<Object> get props => [
        title,
        description,
        category,
        subcategory,
        priority,
        location,
        images,
        reporterId,
      ];
}

class UserIssuesRequested extends IssuesEvent {
  const UserIssuesRequested({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

class NearbyIssuesRequested extends IssuesEvent {
  const NearbyIssuesRequested({
    required this.location,
    required this.radiusInKm,
  });

  final GeoLocation location;
  final double radiusInKm;

  @override
  List<Object> get props => [location, radiusInKm];
}

class PublicIssuesWatchRequested extends IssuesEvent {
  const PublicIssuesWatchRequested();
}

class PublicIssuesUpdated extends IssuesEvent {
  const PublicIssuesUpdated(this.issues);

  final List<Issue> issues;

  @override
  List<Object> get props => [issues];
}