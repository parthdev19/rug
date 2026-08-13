import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/features/auth/controller/forgot_password_controller.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/features/auth/domain/repositories/auth_repository.dart';
import 'package:rug/shared/models/user_model.dart';

/// Minimal stub AuthRepository for unit-testing the forgot-password controller.
class StubAuthRepository implements AuthRepository {
  /// When set to true, all calls succeed. When false, they throw.
  bool shouldSucceed = true;
  String stubResetToken = 'stub_reset_token_abc123';

  @override
  Future<void> forgotPassword({required String email}) async {
    if (!shouldSucceed) throw Exception('User not found.');
  }

  @override
  Future<String> verifyForgotPasswordOtp({
    required String email,
    required int otp,
  }) async {
    if (!shouldSucceed || otp != 1234) {
      throw Exception('Please enter a valid OTP.');
    }
    return stubResetToken;
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    if (!shouldSucceed) throw Exception('Invalid or expired password reset token.');
  }

  @override
  Future<void> resendOtp({required String email}) async {
    if (!shouldSucceed) throw Exception('User not found.');
  }

  // ── Stubs for unused methods ───────────────────────────────────────────────

  @override
  Future<UserModel?> socialSignIn({required String email, required String googleAuthToken}) async => null;

  @override
  Future<UserModel?> emailSignIn({required String email, required String password}) async => null;

  @override
  Future<Map<String, dynamic>> signUp({required String username, required String email, required String password, String? profileImagePath}) async => {};

  @override
  Future<void> verifyOtp({required String email, required int otp}) async {}

  @override
  Future<UserModel?> guestLogin({required String username}) async => null;

  @override
  Future<Map<String, dynamic>> checkAvailability({String? email, String? username}) async => {};

  @override
  Future<Map<String, dynamic>> resolveAccountConflict({required int currentUserId, required int existingUserId, required String email, required String action, String? deviceId}) async => {};

  @override
  Future<Map<String, dynamic>> getProfile() async => {};

  @override
  Future<void> changePassword({required String oldPassword, required String newPassword}) async {}

  @override
  Future<void> updateUsername({required String username}) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  group('ForgotPasswordController Tests', () {
    late ProviderContainer container;
    late StubAuthRepository stubRepo;

    setUp(() {
      stubRepo = StubAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(stubRepo),
        ],
      );
      container.listen(forgotPasswordControllerProvider, (previous, next) {});
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(forgotPasswordControllerProvider);
      expect(state.emailOrUsername, '');
      expect(state.otp, '');
      expect(state.countdownSeconds, 60);
      expect(state.isEmailSubmitLoading, false);
      expect(state.isOtpVerifyLoading, false);
      expect(state.isResetPasswordLoading, false);
      expect(state.emailSubmitSuccess, false);
      expect(state.otpVerifySuccess, false);
      expect(state.resetPasswordSuccess, false);
      expect(state.emailSubmitError, null);
      expect(state.otpVerifyError, null);
      expect(state.resetPasswordError, null);
      expect(state.resetToken, null);
    });

    test('updateEmailOrUsername updates state', () {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);
      notifier.updateEmailOrUsername('rug_player@example.com');
      final state = container.read(forgotPasswordControllerProvider);
      expect(state.emailOrUsername, 'rug_player@example.com');
    });

    test('sendOtp handles loading and success states', () async {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);
      notifier.updateEmailOrUsername('player@example.com');

      final future = notifier.sendOtp();

      // Check loading state immediately
      var state = container.read(forgotPasswordControllerProvider);
      expect(state.isEmailSubmitLoading, true);
      expect(state.emailSubmitSuccess, false);

      final success = await future;
      expect(success, true);

      state = container.read(forgotPasswordControllerProvider);
      expect(state.isEmailSubmitLoading, false);
      expect(state.emailSubmitSuccess, true);
    });

    test('sendOtp sets error on failure', () async {
      stubRepo.shouldSucceed = false;
      final notifier = container.read(forgotPasswordControllerProvider.notifier);
      notifier.updateEmailOrUsername('unknown@example.com');

      final success = await notifier.sendOtp();
      expect(success, false);

      final state = container.read(forgotPasswordControllerProvider);
      expect(state.isEmailSubmitLoading, false);
      expect(state.emailSubmitSuccess, false);
      expect(state.emailSubmitError, isNotNull);
    });

    test('verifyOtpCode rejects wrong code and accepts correct code', () async {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);
      notifier.updateEmailOrUsername('player@example.com');
      await notifier.sendOtp();

      // Wrong OTP (backend will reject anything != 1234 in stub)
      var success = await notifier.verifyOtpCode('0000');
      expect(success, false);
      var state = container.read(forgotPasswordControllerProvider);
      expect(state.isOtpVerifyLoading, false);
      expect(state.otpVerifySuccess, false);
      expect(state.otpVerifyError, isNotNull);

      // Correct OTP (1234 in stub)
      success = await notifier.verifyOtpCode('1234');
      expect(success, true);
      state = container.read(forgotPasswordControllerProvider);
      expect(state.otpVerifySuccess, true);
      expect(state.resetToken, 'stub_reset_token_abc123');
      expect(state.otpVerifyError, null);
    });

    test('resetPassword verifies match and resets successfully', () async {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);
      notifier.updateEmailOrUsername('player@example.com');
      await notifier.sendOtp();
      await notifier.verifyOtpCode('1234'); // Gets reset token

      final future = notifier.resetPassword('StrongPass123!', 'StrongPass123!');
      var state = container.read(forgotPasswordControllerProvider);
      expect(state.isResetPasswordLoading, true);

      final success = await future;
      expect(success, true);

      state = container.read(forgotPasswordControllerProvider);
      expect(state.isResetPasswordLoading, false);
      expect(state.resetPasswordSuccess, true);
      expect(state.resetPasswordError, null);
    });

    test('resetPassword fails on mismatched passwords', () async {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);

      final success = await notifier.resetPassword('StrongPass123!', 'Mismatched!');
      expect(success, false);

      final state = container.read(forgotPasswordControllerProvider);
      expect(state.resetPasswordSuccess, false);
      expect(state.resetPasswordError, 'Passwords do not match.');
    });

    test('resetPassword fails when no reset token is available', () async {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);
      // Skip sendOtp + verifyOtpCode steps, so reset_token is null

      final success = await notifier.resetPassword('StrongPass123!', 'StrongPass123!');
      expect(success, false);

      final state = container.read(forgotPasswordControllerProvider);
      expect(state.resetPasswordError, isNotNull);
    });
  });
}
