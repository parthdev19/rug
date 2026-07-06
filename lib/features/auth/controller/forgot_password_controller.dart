/// Controller managing the state and actions of the Forgot Password flow.
library;

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

  /// Simulate sending an OTP code.
  Future<bool> sendOtp() async {
    state = state.copyWith(
      isEmailSubmitLoading: true,
      emailSubmitSuccess: false,
    );

    try {
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 1500));
      state = state.copyWith(
        isEmailSubmitLoading: false,
        emailSubmitSuccess: true,
      );
      startTimer();
      return true;
    } catch (e) {
      state = state.copyWith(
        isEmailSubmitLoading: false,
        emailSubmitError: e.toString(),
      );
      return false;
    }
  }

  /// Simulate resending the OTP code.
  Future<bool> resendOtp() async {
    if (state.countdownSeconds > 0) {
      // Cannot resend until timer expires
      return false;
    }

    state = state.copyWith(
      isOtpVerifyLoading: true,
    );

    try {
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 1000));
      state = state.copyWith(
        isOtpVerifyLoading: false,
        otp: '', // Clear previous code input
      );
      startTimer();
      return true;
    } catch (e) {
      state = state.copyWith(
        isOtpVerifyLoading: false,
        otpVerifyError: 'Failed to resend code. Please try again.',
      );
      return false;
    }
  }

  /// Verify the entered 6-digit OTP code.
  Future<bool> verifyOtpCode(String code) async {
    state = state.copyWith(
      isOtpVerifyLoading: true,
      otpVerifySuccess: false,
    );

    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Validation: Mock code is "123456". Check if timer expired.
      if (state.countdownSeconds == 0) {
        state = state.copyWith(
          isOtpVerifyLoading: false,
          otpVerifyError: 'Verification code has expired. Please request a new one.',
        );
        return false;
      }

      if (code == '123456') {
        _timer?.cancel();
        state = state.copyWith(
          isOtpVerifyLoading: false,
          otpVerifySuccess: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isOtpVerifyLoading: false,
          otpVerifyError: 'Invalid verification code. Please check and try again.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isOtpVerifyLoading: false,
        otpVerifyError: e.toString(),
      );
      return false;
    }
  }

  /// Simulate updating password.
  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    state = state.copyWith(
      isResetPasswordLoading: true,
      resetPasswordSuccess: false,
    );

    try {
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Simple validation checks (though should be captured by form state validation)
      if (newPassword.length < 8) {
        state = state.copyWith(
          isResetPasswordLoading: false,
          resetPasswordError: 'Password must be at least 8 characters.',
        );
        return false;
      }

      if (newPassword != confirmPassword) {
        state = state.copyWith(
          isResetPasswordLoading: false,
          resetPasswordError: 'Passwords do not match.',
        );
        return false;
      }

      state = state.copyWith(
        isResetPasswordLoading: false,
        resetPasswordSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isResetPasswordLoading: false,
        resetPasswordError: e.toString(),
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
