/// State class representing the registration form state.
library;

class RegisterState {
  const RegisterState({
    this.username = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.profileImagePath,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String? profileImagePath;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  RegisterState copyWith({
    String? username,
    String? email,
    String? password,
    String? confirmPassword,
    String? profileImagePath,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return RegisterState(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // We pass custom value, which could be null
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
