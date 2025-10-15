import 'package:equatable/equatable.dart';

import '../../../core/utils/typedef.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class SignUpWithEmail extends UseCase<User, SignUpWithEmailParams> {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<User> call(SignUpWithEmailParams params) async {
    return _repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
      age: params.age,
      city: params.city,
      phone: params.phone,
    );
  }
}

class SignUpWithEmailParams extends Equatable {
  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.city,
    this.phone,
  });

  final String email;
  final String password;
  final String name;
  final int age;
  final String city;
  final String? phone;

  @override
  List<Object?> get props => [email, password, name, age, city, phone];
}