import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/config/env/env_config.dart';
import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/core/enums/app_enums.dart';
import 'package:rug/routes/app_router.dart';
import 'package:rug/services/device/screen_tracker_service.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/shared/providers/common_providers.dart';

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
    final jsonString = jsonEncode(_responseJson);
    return ResponseBody.fromString(
      jsonString,
      _statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class MockRoute extends Route<dynamic> {
  MockRoute({required String name}) : super(settings: RouteSettings(name: name));
}

void main() {
  late MockAdapter mockAdapter;
  late ProviderContainer container;

  setUpAll(() {
    AppLogger.init(enableLogging: false);
    EnvConfig.init(AppFlavor.dev);
  });

  setUp(() {
    mockAdapter = MockAdapter();
    ScreenTrackerService.instance.dio = Dio()..httpClientAdapter = mockAdapter;
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('ScreenTrackerService Tests', () {
    test('trackScreen sends correct payload and resolves relative API url', () async {
      mockAdapter.setResponse({
        'success': true,
        'statuscode': 1,
        'message': 'Screen info saved successfully.',
      });

      await ScreenTrackerService.instance.trackScreen('home_screen', userId: '42');

      expect(mockAdapter.lastRequestOptions, isNotNull);
      expect(mockAdapter.lastRequestOptions!.path, ApiConstants.screenInfo);
      expect(mockAdapter.lastRequestOptions!.method, 'POST');

      final data = mockAdapter.lastRequestOptions!.data as Map<String, dynamic>;
      expect(data['user_id'], 42);
      expect(data['screen_name'], 'home_screen');
      expect(data.containsKey('screen_time'), true);
    });

    test('trackScreen defaults user_id to 0 if null or unparsable', () async {
      mockAdapter.setResponse({'success': true});

      // Null case
      await ScreenTrackerService.instance.trackScreen('splash_screen');
      expect((mockAdapter.lastRequestOptions!.data as Map)['user_id'], 0);

      // Unparsable string case
      await ScreenTrackerService.instance.trackScreen('splash_screen', userId: 'guest_123');
      expect((mockAdapter.lastRequestOptions!.data as Map)['user_id'], 0);
    });
  });

  group('ScreenTrackerObserver Tests', () {
    test('formats camelCase and custom route names to snake_case_screen format', () async {
      mockAdapter.setResponse({'success': true});
      final observer = ScreenTrackerObserver(
        readUserId: () => container.read(currentUserIdProvider),
      );

      // Test custom case mappings
      observer.didPush(MockRoute(name: 'forgotPassword'), null);
      await Future.delayed(const Duration(milliseconds: 10));
      expect((mockAdapter.lastRequestOptions!.data as Map)['screen_name'], 'forgot_password_screen');

      observer.didPush(MockRoute(name: 'createGame'), null);
      await Future.delayed(const Duration(milliseconds: 10));
      expect((mockAdapter.lastRequestOptions!.data as Map)['screen_name'], 'create_game_screen');

      // Test default camelCase to snake_case format
      observer.didPush(MockRoute(name: 'myAwesomeNewPage'), null);
      await Future.delayed(const Duration(milliseconds: 10));
      expect((mockAdapter.lastRequestOptions!.data as Map)['screen_name'], 'my_awesome_new_page_screen');
    });

    test('deduplicates consecutive entries to the same screen', () async {
      mockAdapter.setResponse({'success': true});
      final observer = ScreenTrackerObserver(
        readUserId: () => container.read(currentUserIdProvider),
      );

      // Push home_screen first time
      observer.didPush(MockRoute(name: 'home'), null);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(mockAdapter.lastRequestOptions, isNotNull);
      mockAdapter.lastRequestOptions = null;

      // Push home_screen second consecutive time
      observer.didPush(MockRoute(name: 'home'), null);
      await Future.delayed(const Duration(milliseconds: 10));
      // Should NOT result in a new HTTP call
      expect(mockAdapter.lastRequestOptions, isNull);
    });

    test('only tracks entry to game screens once, ignoring internal sub-routes until exit', () async {
      mockAdapter.setResponse({'success': true});
      final observer = ScreenTrackerObserver(
        readUserId: () => container.read(currentUserIdProvider),
      );

      // 1. Enter home screen
      observer.didPush(MockRoute(name: 'home'), null);
      await Future.delayed(const Duration(milliseconds: 10));
      expect((mockAdapter.lastRequestOptions!.data as Map)['screen_name'], 'home_screen');
      mockAdapter.lastRequestOptions = null;

      // 2. Enter game screen (gameTable)
      observer.didPush(MockRoute(name: 'gameTable'), null);
      await Future.delayed(const Duration(milliseconds: 10));
      expect((mockAdapter.lastRequestOptions!.data as Map)['screen_name'], 'game_table_screen');
      mockAdapter.lastRequestOptions = null;

      // 3. Push a sub-route while in game (not in game routes, not in non-game routes)
      observer.didPush(MockRoute(name: 'inGameMenuDialog'), null);
      await Future.delayed(const Duration(milliseconds: 10));
      // Should NOT call API since _isInGame is active
      expect(mockAdapter.lastRequestOptions, isNull);

      // 4. Return to game screen (didPop)
      observer.didPop(MockRoute(name: 'inGameMenuDialog'), MockRoute(name: 'gameTable'));
      await Future.delayed(const Duration(milliseconds: 10));
      // Should NOT call API
      expect(mockAdapter.lastRequestOptions, isNull);

      // 5. Exit game back to home screen
      observer.didPush(MockRoute(name: 'home'), null);
      await Future.delayed(const Duration(milliseconds: 10));
      // Should call API tracking home screen
      expect((mockAdapter.lastRequestOptions!.data as Map)['screen_name'], 'home_screen');
    });
  });
}
