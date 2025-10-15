part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
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

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}