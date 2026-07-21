/// API interceptor for authentication, token refresh, and error handling.
///
/// Automatically injects the auth token into requests, handles 401
/// responses by attempting token refresh, and logs requests.
library;

import 'package:dio/dio.dart';
import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/services/logging/app_logger.dart';

import 'package:rug/services/storage/secure_storage_service.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Inject auth token
    final token = await _getAccessToken();
    if (token != null) {
      options.headers[ApiConstants.authHeader] =
          '${ApiConstants.bearerPrefix}$token';
    }

    AppLogger.network(
      options.method,
      options.uri.toString(),
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.network(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    AppLogger.error(
      'API Error: ${err.requestOptions.uri}',
      error: err.message,
    );

    // Handle 401 — attempt token refresh
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the original request with new token
        try {
          final retryResponse = await _retry(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Refresh succeeded but retry failed
        }
      }
      // Token refresh failed — force logout
      _forceLogout();
    }

    handler.next(err);
  }

  /// Retrieves the current access token from storage.
  Future<String?> _getAccessToken() async {
    return SecureStorageService.instance.getAccessToken();
  }

  /// Attempts to refresh the auth token.
  Future<bool> _refreshToken() async {
    // TODO: Implement token refresh logic
    // 1. Get refresh token from secure storage
    // 2. Call refresh endpoint
    // 3. Store new tokens
    // 4. Return success/failure
    return false;
  }

  /// Retries a request with updated auth headers.
  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await _getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null)
          ApiConstants.authHeader: '${ApiConstants.bearerPrefix}$token',
      },
    );

    return Dio().request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Forces user logout when token refresh fails.
  void _forceLogout() {
    // TODO: Clear tokens and navigate to login
    AppLogger.warning('Session expired — forcing logout');
  }
}
