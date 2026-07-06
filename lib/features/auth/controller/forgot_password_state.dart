/// State class representing the forgot password flow state.
library;

class ForgotPasswordState {
  const ForgotPasswordState({
    this.emailOrUsername = '',
    this.otp = '',
    this.countdownSeconds = 60,
    this.isEmailSubmitLoading = false,
    this.isOtpVerifyLoading = false,
    this.isResetPasswordLoading = false,
    this.emailSubmitError,
    this.otpVerifyError,
    this.resetPasswordError,
    this.emailSubmitSuccess = false,
    this.otpVerifySuccess = false,
    this.resetPasswordSuccess = false,
  });

  final String emailOrUsername;
  final String otp;
  final int countdownSeconds;
  final bool isEmailSubmitLoading;
  final bool isOtpVerifyLoading;
  final bool isResetPasswordLoading;
  final String? emailSubmitError;
  final String? otpVerifyError;
  final String? resetPasswordError;
  final bool emailSubmitSuccess;
  final bool otpVerifySuccess;
  final bool resetPasswordSuccess;

  ForgotPasswordState copyWith({
    String? emailOrUsername,
    String? otp,
    int? countdownSeconds,
    bool? isEmailSubmitLoading,
    bool? isOtpVerifyLoading,
    bool? isResetPasswordLoading,
    String? emailSubmitError,
    String? otpVerifyError,
    String? resetPasswordError,
    bool? emailSubmitSuccess,
    bool? otpVerifySuccess,
    bool? resetPasswordSuccess,
  }) {
    return ForgotPasswordState(
      emailOrUsername: emailOrUsername ?? this.emailOrUsername,
      otp: otp ?? this.otp,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      isEmailSubmitLoading: isEmailSubmitLoading ?? this.isEmailSubmitLoading,
      isOtpVerifyLoading: isOtpVerifyLoading ?? this.isOtpVerifyLoading,
      isResetPasswordLoading: isResetPasswordLoading ?? this.isResetPasswordLoading,
      emailSubmitError: emailSubmitError, // We pass custom value, which could be null
      otpVerifyError: otpVerifyError,
      resetPasswordError: resetPasswordError,
      emailSubmitSuccess: emailSubmitSuccess ?? this.emailSubmitSuccess,
      otpVerifySuccess: otpVerifySuccess ?? this.otpVerifySuccess,
      resetPasswordSuccess: resetPasswordSuccess ?? this.resetPasswordSuccess,
    );
  }
}
