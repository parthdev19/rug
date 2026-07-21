import 'package:rug/shared/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> socialSignIn({
    required String email,
    required String googleAuthToken,
    String? username,
  });
}
