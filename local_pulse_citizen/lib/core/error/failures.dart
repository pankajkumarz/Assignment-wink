import 'package:equatable/equatable.dart';
import '../errors/failure.dart';

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message: message, statusCode: 401);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message: message, statusCode: 500);
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message: message, statusCode: 503);
}