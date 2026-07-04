/// Dio HTTP client configuration.
///
/// Singleton Dio instance with base options, interceptors,
/// and retry logic pre-configured.
library;

import 'package:dio/dio.dart';
import 'package:rug/config/env/env_config.dart';
import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/core/constants/app_constants.dart';
import 'package:rug/services/network/api_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio? _instance;

  /// Returns the singleton [Dio] instance.
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  /// Creates a configured [Dio] instance.
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.instance.apiBaseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      ApiInterceptor(),
      if (EnvConfig.instance.enableLogging)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          responseHeader: false,
        ),
    ]);

    return dio;
  }

  /// Resets the Dio instance (useful for token refresh).
  static void reset() {
    _instance?.close();
    _instance = null;
  }
}
