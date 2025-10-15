import 'package:dartz/dartz.dart';
import 'dart:io';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/utils/typedef.dart';
import '../../domain/entities/issue.dart';
import '../../domain/entities/geo_location.dart';
import '../../domain/repositories/issue_repository.dart';
import '../datasources/issue_remote_data_source.dart';
import '../models/issue_model.dart';

class IssueRepositoryImpl implements IssueRepository {
  const IssueRepositoryImpl(this._remoteDataSource);

  final IssueRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<String> createIssue({required Issue issue}) async {
    try {
      final result = await _remoteDataSource.createIssue(
        issue: IssueModel.fromEntity(issue),
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<Issue> getIssueById({required String issueId}) async {
    try {
      final result = await _remoteDataSource.getIssueById(issueId: issueId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid updateIssue({required Issue issue}) async {
    try {
      await _remoteDataSource.updateIssue(issue: IssueModel.fromEntity(issue));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultVoid deleteIssue({required String issueId}) async {
    try {
      await _remoteDataSource.deleteIssue(issueId: issueId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Issue>> getIssuesByReporter({required String reporterId}) async {
    try {
      final result = await _remoteDataSource.getIssuesByReporter(reporterId: reporterId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Issue>> getIssuesByStatus({required String status}) async {
    try {
      final result = await _remoteDataSource.getIssuesByStatus(status: status);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Issue>> getIssuesByCategory({required String category}) async {
    try {
      final result = await _remoteDataSource.getIssuesByCategory(category: category);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Issue>> getIssuesByCity({required String city}) async {
    try {
      final result = await _remoteDataSource.getIssuesByCity(city: city);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Issue>> getIssuesByAssignee({required String assigneeId}) async {
    // TODO: Implement in data source
    return const Left(ServerFailure('Not implemented yet'));
  }

  @override
  ResultFuture<List<Issue>> getIssuesByDepartment({required String department}) async {
    // TODO: Implement in data source
    return const Left(ServerFailure('Not implemented yet'));
  }

  @override
  ResultFuture<List<Issue>> getIssuesNearLocation({
    required GeoLocation location,
    required double radiusInKm,
  }) async {
    try {
      final result = await _remoteDataSource.getIssuesNearLocation(
        location: location,
        radiusInKm: radiusInKm,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Issue>> getIssuesInBounds({
    required double northLat,
    required double southLat,
    required double eastLng,
    required double westLng,
  }) async {
    // TODO: Implement geospatial bounds query
    return const Left(ServerFailure('Not implemented yet'));
  }

  @override
  Stream<List<Issue>> watchIssuesByReporter({required String reporterId}) {
    return _remoteDataSource.watchIssuesByReporter(reporterId: reporterId);
  }

  @override
  Stream<List<Issue>> watchPublicIssues() {
    return _remoteDataSource.watchPublicIssues();
  }

  @override
  Stream<Issue> watchIssue({required String issueId}) {
    return _remoteDataSource.watchIssue(issueId: issueId);
  }

  // Authority functions - TODO: Implement
  @override
  ResultVoid assignIssue({
    required String issueId,
    required String assigneeId,
    required String department,
  }) async {
    return const Left(ServerFailure('Authority functions not implemented yet'));
  }

  @override
  ResultVoid updateIssueStatus({
    required String issueId,
    required String status,
    String? comment,
    DateTime? estimatedResolution,
  }) async {
    return const Left(ServerFailure('Authority functions not implemented yet'));
  }

  @override
  ResultVoid addIssueComment({
    required String issueId,
    required String comment,
    required String authorId,
  }) async {
    return const Left(ServerFailure('Comments not implemented yet'));
  }

  @override
  ResultVoid submitFeedback({
    required String issueId,
    required IssueFeedback feedback,
  }) async {
    return const Left(ServerFailure('Feedback not implemented yet'));
  }

  @override
  ResultFuture<Map<String, dynamic>> getIssueAnalytics({
    String? city,
    String? department,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const Left(ServerFailure('Analytics not implemented yet'));
  }

  @override
  ResultVoid bulkUpdateIssueStatus({
    required List<String> issueIds,
    required String status,
  }) async {
    return const Left(ServerFailure('Bulk operations not implemented yet'));
  }

  @override
  ResultVoid bulkAssignIssues({
    required List<String> issueIds,
    required String assigneeId,
    required String department,
  }) async {
    return const Left(ServerFailure('Bulk operations not implemented yet'));
  }

  // Helper method for image upload
  Future<Either<Failure, List<String>>> uploadImages({
    required String issueId,
    required List<File> images,
  }) async {
    try {
      final result = await _remoteDataSource.uploadImages(
        issueId: issueId,
        images: images,
      );
      return Right(result);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
}