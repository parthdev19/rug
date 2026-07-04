/// Local storage service wrapping Hive.
///
/// Provides typed get/set operations with box management
/// for offline caching and local data persistence.
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:rug/core/constants/storage_keys.dart';
import 'package:rug/services/logging/app_logger.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  /// Opens a Hive box (creates if not exists).
  Future<Box<T>> _openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return Hive.openBox<T>(boxName);
  }

  /// Saves a value to the specified box.
  Future<void> put<T>({
    required String boxName,
    required String key,
    required T value,
  }) async {
    try {
      final box = await _openBox<T>(boxName);
      await box.put(key, value);
    } catch (e) {
      AppLogger.error('LocalStorage put error [$boxName/$key]', error: e);
      rethrow;
    }
  }

  /// Retrieves a value from the specified box.
  Future<T?> get<T>({
    required String boxName,
    required String key,
  }) async {
    try {
      final box = await _openBox<T>(boxName);
      return box.get(key);
    } catch (e) {
      AppLogger.error('LocalStorage get error [$boxName/$key]', error: e);
      return null;
    }
  }

  /// Deletes a value from the specified box.
  Future<void> delete({
    required String boxName,
    required String key,
  }) async {
    try {
      final box = await _openBox(boxName);
      await box.delete(key);
    } catch (e) {
      AppLogger.error('LocalStorage delete error [$boxName/$key]', error: e);
    }
  }

  /// Clears all data from a specific box.
  Future<void> clearBox(String boxName) async {
    try {
      final box = await _openBox(boxName);
      await box.clear();
      AppLogger.info('Cleared box: $boxName');
    } catch (e) {
      AppLogger.error('LocalStorage clearBox error [$boxName]', error: e);
    }
  }

  /// Clears all app storage (for logout).
  Future<void> clearAll() async {
    await clearBox(StorageKeys.userBox);
    await clearBox(StorageKeys.cacheBox);
    await clearBox(StorageKeys.matchHistoryBox);
    await clearBox(StorageKeys.friendsBox);
    // Keep settings box — user preferences survive logout
    AppLogger.info('All storage cleared');
  }
}
