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

  /// POST /v1/app/auth/sign_in for normal email/password login.
  ///
  /// Returns the response map on success, throws an exception on error.
  Future<Map<String, dynamic>> emailSignIn({
    required String email,
    required String password,
    required String deviceId,
    double? lat,
    double? long,
  }) async {
    try {
      final payload = {
        'email': email,
        'password': password,
        'device_id': deviceId,
        'is_social_login': false,
        if (lat != null) 'lat': lat,
        if (long != null) 'long': long,
      };

      AppLogger.debug('Email Sign In request for $email');

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
      AppLogger.error('Email Sign In API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/sign_up for normal user registration.
  ///
  /// Returns the response map on success, throws an exception on error.
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    required String deviceId,
    String? profileImagePath,
    double? lat,
    double? long,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('username', username),
        MapEntry('email', email),
        MapEntry('password', password),
        MapEntry('device_id', deviceId),
        const MapEntry('is_social_login', 'false'),
        const MapEntry('lang', 'en'),
        if (lat != null) MapEntry('lat', lat.toString()),
        if (long != null) MapEntry('long', long.toString()),
      ]);

      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        final file = await MultipartFile.fromFile(
          profileImagePath,
          filename: profileImagePath.split('/').last,
        );
        formData.files.add(MapEntry('profile', file));
      }

      AppLogger.debug('Sign Up request for $email');

      final response = await _dio.post(
        ApiConstants.appSignUp,
        data: formData,
        options: Options(
          headers: {
            'accept': 'application/json',
            Headers.contentTypeHeader: Headers.multipartFormDataContentType,
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
        final message = responseData['message'] ?? 'Registration failed';
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
      throw Exception(e.message ?? 'Network error occurred during registration');
    } catch (e) {
      AppLogger.error('Sign Up API error', error: e);
      rethrow;
    }
  }
}
