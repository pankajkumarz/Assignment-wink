import '../../../core/utils/typedef.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class GetCurrentUser extends UseCaseWithoutParams<User?> {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<User?> call() async {
    return _repository.getCurrentUser();
  }
}