/// Named route constants.
///
/// Centralized path definitions to prevent typos and enable refactoring.
library;

class RouteNames {
  RouteNames._();

  // Core
  static const String splash = '/';
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String guestUsername = '/auth/guest-username';

  // Main
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Game
  static const String createGame = '/create-game';
  static const String gameTable = '/game-table';
  static const String gameLobby = '/game-lobby';
  static const String privateRoom = '/private-room';
  static const String multiplayerTable = '/multiplayer-table';
  static const String onlineMatch = '/online-match';

  // Social
  static const String friends = '/friends';
  static const String leaderboard = '/leaderboard';

  // Economy
  static const String rewards = '/rewards';
  static const String wallet = '/wallet';

  // Notifications
  static const String notifications = '/notifications';
}
