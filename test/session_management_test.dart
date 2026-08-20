import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/shared/models/user_model.dart';
import 'package:rug/shared/providers/common_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Session Restoration & Logout State Tests', () {
    test('Session restoration populates user providers when profile is valid', () {
      final container = ProviderContainer();

      // Simulate restoring session for an existing user
      final validUser = UserModel(
        id: '13',
        username: 'parth_dev',
        email: 'parth@example.com',
        isUsernameSet: true,
      );

      container.read(currentUserProvider.notifier).setUser(validUser);
      container.read(currentUserIdProvider.notifier).setUserId('13');
      container.read(isAuthenticatedProvider.notifier).setAuthenticated(true);

      expect(container.read(currentUserProvider), isNotNull);
      expect(container.read(currentUserProvider)!.username, 'parth_dev');
      expect(container.read(currentUserIdProvider), '13');
      expect(container.read(isAuthenticatedProvider), true);

      container.dispose();
    });

    test('Logout clears all user providers and authentication state', () {
      final container = ProviderContainer();

      // Initialize with logged in state
      final validUser = UserModel(
        id: '13',
        username: 'parth_dev',
        email: 'parth@example.com',
        isUsernameSet: true,
      );
      container.read(currentUserProvider.notifier).setUser(validUser);
      container.read(currentUserIdProvider.notifier).setUserId('13');
      container.read(isAuthenticatedProvider.notifier).setAuthenticated(true);

      // Simulate logout action
      container.read(currentUserProvider.notifier).clearUser();
      container.read(currentUserIdProvider.notifier).clearUserId();
      container.read(isAuthenticatedProvider.notifier).setAuthenticated(false);

      expect(container.read(currentUserProvider), null);
      expect(container.read(currentUserIdProvider), null);
      expect(container.read(isAuthenticatedProvider), false);

      container.dispose();
    });

    test('Post-OTP verification initializes session state for immediate app entry', () {
      final container = ProviderContainer();

      // Simulate successful account creation + OTP verification auto sign-in
      final newUser = UserModel(
        id: '15',
        username: 'new_player',
        email: 'newplayer@example.com',
        isUsernameSet: true,
      );

      container.read(currentUserProvider.notifier).setUser(newUser);
      container.read(currentUserIdProvider.notifier).setUserId('15');
      container.read(isAuthenticatedProvider.notifier).setAuthenticated(true);

      // Verify user state is fully populated for loader -> home transition
      expect(container.read(isAuthenticatedProvider), true);
      expect(container.read(currentUserProvider)?.username, 'new_player');
      expect(container.read(currentUserProvider)?.isUsernameSet, true);

      container.dispose();
    });
  });
}
