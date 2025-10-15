import '../../core/utils/typedef.dart';
import '../entities/issue.dart';
import '../entities/geo_location.dart';

abstract class IssueRepository {
  // Issue CRUD operations
  ResultFuture<String> createIssue({required Issue issue});

  ResultFuture<Issue> getIssueById({required String issueId});

  ResultVoid updateIssue({required Issue issue});

  ResultVoid deleteIssue({required String issueId});

  // Issue queries
  ResultFuture<List<Issue>> getIssuesByReporter({required String reporterId});

  ResultFuture<List<Issue>> getIssuesByStatus({required String status});

  ResultFuture<List<Issue>> getIssuesByCategory({required String category});

  ResultFuture<List<Issue>> getIssuesByCity({required String city});

  ResultFuture<List<Issue>> getIssuesByAssignee({required String assigneeId});

  ResultFuture<List<Issue>> getIssuesByDepartment({required String department});

  // Geospatial queries
  ResultFuture<List<Issue>> getIssuesNearLocation({
    required GeoLocation location,
    required double radiusInKm,
  });

  ResultFuture<List<Issue>> getIssuesInBounds({
    required double northLat,
    required double southLat,
    required double eastLng,
    required double westLng,
  });

  // Real-time streams
  Stream<List<Issue>> watchIssuesByReporter({required String reporterId});

  Stream<List<Issue>> watchPublicIssues();

  Stream<Issue> watchIssue({required String issueId});

  // Issue management (Authority functions)
  ResultVoid assignIssue({
    required String issueId,
    required String assigneeId,
    required String department,
  });

  ResultVoid updateIssueStatus({
    required String issueId,
    required String status,
    String? comment,
    DateTime? estimatedResolution,
  });

  ResultVoid addIssueComment({
    required String issueId,
    required String comment,
    required String authorId,
  });

  // Feedback
  ResultVoid submitFeedback({
    required String issueId,
    required IssueFeedback feedback,
  });

  // Analytics
  ResultFuture<Map<String, dynamic>> getIssueAnalytics({
    String? city,
    String? department,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Bulk operations
  ResultVoid bulkUpdateIssueStatus({
    required List<String> issueIds,
    required String status,
  });

  ResultVoid bulkAssignIssues({
    required List<String> issueIds,
    required String assigneeId,
    required String department,
  });
}