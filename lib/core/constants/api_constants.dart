/// API-related constants for networking configuration.
///
/// Base URLs, endpoint paths, and header keys.
library;

class ApiConstants {
  ApiConstants._();

  // Base URLs — overridden per environment via EnvConfig
  static const String devBaseUrl = 'https://g66p29zh-1902.inc1.devtunnels.ms';
  static const String stagingBaseUrl = 'https://staging-api.rug.game';
  static const String prodBaseUrl = 'https://api.rug.game';

  // WebSocket URLs
  static const String devWsUrl = 'wss://dev-ws.rug.game';
  static const String stagingWsUrl = 'wss://staging-ws.rug.game';
  static const String prodWsUrl = 'wss://ws.rug.game';

  // API Versioning
  static const String apiVersion = '/api/v1';

  // Auth Endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String deviceInfo = '/v1/app/auth/device-info';
  static const String screenInfo = '/v1/app/auth/screen-info';
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
