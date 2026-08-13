/// API-related constants for networking configuration.
///
/// Base URLs, endpoint paths, and header keys.
library;

class ApiConstants {
  ApiConstants._();

  // Base URLs — overridden per environment via EnvConfig
  static const String devBaseUrl = 'https://rbzv2l7n-1902.inc1.devtunnels.ms';
  static const String stagingBaseUrl = 'https://staging-api.rug.game';
  static const String prodBaseUrl = 'https://api.rug.game';

  // WebSocket URLs
  static const String devWsUrl = 'wss://dev-ws.rug.game';
  static const String stagingWsUrl = 'wss://staging-ws.rug.game';
  static const String prodWsUrl = 'wss://ws.rug.game';

  // API Versioning
  static const String apiVersion = '/api/v1';

  // Auth Endpoints — Public
  static const String deviceInfo = '/v1/app/auth/device-info';
  static const String screenInfo = '/v1/app/auth/screen-info';
  static const String appSignIn = '/v1/app/auth/sign_in';
  static const String appSignUp = '/v1/app/auth/sign_up';
  static const String appCheckAvailability = '/v1/app/auth/check_availability';
  static const String appVerifyOtp = '/v1/app/auth/verify_otp';
  static const String appResendOtp = '/v1/app/auth/resend_otp';
  static const String appForgotPassword = '/v1/app/auth/forgot_password';
  static const String appVerifyForgotPasswordOtp =
      '/v1/app/auth/verify_forgot_password_otp';
  static const String appResetPassword = '/v1/app/auth/reset_password';
  static const String appGuestLogin = '/v1/app/auth/guest_login';
  static const String appResolveAccountConflict =
      '/v1/app/auth/resolve-account-conflict';

  // Auth Endpoints — JWT Protected
  static const String appGetProfile = '/v1/app/auth/get_profile';
  static const String appChangePassword = '/v1/app/auth/change_password';
  static const String appUpdateUsername = '/v1/app/auth/update_username';
  static const String appLogout = '/v1/app/auth/logout';

  // Legacy (kept for compatibility)
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';

  // User Endpoints
  static const String profile = '$apiVersion/user/profile';
  static const String updateProfile = '$apiVersion/user/profile';
  static const String friends = '$apiVersion/user/friends';

  // Game Endpoints
  static const String createRoom = '$apiVersion/game/room/create';
  static const String joinRoom = '$apiVersion/game/room/join';
  static const String leaveRoom = '$apiVersion/game/room/leave';
  static const String matchHistory = '$apiVersion/game/history';

  // Leaderboard
  static const String leaderboard = '$apiVersion/leaderboard';

  // Wallet
  static const String walletBalance = '$apiVersion/wallet/balance';
  static const String walletTransactions = '$apiVersion/wallet/transactions';

  // Rewards
  static const String rewards = '$apiVersion/rewards';
  static const String claimReward = '$apiVersion/rewards/claim';

  // Headers
  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
}
