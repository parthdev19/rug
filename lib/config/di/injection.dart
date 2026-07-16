/// Dependency injection setup.
///
/// Initializes all services and registers them for app-wide access.
/// Called once during app startup from [main.dart].
library;

import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rug/config/env/env_config.dart';
import 'package:rug/services/device/device_info_service.dart';
import 'package:rug/services/logging/app_logger.dart';

/// Initializes all app-level dependencies.
///
/// Must be called before [runApp] in [main.dart].
Future<void> initializeDependencies() async {
  // 1. Resolve environment
  final flavor = EnvConfig.resolveFlavor();
  EnvConfig.init(flavor);

  // 2. Initialize logger
  AppLogger.init(enableLogging: EnvConfig.instance.enableLogging);
  AppLogger.info('Initializing RUG [${EnvConfig.instance.flavor.name}]');

  // 3. Initialize Hive for local storage
  await Hive.initFlutter();
  AppLogger.info('Hive initialized');

  // 4. Initialize SharedPreferences
  await SharedPreferences.getInstance();
  AppLogger.info('SharedPreferences initialized');

  // 5. Initialize Firebase (guarded — won't crash without config)
  await _initFirebase();

  // 6. Submit device info asynchronously (non-blocking)
  unawaited(DeviceInfoService.instance.sendDeviceInfo());

  AppLogger.info('All dependencies initialized successfully');
}

Future<void> _initFirebase() async {
  try {
    // TODO: Uncomment after running `flutterfire configure`
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    // AppLogger.info('Firebase initialized');
  } catch (e) {
    AppLogger.warning('Firebase initialization skipped: $e');
  }
}
