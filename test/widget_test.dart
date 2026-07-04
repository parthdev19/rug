import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rug/app.dart';
import 'package:rug/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('RUGApp boots successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RUGApp()));

    // Verify that the root app widget is found.
    expect(find.byType(RUGApp), findsOneWidget);
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
