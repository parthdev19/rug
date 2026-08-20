/// Controller for the post-registration OTP verification flow.
///
/// After a user registers with email/password, they receive a 4-digit OTP
/// to verify their email before they can log in.
library;

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/features/auth/controller/register_controller.dart';
import 'package:rug/services/logging/app_logger.dart';

part 'sign_up_otp_controller.g.dart';

class SignUpOtpState {
  const SignUpOtpState({
    this.isVerifyLoading = false,
    this.isResendLoading = false,
    this.countdownSeconds = 60,
    this.verifyError,
    this.resendError,
    this.isVerifySuccess = false,
  });

  final bool isVerifyLoading;
  final bool isResendLoading;
  final int countdownSeconds;
  final String? verifyError;
  final String? resendError;
  final bool isVerifySuccess;

  SignUpOtpState copyWith({
    bool? isVerifyLoading,
    bool? isResendLoading,
    int? countdownSeconds,
    String? verifyError,
    String? resendError,
    bool? isVerifySuccess,
  }) {
    return SignUpOtpState(
      isVerifyLoading: isVerifyLoading ?? this.isVerifyLoading,
      isResendLoading: isResendLoading ?? this.isResendLoading,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      verifyError: verifyError,
      resendError: resendError,
      isVerifySuccess: isVerifySuccess ?? this.isVerifySuccess,
    );
  }
}
@Riverpod(keepAlive: true)
class SignUpOtpController extends _$SignUpOtpController {
  Timer? _timer;

  @override
  SignUpOtpState build() {
    ref.onDispose(() => _timer?.cancel());
    return const SignUpOtpState();
  }

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

  /// Verify the signup OTP — 4-digit code sent after registration.
  Future<bool> verifyOtp({
    required String email,
    required String code,
    String? password,
  }) async {
    final otpInt = int.tryParse(code);
    if (otpInt == null) {
      state = state.copyWith(verifyError: 'Please enter a valid 4-digit code.');
      return false;
    }

    state = state.copyWith(
      isVerifyLoading: true,
      verifyError: null,
      isVerifySuccess: false,
    );

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.verifyOtp(email: email, otp: otpInt);
      _timer?.cancel();

      // Retrieve registered password if not explicitly passed
      final userPassword =
          password ?? ref.read(registerControllerProvider).password;

      if (userPassword.isNotEmpty) {
        // Authenticate user and persist session & token in SecureStorageService
        await ref.read(authControllerProvider.notifier).signInWithEmail(
              email: email,
              password: userPassword,
            );
      }

      if (ref.mounted) {
        state = state.copyWith(isVerifyLoading: false, isVerifySuccess: true);
      }
      return true;
    } catch (e) {
      AppLogger.error('SignUp OTP verify error', error: e);
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (ref.mounted) {
        state = state.copyWith(isVerifyLoading: false, verifyError: msg);
      }
      return false;
    }
  }

  /// Resend signup OTP to the given email.
  Future<bool> resendOtp({required String email}) async {
    if (state.countdownSeconds > 0) return false;

    state = state.copyWith(isResendLoading: true, resendError: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resendOtp(email: email);
      state = state.copyWith(isResendLoading: false);
      startTimer();
      return true;
    } catch (e) {
      AppLogger.error('SignUp OTP resend error', error: e);
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isResendLoading: false, resendError: msg);
      return false;
    }
  }

  void reset() {
    _timer?.cancel();
    state = const SignUpOtpState();
  }
}
