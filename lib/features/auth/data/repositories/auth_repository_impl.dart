import 'package:rug/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rug/features/auth/domain/repositories/auth_repository.dart';
import 'package:rug/services/device/device_info_service.dart';
import 'package:rug/services/storage/secure_storage_service.dart';
import 'package:rug/shared/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UserModel?> socialSignIn({
    required String email,
    required String googleAuthToken,
  }) async {
    final deviceId = await DeviceInfoService.instance.getDeviceId();

    final data = await _remoteDataSource.socialSignIn(
      email: email,
      deviceId: deviceId,
      googleAuthToken: googleAuthToken,
    );

    return _saveSessionAndCreateUser(data: data, fallbackEmail: email);
  }

  @override
  Future<UserModel?> emailSignIn({
    required String email,
    required String password,
  }) async {
    final deviceId = await DeviceInfoService.instance.getDeviceId();

    final data = await _remoteDataSource.emailSignIn(
      email: email,
      password: password,
      deviceId: deviceId,
    );

    return _saveSessionAndCreateUser(data: data, fallbackEmail: email);
  }

  @override
  Future<UserModel?> signUp({
    required String username,
    required String email,
    required String password,
    String? profileImagePath,
  }) async {
    final deviceId = await DeviceInfoService.instance.getDeviceId();

    final data = await _remoteDataSource.signUp(
      username: username,
      email: email,
      password: password,
      deviceId: deviceId,
      profileImagePath: profileImagePath,
    );

    return _saveSessionAndCreateUser(
      data: data,
      fallbackEmail: email,
      fallbackUsername: username,
    );
  }

  Future<UserModel?> _saveSessionAndCreateUser({
    required Map<String, dynamic> data,
    required String fallbackEmail,
    String? fallbackUsername,
  }) async {
    final userData = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    final token = (data['token'] ?? data['access_token']) as String?;
    final id = userData['id'] ?? data['user_id'];
    final responseUsername = userData['username'] as String?;
    final profile = (userData['profile'] ?? userData['avatar_url']) as String?;
    final userEmail = (userData['email'] as String?) ?? fallbackEmail;

    if (token != null && id != null) {
      final secureStorage = SecureStorageService.instance;
      await secureStorage.saveAccessToken(token);
      await secureStorage.saveUserId(id.toString());
      await secureStorage.setLoggedIn(true);

      final finalUsername = responseUsername ?? fallbackUsername ?? '';

      return UserModel(
        id: id.toString(),
        username: finalUsername,
        email: userEmail,
        avatarUrl: profile,
        displayName: finalUsername.isNotEmpty ? finalUsername : null,
      );
    }

    return null;
  }
}
