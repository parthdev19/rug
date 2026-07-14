/// Secure storage service for sensitive data (tokens, credentials).
///
/// Uses SharedPreferences as a base — can be upgraded to
/// flutter_secure_storage for production encryption.
library;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:rug/core/constants/storage_keys.dart';
import 'package:rug/services/logging/app_logger.dart';

class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // === Token Management ===

  /// Stores the access token.
  Future<void> saveAccessToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(StorageKeys.accessToken, token);
    AppLogger.debug('Access token saved');
  }

  /// Retrieves the access token.
  Future<String?> getAccessToken() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.accessToken);
  }

  /// Stores the refresh token.
  Future<void> saveRefreshToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(StorageKeys.refreshToken, token);
  }

  /// Retrieves the refresh token.
  Future<String?> getRefreshToken() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.refreshToken);
  }

  // === Session Management ===

  /// Saves the logged-in state.
  Future<void> setLoggedIn(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(StorageKeys.isLoggedIn, value);
  }

  /// Checks if the user is logged in.
  Future<bool> isLoggedIn() async {
    final prefs = await _preferences;
    return prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  /// Saves the user ID.
  Future<void> saveUserId(String userId) async {
    final prefs = await _preferences;
    await prefs.setString(StorageKeys.userId, userId);
  }

  /// Retrieves the user ID.
  Future<String?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.userId);
  }

  // === App State ===

  /// Checks if this is the first app launch.
  Future<bool> isFirstLaunch() async {
    final prefs = await _preferences;
    return prefs.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  /// Marks the first launch as complete.
  Future<void> setFirstLaunchComplete() async {
    final prefs = await _preferences;
    await prefs.setBool(StorageKeys.isFirstLaunch, false);
  }

  /// Checks if device info has been sent at least once.
  Future<bool> hasSentDeviceInfo() async {
    final prefs = await _preferences;
    return prefs.getBool(StorageKeys.hasSentDeviceInfo) ?? false;
  }

  /// Sets whether device info has been sent.
  Future<void> setSentDeviceInfo(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(StorageKeys.hasSentDeviceInfo, value);
  }

  /// Retrieves the stored install version.
  Future<String?> getInstallVersion() async {
    final prefs = await _preferences;
    return prefs.getString(StorageKeys.installVersion);
  }

  /// Saves the install version.
  Future<void> saveInstallVersion(String version) async {
    final prefs = await _preferences;
    await prefs.setString(StorageKeys.installVersion, version);
  }

  // === Cleanup ===

  /// Clears all auth-related data (for logout).
  Future<void> clearAuth() async {
    final prefs = await _preferences;
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.refreshToken);
    await prefs.remove(StorageKeys.userId);
    await prefs.setBool(StorageKeys.isLoggedIn, false);
    AppLogger.info('Auth data cleared');
  }

  /// Clears all stored data.
  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
    AppLogger.info('All secure storage cleared');
  }
}
