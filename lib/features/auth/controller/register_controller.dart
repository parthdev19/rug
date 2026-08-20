/// Controller for the registration flow, managing form data and status.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/features/auth/controller/register_state.dart';
import 'package:rug/shared/providers/common_providers.dart';

part 'register_controller.g.dart';

@Riverpod(keepAlive: true)
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

  /// Submit registration to the backend.
  ///
  /// Returns `true` on success (app should navigate to OTP verification).
  /// Returns `false` on error (errorMessage is set in state).
  Future<bool> register() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      // signUp returns raw data — does NOT create session (user must verify OTP first)
      await repository.signUp(
        username: state.username,
        email: state.email,
        password: state.password,
        profileImagePath: state.profileImagePath,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return false;
    }
  }
}
