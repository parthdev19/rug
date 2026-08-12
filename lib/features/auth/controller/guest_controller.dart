import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/shared/models/user_model.dart';
import 'package:rug/shared/providers/common_providers.dart';
import 'package:rug/services/logging/app_logger.dart';

part 'guest_controller.g.dart';

@riverpod
class GuestController extends _$GuestController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Registers a guest player via the backend guest_login API.
  Future<bool> registerGuest(String username) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.guestLogin(username: username);

      if (user != null) {
        ref.read(currentUserProvider.notifier).setUser(user);
        ref.read(currentUserIdProvider.notifier).setUserId(user.id);
        ref.read(isAuthenticatedProvider.notifier).setAuthenticated(true);
        state = const AsyncData(null);
        return true;
      }

      // Fallback: if backend returned an empty or null user, build a local guest
      AppLogger.warning('Guest login returned null user — using local fallback');
      final guestUser = UserModel(
        id: 'guest_${username.hashCode}',
        username: username,
        displayName: '$username (Guest)',
        level: 1,
        totalWins: 0,
        totalGames: 0,
        createdAt: DateTime.now(),
      );
      ref.read(currentUserProvider.notifier).setUser(guestUser);
      ref.read(currentUserIdProvider.notifier).setUserId(guestUser.id);
      ref.read(isAuthenticatedProvider.notifier).setAuthenticated(true);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      AppLogger.error('Guest login failed', error: e, stackTrace: st);
      state = AsyncError(e, st);
      return false;
    }
  }
}
