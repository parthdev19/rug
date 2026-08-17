import 'package:rug/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rug/features/auth/domain/repositories/auth_repository.dart';
import 'package:rug/services/device/device_info_service.dart';
import 'package:rug/services/storage/secure_storage_service.dart';
import 'package:rug/shared/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _remoteDataSource;

  // ── Internal helpers ───────────────────────────────────────────────────────

  Future<String> get _deviceId => DeviceInfoService.instance.getDeviceId();

  Future<UserModel?> _saveSessionAndBuildUser({
    required Map<String, dynamic> data,
    required String fallbackEmail,
    String? fallbackUsername,
  }) async {
    final userData = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    final token = (data['token'] ?? data['access_token'] ?? userData['token']) as String?;
    final id = userData['id'] ?? data['user_id'] ?? data['id'];
    final rawResponseUsername = userData['username'] ?? data['username'];
    final responseUsernameStr = rawResponseUsername is String ? rawResponseUsername : null;
    final profile = (userData['profile'] ?? userData['avatar_url'] ?? userData['profile_url'] ?? data['profile_url']) as String?;
    final userEmail = (userData['email'] as String?) ?? fallbackEmail;

    if (token != null && id != null) {
      final secure = SecureStorageService.instance;
      await secure.saveAccessToken(token);
      await secure.saveUserId(id.toString());
      await secure.setLoggedIn(true);

      // is_username_set can sit at top-level OR inside the user object.
      final rawIsUsernameSet = data['is_username_set'] ??
          userData['is_username_set'] ??
          data['isUsernameSet'] ??
          userData['isUsernameSet'];

      final finalUsername = responseUsernameStr ?? fallbackUsername ?? '';
      final isUsernameSet = UserModel.parseIsUsernameSet(
        rawIsUsernameSet,
        rawResponseUsername,
      );

      return UserModel(
        id: id.toString(),
        username: finalUsername,
        email: userEmail,
        avatarUrl: profile,
        displayName: finalUsername.isNotEmpty ? finalUsername : null,
        isUsernameSet: isUsernameSet,
      );
    }
    return null;
  }

  // ── Social & Email Auth ────────────────────────────────────────────────────

  @override
  Future<UserModel?> socialSignIn({
    required String email,
    required String googleAuthToken,
  }) async {
    final deviceId = await _deviceId;
    final data = await _remoteDataSource.socialSignIn(
      email: email,
      deviceId: deviceId,
      googleAuthToken: googleAuthToken,
    );
    return _saveSessionAndBuildUser(data: data, fallbackEmail: email);
  }

  @override
  Future<UserModel?> emailSignIn({
    required String email,
    required String password,
  }) async {
    final deviceId = await _deviceId;
    final data = await _remoteDataSource.emailSignIn(
      email: email,
      password: password,
      deviceId: deviceId,
    );
    return _saveSessionAndBuildUser(data: data, fallbackEmail: email);
  }

  @override
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    String? profileImagePath,
  }) async {
    final deviceId = await _deviceId;
    return _remoteDataSource.signUp(
      username: username,
      email: email,
      password: password,
      deviceId: deviceId,
      profileImagePath: profileImagePath,
    );
  }

  // ── OTP Flows ─────────────────────────────────────────────────────────────

  @override
  Future<void> verifyOtp({required String email, required int otp}) =>
      _remoteDataSource.verifyOtp(email: email, otp: otp);

  @override
  Future<void> resendOtp({required String email}) =>
      _remoteDataSource.resendOtp(email: email);

  // ── Forgot Password Flow ──────────────────────────────────────────────────

  @override
  Future<void> forgotPassword({required String email}) =>
      _remoteDataSource.forgotPassword(email: email);

  @override
  Future<String> verifyForgotPasswordOtp({
    required String email,
    required int otp,
  }) =>
      _remoteDataSource.verifyForgotPasswordOtp(email: email, otp: otp);

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) =>
      _remoteDataSource.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );

  // ── Guest Login ───────────────────────────────────────────────────────────

  @override
  Future<UserModel?> guestLogin({required String username}) async {
    final deviceId = await _deviceId;
    final data = await _remoteDataSource.guestLogin(
      deviceId: deviceId,
      username: username,
    );
    // Guest login returns token but no email — use empty fallback
    return _saveSessionAndBuildUser(
      data: data,
      fallbackEmail: '',
      fallbackUsername: username,
    );
  }

  // ── Availability ──────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> checkAvailability({
    String? email,
    String? username,
  }) =>
      _remoteDataSource.checkAvailability(email: email, username: username);

  // ── Account Conflict ──────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> resolveAccountConflict({
    required int currentUserId,
    required int existingUserId,
    required String email,
    required String action,
    String? deviceId,
  }) =>
      _remoteDataSource.resolveAccountConflict(
        currentUserId: currentUserId,
        existingUserId: existingUserId,
        email: email,
        action: action,
        deviceId: deviceId,
      );

  // ── JWT-Protected ─────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getProfile() =>
      _remoteDataSource.getProfile();

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      _remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

  @override
  Future<void> updateUsername({required String username}) =>
      _remoteDataSource.updateUsername(username: username);

  @override
  Future<void> logout() async {
    // Fire API logout (best-effort — don't fail locally if network is down)
    await _remoteDataSource.logout().catchError((_) {});
    // Always clear local session
    final secure = SecureStorageService.instance;
    await secure.clearAuth();
  }
}
