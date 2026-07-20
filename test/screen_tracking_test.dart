import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rug/config/env/env_config.dart';
import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/core/enums/app_enums.dart';
import 'package:rug/features/screen_tracking/api/screen_info_api.dart';
import 'package:rug/features/screen_tracking/models/screen_info_model.dart';
import 'package:rug/features/screen_tracking/service/screen_tracking_service.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/services/storage/secure_storage_service.dart';

// ---------------------------------------------------------------------------
// Mock HTTP adapter
// ---------------------------------------------------------------------------

class _MockAdapter implements HttpClientAdapter {
  Map<String, dynamic>? _responseJson;
  int _statusCode = 200;
  RequestOptions? lastOptions;
  int callCount = 0;

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
    lastOptions = options;
    callCount++;
    return ResponseBody.fromString(
      jsonEncode(_responseJson ?? {'success': true}),
      _statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockAdapter adapter;

  setUpAll(() {
    AppLogger.init(enableLogging: false);
    EnvConfig.init(AppFlavor.dev);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SecureStorageService.instance.resetForTesting();
    adapter = _MockAdapter();
    ScreenInfoApi.instance.dio = Dio()..httpClientAdapter = adapter;
  });

  // =========================================================================
  // formatScreenName
  // =========================================================================

  group('formatScreenName', () {
    test('returns explicit override for known camelCase names', () {
      expect(formatScreenName('gameTable'), 'game_table_screen');
      expect(formatScreenName('forgotPassword'), 'forgot_password_screen');
      expect(formatScreenName('verifyOtp'), 'verify_otp_screen');
      expect(formatScreenName('createGame'), 'create_game_screen');
      expect(formatScreenName('multiplayerTable'), 'multiplayer_table_screen');
    });

    test('converts generic camelCase to snake_case and appends _screen', () {
      expect(formatScreenName('home'), 'home_screen');
      expect(formatScreenName('profile'), 'profile_screen');
      expect(formatScreenName('myAwesomePage'), 'my_awesome_page_screen');
    });

    test('does not double-append _screen if name already ends with it', () {
      expect(formatScreenName('home_screen'), 'home_screen');
    });
  });

  // =========================================================================
  // ScreenInfoApi
  // =========================================================================

  group('ScreenInfoApi.postScreenInfo', () {
    test('sends correct payload to the right endpoint', () async {
      adapter.setResponse({'success': true, 'statuscode': 1});

      final entry = ScreenInfoModel(
        screenName: 'home_screen',
        screenTime: DateTime.utc(2026, 7, 18, 10, 30),
      );

      final ok = await ScreenInfoApi.instance.postScreenInfo(
        userId: 42,
        entry: entry,
      );

      expect(ok, isTrue);
      expect(adapter.lastOptions, isNotNull);
      expect(adapter.lastOptions!.path, ApiConstants.screenInfo);
      expect(adapter.lastOptions!.method, 'POST');

      final body = adapter.lastOptions!.data as Map<String, dynamic>;
      expect(body['user_id'], 42);

      final list = body['screen_info'] as List<dynamic>;
      expect(list.length, 1);
      expect(list[0]['screen_name'], 'home_screen');
      expect(list[0]['screen_time'], '2026-07-18T10:30:00.000Z');
    });

    test('returns false and does not throw on HTTP error response', () async {
      adapter.setResponse({'success': false}, statusCode: 400);

      final entry = ScreenInfoModel(
        screenName: 'auth_screen',
        screenTime: DateTime.utc(2026),
      );

      final ok = await ScreenInfoApi.instance.postScreenInfo(
        userId: 1,
        entry: entry,
      );

      expect(ok, isFalse);
    });
  });

  // =========================================================================
  // ScreenTracker (via simulateRouteChange)
  // =========================================================================

  group('ScreenTracker', () {
    late ScreenTracker tracker;

    setUp(() {
      // Provide a fixed user_id so repository does not skip.
      tracker = ScreenTracker(readUserId: () => '3');
    });

    test('tracks a new screen on navigation', () async {
      tracker.simulateRouteChange('home');
      await Future.delayed(const Duration(milliseconds: 30));

      expect(adapter.callCount, 1);
      final body = adapter.lastOptions!.data as Map<String, dynamic>;
      expect(
        (body['screen_info'] as List)[0]['screen_name'],
        'home_screen',
      );
      expect(body['user_id'], 3);
    });

    test('deduplicates consecutive navigations to the same screen', () async {
      tracker.simulateRouteChange('home');
      await Future.delayed(const Duration(milliseconds: 30));
      tracker.simulateRouteChange('home');
      await Future.delayed(const Duration(milliseconds: 30));

      expect(adapter.callCount, 1);
    });

    test('tracks different screens as separate events', () async {
      tracker.simulateRouteChange('home');
      await Future.delayed(const Duration(milliseconds: 30));
      tracker.simulateRouteChange('profile');
      await Future.delayed(const Duration(milliseconds: 30));

      expect(adapter.callCount, 2);
      final body = adapter.lastOptions!.data as Map<String, dynamic>;
      expect(
        (body['screen_info'] as List)[0]['screen_name'],
        'profile_screen',
      );
    });

    test('game screen is tracked exactly once on entry', () async {
      tracker.simulateRouteChange('gameTable');
      await Future.delayed(const Duration(milliseconds: 30));
      // Simulate an in-game sub-route that is neither a game nor non-game route.
      tracker.simulateRouteChange('inGameDialog');
      await Future.delayed(const Duration(milliseconds: 30));
      // Return to game — still inside game lock.
      tracker.simulateRouteChange('gameTable');
      await Future.delayed(const Duration(milliseconds: 30));

      expect(adapter.callCount, 1);
      final body = adapter.lastOptions!.data as Map<String, dynamic>;
      expect(
        (body['screen_info'] as List)[0]['screen_name'],
        'game_table_screen',
      );
    });

    test('resumes tracking when user exits game to a non-game screen', () async {
      tracker.simulateRouteChange('gameTable');
      await Future.delayed(const Duration(milliseconds: 30));
      tracker.simulateRouteChange('home');
      await Future.delayed(const Duration(milliseconds: 30));

      expect(adapter.callCount, 2);
    });

    test('skips tracking when no user_id and no storage fallback exists',
        () async {
      final noIdTracker = ScreenTracker(readUserId: () => null);
      noIdTracker.simulateRouteChange('home');
      await Future.delayed(const Duration(milliseconds: 30));

      expect(adapter.callCount, 0);
    });

    test('extracts numeric part from guest user ID format', () async {
      final guestTracker =
          ScreenTracker(readUserId: () => 'guest_987654');
      guestTracker.simulateRouteChange('home');
      await Future.delayed(const Duration(milliseconds: 30));

      expect(adapter.callCount, 1);
      final body = adapter.lastOptions!.data as Map<String, dynamic>;
      expect(body['user_id'], 987654);
    });

    test('falls back to stored device_user_id when provider returns null',
        () async {
      await SecureStorageService.instance.saveDeviceUserId(777);

      final fallbackTracker = ScreenTracker(readUserId: () => null);
      fallbackTracker.simulateRouteChange('home');
      await Future.delayed(const Duration(milliseconds: 30));

      expect(adapter.callCount, 1);
      final body = adapter.lastOptions!.data as Map<String, dynamic>;
      expect(body['user_id'], 777);
    });

    test('sends exact user_id from numeric readUserId callback', () async {
      final specificTracker = ScreenTracker(readUserId: () => '99');
      specificTracker.simulateRouteChange('settings');
      await Future.delayed(const Duration(milliseconds: 30));

      final body = adapter.lastOptions!.data as Map<String, dynamic>;
      expect(body['user_id'], 99);
    });
  });
}
