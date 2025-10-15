class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
}