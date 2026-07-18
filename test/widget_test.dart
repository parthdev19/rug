import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rug/app.dart';
import 'package:rug/features/splash/presentation/splash_screen.dart';
import 'package:rug/config/env/env_config.dart';
import 'package:rug/core/enums/app_enums.dart';
import 'package:rug/services/device/device_info_service.dart';

class MockWidgetTestAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({'success': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() {
    EnvConfig.init(AppFlavor.dev);
  });

  setUp(() {
    // Inject mock adapter to prevent real network calls and timeouts
    DeviceInfoService.instance.dio.httpClientAdapter = MockWidgetTestAdapter();
  });

  testWidgets('RUGApp boots successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RUGApp()));

    // Verify that the root app widget is found.
    expect(find.byType(RUGApp), findsOneWidget);

    // Let the splash animations and timers finish to prevent pending timer errors
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('splash deal animation completes without framework errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: RUGApp()));

    expect(find.byType(SplashScreen), findsOneWidget);

    // Cross the card landing overshoot where the previous curve assertion
    // occurred, then finish the timeline and verify navigation completes.
    await tester.pump(const Duration(milliseconds: 2900));
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 1200));
    expect(tester.takeException(), isNull);
  });
}
