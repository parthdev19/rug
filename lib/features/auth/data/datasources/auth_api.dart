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

  /// POST /v1/app/auth/sign_in for Google social login.
  ///
  /// Returns the response map on success, throws an exception on error.
  Future<Map<String, dynamic>> socialSignIn({
    required String email,
    required String deviceId,
    required String googleAuthToken,
    double? lat,
    double? long,
  }) async {
    try {
      final payload = {
        'email': email,
        'device_id': deviceId,
        'is_social_login': true,
        'google_auth_token': googleAuthToken,
        'social_media_type': 'google',
        if (lat != null) 'lat': lat,
        if (long != null) 'long': long,
      };

      AppLogger.debug('Social Sign In payload: $payload');

      final response = await _dio.post(
        ApiConstants.appSignIn,
        data: payload,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
          extra: {'skipAuth': true},
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
