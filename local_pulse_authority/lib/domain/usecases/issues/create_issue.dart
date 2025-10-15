import 'package:equatable/equatable.dart';

import '../../../core/utils/typedef.dart';
import '../../entities/issue.dart';
import '../../repositories/issue_repository.dart';
import '../usecase.dart';

class CreateIssue extends UseCase<String, CreateIssueParams> {
  const CreateIssue(this._repository);

  final IssueRepository _repository;

  @override
  ResultFuture<String> call(CreateIssueParams params) async {
    return _repository.createIssue(issue: params.issue);
  }
}

class CreateIssueParams extends Equatable {
  const CreateIssueParams({required this.issue});

  final Issue issue;

  @override
  List<Object> get props => [issue];
}