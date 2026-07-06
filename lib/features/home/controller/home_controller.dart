import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Start a new game table as host.
  Future<void> createGame() async {
    // Action details for creating a new game.
    // Placeholder for multiplayer table/lobby initialization.
  }

  /// Join an existing game room with a code.
  Future<void> joinGame(String roomCode) async {
    // Action details for joining a room code.
  }
}
