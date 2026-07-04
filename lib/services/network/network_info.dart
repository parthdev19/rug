/// Network connectivity information service.
///
/// Wraps [connectivity_plus] to provide a simple API for checking
/// network availability throughout the application.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rug/services/logging/app_logger.dart';

class NetworkInfo {
  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Stream of connectivity changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Checks if the device currently has network access.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    final connected = !results.contains(ConnectivityResult.none);
    AppLogger.debug('Network connected: $connected ($results)');
    return connected;
  }

  /// Returns the current connectivity type.
  Future<List<ConnectivityResult>> get connectivityType =>
      _connectivity.checkConnectivity();

  /// Checks if connected via WiFi.
  Future<bool> get isWifi async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  /// Checks if connected via mobile data.
  Future<bool> get isMobile async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }
}
