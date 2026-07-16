/// Storage key constants for Hive boxes and SharedPreferences.
///
/// Centralized keys to prevent typos and enable refactoring.
library;

class StorageKeys {
  StorageKeys._();

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String matchHistoryBox = 'match_history_box';
  static const String friendsBox = 'friends_box';

  // SharedPreferences Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
  static const String soundEnabled = 'sound_enabled';
  static const String musicEnabled = 'music_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  static const String languageCode = 'language_code';
  static const String lastSyncTimestamp = 'last_sync_timestamp';
  static const String pushNotificationToken = 'push_notification_token';
  static const String hasSentDeviceInfo = 'has_sent_device_info';
  static const String installVersion = 'install_version';
}
