import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rug/services/device/device_info_service.dart';
import 'package:rug/services/storage/secure_storage_service.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/config/env/env_config.dart';
import 'package:rug/core/enums/app_enums.dart';
import 'package:rug/core/constants/api_constants.dart';

class MockAdapter implements HttpClientAdapter {
  late Map<String, dynamic> _responseJson;
  late int _statusCode;
  RequestOptions? lastRequestOptions;

  void setResponse(Map<String, dynamic> json, {int statusCode = 200}) {
    _responseJson = json;
    _statusCode = statusCode;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    return ResponseBody.fromString(
      jsonEncode(_responseJson),
      _statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceInfoService Tests', () {
    late MockAdapter mockAdapter;
    late SecureStorageService secureStorage;

    setUpAll(() {
      AppLogger.init(enableLogging: false);
      EnvConfig.init(AppFlavor.dev);
    });

    setUp(() async {
      // Initialize SharedPreferences with empty mock values
      SharedPreferences.setMockInitialValues({});
      
      // Initialize PackageInfo with mock values
      PackageInfo.setMockInitialValues(
        appName: 'RUG',
        packageName: 'com.rug.game',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      secureStorage = SecureStorageService.instance;
      // Clear secure storage/prefs
      await secureStorage.clearAll();

      mockAdapter = MockAdapter();
      
      // Inject mock adapter into the global DioClient instance
      DeviceInfoService.instance.dio.httpClientAdapter = mockAdapter;
    });

    test('First app launch sends all details and updates local preference', () async {
      mockAdapter.setResponse({
        'success': true,
        'statuscode': 1,
        'message': 'Device info updated successfully.',
        'data': {'user_id': 1}
      });

      // Assert firstLaunch and deviceInfoSentOnce initial state
      expect(await secureStorage.hasSentDeviceInfo(), false);
      expect(await secureStorage.getInstallVersion(), null);

      // Trigger API call
      await DeviceInfoService.instance.sendDeviceInfo();

      // Verify the request details
      expect(mockAdapter.lastRequestOptions, isNotNull);
      expect(mockAdapter.lastRequestOptions!.path, ApiConstants.deviceInfo);
      expect(mockAdapter.lastRequestOptions!.method, 'POST');

      final data = mockAdapter.lastRequestOptions!.data as Map<String, dynamic>;
      expect(data.containsKey('device_id'), true);
      expect(data.containsKey('device_type'), true);
      expect(data['lat'], 0);
      expect(data['long'], 0);
      expect(data.containsKey('language'), true);
      expect(data.containsKey('timezone_name'), true);
      expect(data.containsKey('timezone_offset'), true);
      expect(data['current_version'], '1.0.0');
      expect(data['install_version'], '1.0.0');
      expect(data.containsKey('device_name'), true);

      // Verify states saved in local storage
      expect(await secureStorage.hasSentDeviceInfo(), true);
      expect(await secureStorage.getInstallVersion(), '1.0.0');
    });

    test('Subsequent launch sends only 4 keys', () async {
      // Pre-set that device info has been sent and install version is 0.9.0
      await secureStorage.setSentDeviceInfo(true);
      await secureStorage.saveInstallVersion('0.9.0');

      mockAdapter.setResponse({
        'success': true,
        'statuscode': 1,
        'message': 'Device info updated successfully.',
        'data': {'user_id': 1}
      });

      // Trigger API call
      await DeviceInfoService.instance.sendDeviceInfo();

      // Verify the request details
      expect(mockAdapter.lastRequestOptions, isNotNull);
      final data = mockAdapter.lastRequestOptions!.data as Map<String, dynamic>;
      
      // Should only contain the 4 keys: lat, long, current_version, install_version
      expect(data.length, 4);
      expect(data['lat'], 0);
      expect(data['long'], 0);
      expect(data['current_version'], '1.0.0');
      expect(data['install_version'], '0.9.0');

      expect(data.containsKey('device_id'), false);
      expect(data.containsKey('device_type'), false);
      expect(data.containsKey('device_name'), false);
    });

    test('If API call fails, local storage flag is not set to true', () async {
      mockAdapter.setResponse({
        'success': false,
        'statuscode': 0,
        'message': 'Error updating device info.',
      }, statusCode: 400);

      expect(await secureStorage.hasSentDeviceInfo(), false);

      // Trigger API call
      await DeviceInfoService.instance.sendDeviceInfo();

      // Verify state remains false
      expect(await secureStorage.hasSentDeviceInfo(), false);
    });
  });
}
