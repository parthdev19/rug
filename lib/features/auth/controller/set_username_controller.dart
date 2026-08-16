import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/shared/models/user_model.dart';
import 'package:rug/shared/providers/common_providers.dart';
import 'package:rug/services/logging/app_logger.dart';

part 'set_username_controller.g.dart';

@riverpod
class SetUsernameController extends _$SetUsernameController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Calls [/v1/app/auth/update_username] and marks the user as having a
  /// username set in the local provider state.
  Future<bool> setUsername(String username) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.updateUsername(username: username);

      // Update the in-memory user so the rest of the app sees the new name
      // and isUsernameSet = true immediately.
      final current = ref.read(currentUserProvider);
      if (current != null) {
        final updated = UserModel(
          id: current.id,
          username: username,
          email: current.email,
          avatarUrl: current.avatarUrl,
          displayName: username,
          level: current.level,
          totalWins: current.totalWins,
          totalGames: current.totalGames,
          createdAt: current.createdAt,
          isUsernameSet: true,
        );
        ref.read(currentUserProvider.notifier).setUser(updated);
      }

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      AppLogger.error('Set username failed', error: e, stackTrace: st);
      state = AsyncError(e, st);
      return false;
    }
  }
}
