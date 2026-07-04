/// RUG — Entry point.
///
/// Initializes all dependencies and launches the app
/// with Riverpod's ProviderScope.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/app.dart';
import 'package:rug/config/di/injection.dart';
import 'package:rug/core/errors/error_handler.dart';
import 'package:rug/services/logging/app_logger.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Lock orientation to portrait (game will handle landscape for table)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF0D1117),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Initialize all dependencies
      await initializeDependencies();

      // Catch Flutter framework errors
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        ErrorHandler.reportError(
          details.exception,
          details.stack ?? StackTrace.current,
        );
      };

      // Run the app
      runApp(
        const ProviderScope(
          child: RUGApp(),
        ),
      );
    },
    // Catch all uncaught async errors
    (error, stackTrace) {
      AppLogger.fatal('Uncaught error', error: error, stackTrace: stackTrace);
      ErrorHandler.reportError(error, stackTrace);
    },
  );
}
