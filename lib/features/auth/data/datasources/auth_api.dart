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

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  Options _publicJson() => Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        extra: {'skipAuth': true},
      );

  Options _authJson() => Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

  Map<String, dynamic> _parseSuccess(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['success'] == true) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) return data;
        // Some endpoints return data: null — return empty map
        return {};
      }
      final message = responseData['message'] ?? 'Request failed';
      throw Exception(message);
    }
    throw Exception('Invalid server response format');
  }

  Exception _parseDioError(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('message')) {
      final msg = responseData['message'];
      return Exception(msg is List ? msg.join(', ') : msg.toString());
    }
    return Exception(e.message ?? 'Network error');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Public Endpoints
  // ──────────────────────────────────────────────────────────────────────────

  /// POST /v1/app/auth/sign_in — Google social login.
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
        options: _publicJson(),
      );
      return _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Social Sign In API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/sign_in — Email/password login.
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
        options: _publicJson(),
      );
      return _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Email Sign In API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/sign_up — Normal user registration (multipart).
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
      return _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Sign Up API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/verify_otp — Verify OTP after sign_up.
  Future<void> verifyOtp({
    required String email,
    required int otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.appVerifyOtp,
        data: {'email': email, 'otp': otp},
        options: _publicJson(),
      );
      _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Verify OTP API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/resend_otp — Resend OTP to email.
  Future<void> resendOtp({required String email}) async {
    try {
      final response = await _dio.post(
        ApiConstants.appResendOtp,
        data: {'email': email},
        options: _publicJson(),
      );
      _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Resend OTP API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/forgot_password — Send forgot password OTP.
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        ApiConstants.appForgotPassword,
        data: {'email': email},
        options: _publicJson(),
      );
      _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Forgot Password API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/verify_forgot_password_otp — Returns reset_token.
  Future<String> verifyForgotPasswordOtp({
    required String email,
    required int otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.appVerifyForgotPasswordOtp,
        data: {'email': email, 'otp': otp},
        options: _publicJson(),
      );
      final data = _parseSuccess(response.data);
      final token = data['reset_token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('No reset token returned from server');
      }
      return token;
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Verify Forgot Password OTP API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/reset_password — Reset password using reset_token.
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.appResetPassword,
        data: {'reset_token': resetToken, 'new_password': newPassword},
        options: _publicJson(),
      );
      _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Reset Password API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/guest_login — Login as a guest user.
  Future<Map<String, dynamic>> guestLogin({
    required String deviceId,
    required String username,
    double? lat,
    double? long,
  }) async {
    try {
      final payload = {
        'device_id': deviceId,
        'username': username,
        if (lat != null) 'lat': lat,
        if (long != null) 'long': long,
      };
      AppLogger.debug('Guest Login request for username: $username');
      final response = await _dio.post(
        ApiConstants.appGuestLogin,
        data: payload,
        options: _publicJson(),
      );
      return _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Guest Login API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/check_availability — Check email/username availability.
  Future<Map<String, dynamic>> checkAvailability({
    String? email,
    String? username,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (email != null) payload['email'] = email;
      if (username != null) payload['username'] = username;
      final response = await _dio.post(
        ApiConstants.appCheckAvailability,
        data: payload,
        options: _publicJson(),
      );
      return _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Check Availability API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/resolve-account-conflict — Resolve guest/existing account conflict.
  Future<Map<String, dynamic>> resolveAccountConflict({
    required int currentUserId,
    required int existingUserId,
    required String email,
    required String action, // 'OLD_DATA' | 'CURRENT_DATA'
    String? deviceId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'current_user_id': currentUserId,
        'existing_user_id': existingUserId,
        'email': email,
        'action': action,
        if (deviceId != null) 'device_id': deviceId,
      };
      final response = await _dio.post(
        ApiConstants.appResolveAccountConflict,
        data: payload,
        options: _publicJson(),
      );
      return _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Resolve Account Conflict API error', error: e);
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // JWT-Protected Endpoints
  // ──────────────────────────────────────────────────────────────────────────

  /// GET /v1/app/auth/get_profile — Fetch authenticated user profile.
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get(
        ApiConstants.appGetProfile,
        options: _authJson(),
      );
      return _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Get Profile API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/change_password — Change password for authenticated user.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.appChangePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
        options: _authJson(),
      );
      _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Change Password API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/update_username — Update username for authenticated user.
  Future<void> updateUsername({required String username}) async {
    try {
      final response = await _dio.post(
        ApiConstants.appUpdateUsername,
        data: {'username': username},
        options: _authJson(),
      );
      _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Update Username API error', error: e);
      rethrow;
    }
  }

  /// POST /v1/app/auth/logout — Logout authenticated user (invalidates token).
  Future<void> logout() async {
    try {
      final response = await _dio.post(
        ApiConstants.appLogout,
        options: _authJson(),
      );
      _parseSuccess(response.data);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      AppLogger.error('Logout API error', error: e);
      rethrow;
    }
  }
}
