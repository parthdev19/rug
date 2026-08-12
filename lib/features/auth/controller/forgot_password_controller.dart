/// Controller managing the state and actions of the Forgot Password flow.
library;

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/features/auth/controller/forgot_password_state.dart';

part 'forgot_password_controller.g.dart';

@riverpod
class ForgotPasswordController extends _$ForgotPasswordController {
  Timer? _timer;

  @override
  ForgotPasswordState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const ForgotPasswordState();
  }

  /// Update email or username input.
  void updateEmailOrUsername(String value) {
    state = state.copyWith(emailOrUsername: value);
  }

  /// Update current OTP input value.
  void updateOtp(String value) {
    state = state.copyWith(otp: value);
  }

  /// Start the 60-second countdown timer.
  void startTimer() {
    _timer?.cancel();
    state = state.copyWith(countdownSeconds: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownSeconds > 0) {
        state = state.copyWith(countdownSeconds: state.countdownSeconds - 1);
      } else {
        _timer?.cancel();
      }
    });
  }

  /// Stop the countdown timer.
  void stopTimer() {
    _timer?.cancel();
  }

  /// Send forgot-password OTP to the user's email (real API call).
  Future<bool> sendOtp() async {
    final email = state.emailOrUsername.trim();
    state = state.copyWith(
      isEmailSubmitLoading: true,
      emailSubmitSuccess: false,
      emailSubmitError: null,
    );
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.forgotPassword(email: email);
      state = state.copyWith(
        isEmailSubmitLoading: false,
        emailSubmitSuccess: true,
      );
      startTimer();
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        isEmailSubmitLoading: false,
        emailSubmitError: msg,
      );
      return false;
    }
  }

  /// Resend forgot-password OTP (real API call).
  Future<bool> resendOtp() async {
    if (state.countdownSeconds > 0) return false;

    final email = state.emailOrUsername.trim();
    state = state.copyWith(isOtpVerifyLoading: true, otpVerifyError: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.forgotPassword(email: email);
      state = state.copyWith(
        isOtpVerifyLoading: false,
        otp: '',
      );
      startTimer();
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        isOtpVerifyLoading: false,
        otpVerifyError: msg,
      );
      return false;
    }
  }

  /// Verify forgot-password OTP — stores reset_token on success (real API).
  Future<bool> verifyOtpCode(String code) async {
    final email = state.emailOrUsername.trim();
    final otpInt = int.tryParse(code);

    if (otpInt == null) {
      state = state.copyWith(otpVerifyError: 'Please enter a valid OTP code.');
      return false;
    }

    state = state.copyWith(
      isOtpVerifyLoading: true,
      otpVerifySuccess: false,
      otpVerifyError: null,
    );

    try {
      final repository = ref.read(authRepositoryProvider);
      final resetToken = await repository.verifyForgotPasswordOtp(
        email: email,
        otp: otpInt,
      );
      _timer?.cancel();
      state = state.copyWith(
        isOtpVerifyLoading: false,
        otpVerifySuccess: true,
        resetToken: resetToken,
      );
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        isOtpVerifyLoading: false,
        otpVerifyError: msg,
      );
      return false;
    }
  }

  /// Reset password using the stored reset_token (real API call).
  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      state = state.copyWith(resetPasswordError: 'Passwords do not match.');
      return false;
    }

    final resetToken = state.resetToken;
    if (resetToken == null || resetToken.isEmpty) {
      state = state.copyWith(
        resetPasswordError: 'Session expired. Please restart the password reset.',
      );
      return false;
    }

    state = state.copyWith(
      isResetPasswordLoading: true,
      resetPasswordSuccess: false,
      resetPasswordError: null,
    );

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );
      state = state.copyWith(
        isResetPasswordLoading: false,
        resetPasswordSuccess: true,
      );
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        isResetPasswordLoading: false,
        resetPasswordError: msg,
      );
      return false;
    }
  }

  /// Reset state.
  void reset() {
    _timer?.cancel();
    state = const ForgotPasswordState();
  }
}
