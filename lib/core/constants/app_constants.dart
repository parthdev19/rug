/// App-wide constants for the RUG card game.
///
/// Centralized location for magic values used across the application.
library;

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'RUG';
  static const String appTagline = 'The Three of Clubs';
  static const String appVersion = '1.0.0';

  // Game Constants
  static const int maxPlayersPerTable = 6;
  static const int minPlayersPerTable = 2;
  static const int standardDeckSize = 52;
  static const int cardsPerSuit = 13;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration webSocketReconnectDelay = Duration(seconds: 3);
  static const Duration turnTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int leaderboardPageSize = 50;

  // Cache
  static const Duration cacheTTL = Duration(hours: 1);
  static const int maxCacheSize = 100;

  // Animation
  static const Duration splashDuration = Duration(seconds: 3);
}
