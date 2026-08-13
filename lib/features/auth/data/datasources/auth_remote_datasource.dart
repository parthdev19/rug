import 'package:rug/features/auth/data/datasources/auth_api.dart';

/// Thin pass-through layer between repository and AuthApi.
class AuthRemoteDataSource {
  // ── Public endpoints ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> socialSignIn({
    required String email,
    required String deviceId,
    required String googleAuthToken,
    double? lat,
    double? long,
  }) =>
      AuthApi.instance.socialSignIn(
        email: email,
        deviceId: deviceId,
        googleAuthToken: googleAuthToken,
        lat: lat,
        long: long,
      );

  Future<Map<String, dynamic>> emailSignIn({
    required String email,
    required String password,
    required String deviceId,
    double? lat,
    double? long,
  }) =>
      AuthApi.instance.emailSignIn(
        email: email,
        password: password,
        deviceId: deviceId,
        lat: lat,
        long: long,
      );

  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    required String deviceId,
    String? profileImagePath,
    double? lat,
    double? long,
  }) =>
      AuthApi.instance.signUp(
        username: username,
        email: email,
        password: password,
        deviceId: deviceId,
        profileImagePath: profileImagePath,
        lat: lat,
        long: long,
      );

  Future<void> verifyOtp({required String email, required int otp}) =>
      AuthApi.instance.verifyOtp(email: email, otp: otp);

  Future<void> resendOtp({required String email}) =>
      AuthApi.instance.resendOtp(email: email);

  Future<void> forgotPassword({required String email}) =>
      AuthApi.instance.forgotPassword(email: email);

  Future<String> verifyForgotPasswordOtp({
    required String email,
    required int otp,
  }) =>
      AuthApi.instance.verifyForgotPasswordOtp(email: email, otp: otp);

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) =>
      AuthApi.instance.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );

  Future<Map<String, dynamic>> guestLogin({
    required String deviceId,
    required String username,
    double? lat,
    double? long,
  }) =>
      AuthApi.instance.guestLogin(
        deviceId: deviceId,
        username: username,
        lat: lat,
        long: long,
      );

  Future<Map<String, dynamic>> checkAvailability({
    String? email,
    String? username,
  }) =>
      AuthApi.instance.checkAvailability(email: email, username: username);

  Future<Map<String, dynamic>> resolveAccountConflict({
    required int currentUserId,
    required int existingUserId,
    required String email,
    required String action,
    String? deviceId,
  }) =>
      AuthApi.instance.resolveAccountConflict(
        currentUserId: currentUserId,
        existingUserId: existingUserId,
        email: email,
        action: action,
        deviceId: deviceId,
      );

  // ── JWT-Protected endpoints ────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() =>
      AuthApi.instance.getProfile();

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      AuthApi.instance.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

  Future<void> updateUsername({required String username}) =>
      AuthApi.instance.updateUsername(username: username);

  Future<void> logout() => AuthApi.instance.logout();
}
