import 'dart:math' as math;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/shared/models/user_model.dart';
import 'package:rug/shared/providers/common_providers.dart';

part 'guest_controller.g.dart';

@riverpod
class GuestController extends _$GuestController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Registers a temporary guest player profile and logs them in.
  Future<bool> registerGuest(String username) async {
    state = const AsyncLoading();

    try {
      // Simulate slight network delay for premium loader experience
      await Future.delayed(const Duration(milliseconds: 1200));

      final randomId = math.Random().nextInt(900000) + 100000;
      final guestId = 'guest_$randomId';

      final guestUser = UserModel(
        id: guestId,
        username: username,
        displayName: '$username (Guest)',
        level: 1,
        totalWins: 0,
        totalGames: 0,
        createdAt: DateTime.now(),
      );

      // Save user info and update auth status
      ref.read(currentUserProvider.notifier).setUser(guestUser);
      ref.read(currentUserIdProvider.notifier).setUserId(guestId);
      ref.read(isAuthenticatedProvider.notifier).setAuthenticated(true);

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
