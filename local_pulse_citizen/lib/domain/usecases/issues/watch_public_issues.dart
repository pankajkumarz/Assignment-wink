import '../../entities/issue.dart';
import '../../repositories/issue_repository.dart';
import '../usecase.dart';

class WatchPublicIssues extends StreamUseCaseWithoutParams<List<Issue>> {
  const WatchPublicIssues(this._repository);

  final IssueRepository _repository;

  @override
  Stream<List<Issue>> call() {
    return _repository.watchPublicIssues();
  }
}