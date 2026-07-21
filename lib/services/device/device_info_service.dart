/// Service for retrieving device and package info and submitting it to the server.
library;

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/services/network/dio_client.dart';
import 'package:rug/services/storage/secure_storage_service.dart';

class DeviceInfoService {
  DeviceInfoService._();

  static final DeviceInfoService instance = DeviceInfoService._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Dio _dio = DioClient.instance;

  /// Exposed for testing.
  @visibleForTesting
  Dio get dio => _dio;

  /// Fetches device info and makes the API call.
  Future<void> sendDeviceInfo() async {
    try {
      final secureStorage = SecureStorageService.instance;
      final sentOnce = await secureStorage.hasSentDeviceInfo();

      // Get app version info
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Get or save install version
      String? installVersion = await secureStorage.getInstallVersion();
      if (installVersion == null) {
        installVersion = currentVersion;
        await secureStorage.saveInstallVersion(currentVersion);
      }

      // Get location coordinates (ask permission if it's the first time)
      final position = await _getCurrentLocation(requestPermission: !sentOnce);
      final lat = position?.latitude ?? 0.0;
      final long = position?.longitude ?? 0.0;

      Map<String, dynamic> payload;

      if (!sentOnce) {
        // Fetch full device details
        final deviceDetails = await _getDeviceDetails();
        final deviceType = _getDeviceType();
        final language = _getLanguage();
        final timezoneName = DateTime.now().timeZoneName;
        final timezoneOffset = _getTimezoneOffset();

        payload = {
          'device_id': deviceDetails['device_id'],
          'device_type': deviceType,
          'lat': lat,
          'long': long,
          'language': language,
          'timezone_name': timezoneName,
          'timezone_offset': timezoneOffset,
          'current_version': currentVersion,
          'install_version': installVersion,
          'device_name': deviceDetails['device_name'],
        };
      } else {
        // Subsequent launch: only send device_id, lat, long, current_version, install_version
        final deviceDetails = await _getDeviceDetails();
        payload = {
          'device_id': deviceDetails['device_id'],
          'lat': lat,
          'long': long,
          'current_version': currentVersion,
          'install_version': installVersion,
        };
      }

      AppLogger.info('Sending device info (first_time: ${!sentOnce}) to API');
      AppLogger.debug('Device info payload: $payload');

      final response = await _dio.post(
        ApiConstants.deviceInfo,
        data: payload,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Check for success: status code 200 or 201, or custom response key success = true
      final responseData = response.data;
      bool isSuccess = response.statusCode == 200 || response.statusCode == 201;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('success')) {
          isSuccess = responseData['success'] == true;
        }
      }

      if (isSuccess) {
        AppLogger.info('Device info updated successfully');
        if (!sentOnce) {
          await secureStorage.setSentDeviceInfo(true);
        }
        if (responseData is Map<String, dynamic>) {
          final data = responseData['data'];
          if (data is Map<String, dynamic>) {
            final rawUserId = data['user_id'];
            final userId = rawUserId is int
                ? rawUserId
                : int.tryParse(rawUserId?.toString() ?? '');
            if (userId != null && userId > 0) {
              await secureStorage.saveDeviceUserId(userId);
              AppLogger.debug('Device user_id saved: $userId');
            }
          }
        }
      } else {
        AppLogger.warning(
          'Failed to update device info. Status code: ${response.statusCode}, response: $responseData',
        );
      }
    } catch (e) {
      AppLogger.error('Error sending device info', error: e);
    }
  }

  /// Request permission and fetch current GPS coordinates.
  Future<Position?> _getCurrentLocation({required bool requestPermission}) async {
    try {
      if (kIsWeb) return null;
      if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (requestPermission) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return null;
          }
        } else {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      AppLogger.warning('Failed to fetch location coordinates: $e');
      return null;
    }
  }

  /// Exposes the device ID publicly.
  Future<String> getDeviceId() async {
    final details = await _getDeviceDetails();
    return details['device_id'] ?? 'unknown_id';
  }

  /// Get device ID and device name depending on platform.
  Future<Map<String, String>> _getDeviceDetails() async {
    String deviceId = 'unknown_id';
    String deviceName = 'unknown_device';

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceId = webInfo.userAgent ?? 'web_user_agent';
        deviceName = webInfo.browserName.toString();
      } else if (Platform.isAndroid) {
        const androidIdPlugin = AndroidId();
        deviceId = await androidIdPlugin.getId() ?? 'unknown_android_id';
        final androidInfo = await _deviceInfo.androidInfo;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_id';
        deviceName = iosInfo.name;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        deviceId = macInfo.systemGUID ?? 'unknown_mac_GUID';
        deviceName = macInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceId = linuxInfo.machineId ?? 'unknown_linux_id';
        deviceName = linuxInfo.name;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
        deviceName = windowsInfo.computerName;
      }
    } catch (e) {
      AppLogger.error('Failed to get platform device details', error: e);
    }

    return {
      'device_id': deviceId,
      'device_name': deviceName,
    };
  }

  /// Get simplified device type.
  String _getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    if (Platform.isWindows) return 'windows';
    return 'unknown';
  }

  /// Get simplified locale language.
  String _getLanguage() {
    try {
      if (kIsWeb) return 'en';
      final locale = Platform.localeName;
      if (locale.contains('_') || locale.contains('-')) {
        return locale.split(RegExp(r'[-_]'))[0];
      }
      return locale.isNotEmpty ? locale : 'en';
    } catch (_) {
      return 'en';
    }
  }

  /// Format timezone offset as GMT+/-HH:MM
  String _getTimezoneOffset() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours.abs().toString().padLeft(2, '0');
      final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
      final sign = offset.isNegative ? '-' : '+';
      return 'GMT$sign$hours:$minutes';
    } catch (_) {
      return 'GMT+00:00';
    }
  }
}
