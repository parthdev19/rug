/// Base repository with common error handling patterns.
///
/// All feature repositories should extend this to get consistent
/// error handling and network checking.
library;

import 'package:dio/dio.dart';
import 'package:rug/core/errors/app_exception.dart';
import 'package:rug/core/errors/error_handler.dart';
import 'package:rug/core/errors/failure.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/services/network/network_info.dart';

/// Base repository providing error handling utilities.
abstract class BaseRepository {
  const BaseRepository({required this.networkInfo});

  final NetworkInfo networkInfo;

  /// Wraps a remote API call with error handling.
  ///
  /// Returns the result on success, throws [AppException] on failure.
  Future<T> safeApiCall<T>(Future<T> Function() call) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(
        message: 'No internet connection.',
        code: 'NO_CONNECTION',
      );
    }

    try {
      return await call();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected repository error', error: e, stackTrace: stackTrace);
      throw ServerException(message: e.toString());
    }
  }

  /// Wraps a local cache operation with error handling.
  Future<T> safeCacheCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e, stackTrace) {
      AppLogger.error('Cache operation failed', error: e, stackTrace: stackTrace);
      throw CacheException(message: e.toString());
    }
  }

  /// Converts an [AppException] to a [Failure].
  Failure mapToFailure(AppException exception) {
    return ErrorHandler.mapExceptionToFailure(exception);
  }
}
