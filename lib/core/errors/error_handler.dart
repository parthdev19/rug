/// Global error handler for the RUG application.
///
/// Catches and processes all unhandled exceptions, mapping them
/// to user-friendly messages and logging them appropriately.
library;

import 'package:dio/dio.dart';
import 'package:rug/core/errors/app_exception.dart';
import 'package:rug/core/errors/failure.dart';
import 'package:rug/services/logging/app_logger.dart';

class ErrorHandler {
  ErrorHandler._();

  /// Maps a [DioException] to an [AppException].
  static NetworkException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please try again.',
          code: 'CONNECTION_TIMEOUT',
        );
      case DioExceptionType.sendTimeout:
        return const NetworkException(
          message: 'Request timed out. Please try again.',
          code: 'SEND_TIMEOUT',
        );
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Server took too long to respond.',
          code: 'RECEIVE_TIMEOUT',
        );
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled.',
          code: 'CANCELLED',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection.',
          code: 'NO_CONNECTION',
        );
      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Security certificate error.',
          code: 'BAD_CERTIFICATE',
        );
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: error.message ?? 'An unexpected network error occurred.',
          code: 'UNKNOWN',
        );
    }
  }

  /// Maps HTTP status codes to appropriate exceptions.
  static NetworkException _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return const NetworkException(
          message: 'Bad request.',
          code: 'BAD_REQUEST',
          statusCode: 400,
        );
      case 401:
        return const NetworkException(
          message: 'Session expired. Please log in again.',
          code: 'UNAUTHORIZED',
          statusCode: 401,
        );
      case 403:
        return const NetworkException(
          message: 'Access denied.',
          code: 'FORBIDDEN',
          statusCode: 403,
        );
      case 404:
        return const NetworkException(
          message: 'Resource not found.',
          code: 'NOT_FOUND',
          statusCode: 404,
        );
      case 409:
        return const NetworkException(
          message: 'Conflict — resource already exists.',
          code: 'CONFLICT',
          statusCode: 409,
        );
      case 429:
        return const NetworkException(
          message: 'Too many requests. Please slow down.',
          code: 'RATE_LIMITED',
          statusCode: 429,
        );
      case 500:
        return const NetworkException(
          message: 'Internal server error.',
          code: 'SERVER_ERROR',
          statusCode: 500,
        );
      case 503:
        return const NetworkException(
          message: 'Server is temporarily unavailable.',
          code: 'SERVICE_UNAVAILABLE',
          statusCode: 503,
        );
      default:
        return NetworkException(
          message: 'Unexpected error (HTTP $statusCode).',
          code: 'HTTP_$statusCode',
          statusCode: statusCode,
        );
    }
  }

  /// Converts any [AppException] to a [Failure] for domain-layer use.
  static Failure mapExceptionToFailure(AppException exception) {
    return switch (exception) {
      NetworkException(:final message, :final code, :final statusCode) =>
        NetworkFailure(message: message, code: code, statusCode: statusCode),
      AuthException(:final message, :final code) =>
        AuthFailure(message: message, code: code),
      CacheException(:final message, :final code) =>
        CacheFailure(message: message, code: code),
      ServerException(:final message, :final code, :final statusCode) =>
        ServerFailure(message: message, code: code, statusCode: statusCode),
      _ => UnknownFailure(message: exception.message, code: exception.code),
    };
  }

  /// Logs and reports an error globally.
  static void reportError(Object error, StackTrace stackTrace) {
    AppLogger.error('Unhandled error', error: error, stackTrace: stackTrace);
    // TODO: Add Crashlytics / Sentry reporting here
  }
}
