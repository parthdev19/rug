import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/services/network/dio_client.dart';

class AuthApi {
  AuthApi._();

  static final AuthApi instance = AuthApi._();

  Dio get _dio => _testDio ?? DioClient.instance;
  Dio? _testDio;

  /// Allows injecting a custom [Dio] instance during tests.
  @visibleForTesting
  set dio(Dio value) => _testDio = value;

  /// POST /v1/app/auth/sign_up for Google social login.
  ///
  /// Returns the response map on success, throws an exception on error.
  Future<Map<String, dynamic>> socialSignIn({
    required String email,
    required String deviceId,
    required String googleAuthToken,
    String? username,
    String language = 'en',
    double longitude = 0,
  }) async {
    try {
      // The backend contract is multipart/form-data, including for social
      // registration. Do not send the Google token in application/json.
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('device_id', deviceId),
        MapEntry('google_auth_token', googleAuthToken),
        const MapEntry('is_social_login', 'true'),
        MapEntry('lang', language),
        MapEntry('email', email),
        MapEntry('long', longitude.toString()),
        if (username != null && username.isNotEmpty)
          MapEntry('username', username),
      ]);

      AppLogger.debug(
        'Social sign-up request prepared for $email (Google token redacted).',
      );

      final response = await _dio.post(
        ApiConstants.appSignUp,
        data: formData,
        options: Options(
          headers: {
            'accept': 'application/json',
            Headers.contentTypeHeader: Headers.multipartFormDataContentType,
          },
        ),
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          if (data is Map<String, dynamic>) {
            return data;
          }
        }
        final message = responseData['message'] ?? 'Authentication failed';
        throw Exception(message);
      }

      throw Exception('Invalid server response format');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('message')) {
        final msg = responseData['message'];
        throw Exception(msg is List ? msg.join(', ') : msg.toString());
      }
      throw Exception(e.message ?? 'Network error occurred during sign in');
    } catch (e) {
      AppLogger.error('Social Sign In API error', error: e);
      rethrow;
    }
  }
}
