import '../../../core/utils/typedef.dart';
import '../../entities/alert.dart';
import '../../repositories/alert_repository.dart';
import '../usecase.dart';

class GetActiveAlerts extends UseCaseWithoutParams<List<Alert>> {
  const GetActiveAlerts(this._repository);

  final AlertRepository _repository;

  @override
  ResultFuture<List<Alert>> call() async {
    return _repository.getActiveAlerts();
  }
}