/// Controller for the registration flow, managing form data and status.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/features/auth/controller/register_state.dart';
import 'package:rug/shared/providers/common_providers.dart';

part 'register_controller.g.dart';

@riverpod
class RegisterController extends _$RegisterController {
  @override
  RegisterState build() => const RegisterState();

  /// Update the current username.
  void updateUsername(String username) {
    state = state.copyWith(username: username);
  }

  /// Update the current email.
  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  /// Update the current password.
  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  /// Update the confirm password.
  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  /// Update the selected profile image path.
  void updateProfileImagePath(String? path) {
    state = state.copyWith(profileImagePath: path);
  }

  /// Reset the registration state.
  void reset() {
    state = const RegisterState();
  }

  /// Trigger registration API request.
  Future<bool> register() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signUp(
        username: state.username,
        email: state.email,
        password: state.password,
        profileImagePath: state.profileImagePath,
      );

      if (user != null) {
        ref.read(currentUserProvider.notifier).setUser(user);
        ref.read(currentUserIdProvider.notifier).setUserId(user.id);
        ref.read(isAuthenticatedProvider.notifier).setAuthenticated(true);
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      }

      throw Exception('Registration response was invalid.');
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return false;
    }
  }
}
