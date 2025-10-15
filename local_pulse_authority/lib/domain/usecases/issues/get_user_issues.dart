import 'package:equatable/equatable.dart';

import '../../../core/utils/typedef.dart';
import '../../entities/issue.dart';
import '../../repositories/issue_repository.dart';
import '../usecase.dart';

class GetUserIssues extends UseCase<List<Issue>, GetUserIssuesParams> {
  const GetUserIssues(this._repository);

  final IssueRepository _repository;

  @override
  ResultFuture<List<Issue>> call(GetUserIssuesParams params) async {
    return _repository.getIssuesByReporter(reporterId: params.userId);
  }
}

class GetUserIssuesParams extends Equatable {
  const GetUserIssuesParams({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}