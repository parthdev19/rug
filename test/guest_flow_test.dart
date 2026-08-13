import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/features/auth/controller/guest_controller.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/features/auth/domain/repositories/auth_repository.dart';
import 'package:rug/shared/models/user_model.dart';
import 'package:rug/shared/providers/common_providers.dart';

/// Stub repository that returns a valid guest UserModel.
class StubGuestRepository implements AuthRepository {
  @override
  Future<UserModel?> guestLogin({required String username}) async {
    return UserModel(
      id: 'guest_${username.hashCode}',
      username: username,
      displayName: '$username (Guest)',
      level: 1,
      totalWins: 0,
      totalGames: 0,
      createdAt: DateTime.now(),
    );
  }

  // ── Stubs for unused methods ───────────────────────────────────────────────

  @override
  Future<UserModel?> socialSignIn({required String email, required String googleAuthToken}) async => null;

  @override
  Future<UserModel?> emailSignIn({required String email, required String password}) async => null;

  @override
  Future<Map<String, dynamic>> signUp({required String username, required String email, required String password, String? profileImagePath}) async => {};

  @override
  Future<void> verifyOtp({required String email, required int otp}) async {}

  @override
  Future<void> resendOtp({required String email}) async {}

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<String> verifyForgotPasswordOtp({required String email, required int otp}) async => '';

  @override
  Future<void> resetPassword({required String resetToken, required String newPassword}) async {}

  @override
  Future<Map<String, dynamic>> checkAvailability({String? email, String? username}) async => {};

  @override
  Future<Map<String, dynamic>> resolveAccountConflict({required int currentUserId, required int existingUserId, required String email, required String action, String? deviceId}) async => {};

  @override
  Future<Map<String, dynamic>> getProfile() async => {};

  @override
  Future<void> changePassword({required String oldPassword, required String newPassword}) async {}

  @override
  Future<void> updateUsername({required String username}) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  group('GuestController & Guest Flow Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(StubGuestRepository()),
        ],
      );
      container.listen(guestControllerProvider, (previous, next) {});
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
