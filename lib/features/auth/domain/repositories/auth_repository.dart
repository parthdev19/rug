import 'package:rug/shared/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> socialSignIn({
    required String email,
    required String googleAuthToken,
  });

  Future<UserModel?> emailSignIn({
    required String email,
    required String password,
  });

  Future<UserModel?> signUp({
    required String username,
    required String email,
    required String password,
    String? profileImagePath,
  });
}
