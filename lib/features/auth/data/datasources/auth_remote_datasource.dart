import 'package:rug/features/auth/data/datasources/auth_api.dart';

class AuthRemoteDataSource {
  Future<Map<String, dynamic>> socialSignIn({
    required String email,
    required String deviceId,
    required String googleAuthToken,
    double? lat,
    double? long,
  }) async {
    return AuthApi.instance.socialSignIn(
      email: email,
      deviceId: deviceId,
      googleAuthToken: googleAuthToken,
      lat: lat,
      long: long,
    );
  }

  Future<Map<String, dynamic>> emailSignIn({
    required String email,
    required String password,
    required String deviceId,
    double? lat,
    double? long,
  }) async {
    return AuthApi.instance.emailSignIn(
      email: email,
      password: password,
      deviceId: deviceId,
      lat: lat,
      long: long,
    );
  }

  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    required String deviceId,
    String? profileImagePath,
    double? lat,
    double? long,
  }) async {
    return AuthApi.instance.signUp(
      username: username,
      email: email,
      password: password,
      deviceId: deviceId,
      profileImagePath: profileImagePath,
      lat: lat,
      long: long,
    );
  }
}
