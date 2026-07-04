/// Base exception hierarchy for the RUG application.
///
/// All app-specific exceptions extend [AppException] so they can be
/// caught uniformly by the global error handler.
library;

/// Base class for all application exceptions.
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException($code): $message';
}

/// Exception thrown when a network request fails.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.stackTrace,
    this.statusCode,
  });

  final int? statusCode;
}

/// Exception thrown when authentication fails or token expires.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when local storage operations fail.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when data parsing/serialization fails.
class SerializationException extends AppException {
  const SerializationException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when a WebSocket operation fails.
class WebSocketException extends AppException {
  const WebSocketException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when server returns a known business-logic error.
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.stackTrace,
    this.statusCode,
  });

  final int? statusCode;
}

/// Exception thrown when a required permission is denied.
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}
