import 'package:equatable/equatable.dart';

import '../../../core/utils/typedef.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class SignInWithEmail extends UseCase<User, SignInWithEmailParams> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<User> call(SignInWithEmailParams params) async {
    return _repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailParams extends Equatable {
  const SignInWithEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}