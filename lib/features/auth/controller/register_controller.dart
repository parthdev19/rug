/// Controller for the registration flow, managing form data and status.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/auth/controller/register_state.dart';

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

  /// Trigger simulated registration API request.
  Future<bool> register() async {
    state = RegisterState(
      username: state.username,
      email: state.email,
      password: state.password,
      confirmPassword: state.confirmPassword,
      profileImagePath: state.profileImagePath,
      isLoading: true,
    );

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 2000));
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
