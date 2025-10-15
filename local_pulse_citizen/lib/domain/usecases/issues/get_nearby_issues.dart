import 'package:equatable/equatable.dart';

import '../../../core/utils/typedef.dart';
import '../../entities/issue.dart';
import '../../entities/geo_location.dart';
import '../../repositories/issue_repository.dart';
import '../usecase.dart';

class GetNearbyIssues extends UseCase<List<Issue>, GetNearbyIssuesParams> {
  const GetNearbyIssues(this._repository);

  final IssueRepository _repository;

  @override
  ResultFuture<List<Issue>> call(GetNearbyIssuesParams params) async {
    return _repository.getIssuesNearLocation(
      location: params.location,
      radiusInKm: params.radiusInKm,
    );
  }
}

class GetNearbyIssuesParams extends Equatable {
  const GetNearbyIssuesParams({
    required this.location,
    required this.radiusInKm,
  });

  final GeoLocation location;
  final double radiusInKm;

  @override
  List<Object> get props => [location, radiusInKm];
}