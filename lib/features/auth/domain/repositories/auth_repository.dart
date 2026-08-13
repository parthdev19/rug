import 'package:rug/shared/models/user_model.dart';

/// Domain interface for all authentication operations.
abstract class AuthRepository {
  // ── Social & Email Auth ────────────────────────────────────────────────────

  Future<UserModel?> socialSignIn({
    required String email,
    required String googleAuthToken,
  });

  Future<UserModel?> emailSignIn({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    String? profileImagePath,
  });

  // ── OTP Flows ─────────────────────────────────────────────────────────────

  /// Verify signup OTP (4-digit code from email after registration).
  Future<void> verifyOtp({required String email, required int otp});

  /// Resend signup OTP.
  Future<void> resendOtp({required String email});

  // ── Forgot Password Flow ──────────────────────────────────────────────────

  Future<void> forgotPassword({required String email});

  /// Verify forgot-password OTP — returns a [reset_token].
  Future<String> verifyForgotPasswordOtp({
    required String email,
    required int otp,
  });

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  // ── Guest Login ───────────────────────────────────────────────────────────

  Future<UserModel?> guestLogin({
    required String username,
  });

  // ── Availability ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkAvailability({
    String? email,
    String? username,
  });

  // ── Account Conflict ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> resolveAccountConflict({
    required int currentUserId,
    required int existingUserId,
    required String email,
    required String action,
    String? deviceId,
  });

  // ── JWT-Protected ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile();

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> updateUsername({required String username});

  Future<void> logout();
}
