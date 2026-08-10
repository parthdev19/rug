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
}
