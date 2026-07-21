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
    String? username,
  }) async {
    final deviceId = await DeviceInfoService.instance.getDeviceId();

    final data = await _remoteDataSource.socialSignIn(
      email: email,
      deviceId: deviceId,
      googleAuthToken: googleAuthToken,
      username: username,
    );

    final userData = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    final token = (data['token'] ?? data['access_token']) as String?;
    final id = userData['id'] ?? data['user_id'];
    final responseUsername = userData['username'] as String?;
    final profile = (userData['profile'] ?? userData['avatar_url']) as String?;

    if (token != null && id != null) {
      final secureStorage = SecureStorageService.instance;
      await secureStorage.saveAccessToken(token);
      await secureStorage.saveUserId(id.toString());
      await secureStorage.setLoggedIn(true);

      return UserModel(
        id: id.toString(),
        username: responseUsername ?? username ?? '',
        email: email,
        avatarUrl: profile,
        displayName: responseUsername ?? username,
      );
    }

    return null;
  }
}
