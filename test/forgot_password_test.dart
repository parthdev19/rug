import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/features/auth/controller/forgot_password_controller.dart';

void main() {
  group('ForgotPasswordController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.listen(
        forgotPasswordControllerProvider,
        (previous, next) {},
      );
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
    });

    test('updateEmailOrUsername updates state', () {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);
      notifier.updateEmailOrUsername('rug_player');

      final state = container.read(forgotPasswordControllerProvider);
      expect(state.emailOrUsername, 'rug_player');
    });

    test('sendOtp handles loading and success states', () async {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);
      final future = notifier.sendOtp();

      // Check loading state immediately
      var state = container.read(forgotPasswordControllerProvider);
      expect(state.isEmailSubmitLoading, true);
      expect(state.emailSubmitSuccess, false);

      final success = await future;
      expect(success, true);

      // Check success state
      state = container.read(forgotPasswordControllerProvider);
      expect(state.isEmailSubmitLoading, false);
      expect(state.emailSubmitSuccess, true);
      expect(state.countdownSeconds, 60);
    });

    test('verifyOtpCode rejects wrong code and accepts correct code', () async {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);
      
      // Send OTP first to start timer
      await notifier.sendOtp();

      // Verify incorrect OTP
      var verifyFuture = notifier.verifyOtpCode('000000');
      var state = container.read(forgotPasswordControllerProvider);
      expect(state.isOtpVerifyLoading, true);

      var success = await verifyFuture;
      expect(success, false);

      state = container.read(forgotPasswordControllerProvider);
      expect(state.isOtpVerifyLoading, false);
      expect(state.otpVerifySuccess, false);
      expect(state.otpVerifyError, 'Invalid verification code. Please check and try again.');

      // Verify correct OTP
      verifyFuture = notifier.verifyOtpCode('123456');
      success = await verifyFuture;
      expect(success, true);

      state = container.read(forgotPasswordControllerProvider);
      expect(state.otpVerifySuccess, true);
      expect(state.otpVerifyError, null);
    });

    test('resetPassword verifies match and resets successfully', () async {
      final notifier = container.read(forgotPasswordControllerProvider.notifier);

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
  });
}
