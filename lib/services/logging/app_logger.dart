/// Application logger wrapper.
///
/// Wraps the [logger] package with static methods for consistent
/// logging across the application. Respects environment config.
library;

import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static late final Logger _logger;
  static bool _enabled = true;

  /// Initialize the logger.
  static void init({bool enableLogging = true}) {
    _enabled = enableLogging;
    _logger = Logger(
      printer: PrettyPrinter(
        errorMethodCount: 5,
        lineLength: 80,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: enableLogging ? Level.debug : Level.off,
    );
  }

  /// Log a debug message.
  static void debug(dynamic message) {
    if (_enabled) _logger.d(message);
  }

  /// Log an info message.
  static void info(dynamic message) {
    if (_enabled) _logger.i(message);
  }

  /// Log a warning message.
  static void warning(dynamic message) {
    if (_enabled) _logger.w(message);
  }

  /// Log an error message.
  static void error(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_enabled) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal/critical message.
  static void fatal(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Always log fatal errors regardless of environment
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log network request/response.
  static void network(String method, String url, {int? statusCode}) {
    if (_enabled) {
      final status = statusCode != null ? ' [$statusCode]' : '';
      _logger.d('🌐 $method $url$status');
    }
  }
}
