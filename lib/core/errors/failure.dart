/// Failure classes for functional error handling.
///
/// Used as the Left side of Either-style results to represent
/// domain-level failures without throwing exceptions.
library;

import 'package:equatable/equatable.dart';

/// Base failure class.
sealed class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Failure due to network issues (no connection, timeout, etc.).
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  final int? statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure due to authentication issues.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Failure due to local cache/storage issues.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Failure due to server-side business logic errors.
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  final int? statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure due to validation errors (input, form, etc.).
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  final Map<String, String>? fieldErrors;

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Unknown / unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}
