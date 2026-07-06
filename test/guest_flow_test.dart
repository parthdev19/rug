import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/features/auth/controller/guest_controller.dart';
import 'package:rug/shared/providers/common_providers.dart';

void main() {
  group('GuestController & Guest Flow Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.listen(
        guestControllerProvider,
        (previous, next) {},
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state of guest controller is AsyncData(null)', () {
      final state = container.read(guestControllerProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('registerGuest updates auth state and saves guest user profile', () async {
      // 1. Initial State assertions
      expect(container.read(isAuthenticatedProvider), false);
      expect(container.read(currentUserProvider), null);
      expect(container.read(isGuestProvider), false);

      // 2. Trigger guest registration
      final notifier = container.read(guestControllerProvider.notifier);
      final future = notifier.registerGuest('rug_guest');

      // Check loading state immediately
      expect(container.read(guestControllerProvider).isLoading, true);

      final success = await future;
      expect(success, true);

      // 3. Verify final state updates
      expect(container.read(guestControllerProvider), const AsyncData<void>(null));
      expect(container.read(isAuthenticatedProvider), true);

      final user = container.read(currentUserProvider);
      expect(user, isNotNull);
      expect(user!.username, 'rug_guest');
      expect(user.id.startsWith('guest_'), true);
      expect(container.read(currentUserIdProvider), user.id);
      expect(container.read(isGuestProvider), true);
    });
  });
}
