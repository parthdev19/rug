/// Controller managing game table state and actions.
library;

import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/create_game/controller/create_game_controller.dart';
import 'package:rug/features/game_table/controller/game_table_state.dart';
import 'package:rug/features/game_table/models/player_seat_model.dart';
import 'package:rug/shared/providers/common_providers.dart';

part 'game_table_controller.g.dart';

@riverpod
class GameTableController extends _$GameTableController {
  @override
  GameTableState build() {
    final config = ref.watch(createGameControllerProvider);
    final currentUser = ref.watch(currentUserProvider);

    final roomCode = _generateRoomCode();
    final players = _generateMockPlayers(
      totalPlayers: config.totalPlayers,
      currentUsername: currentUser?.username ?? 'Player',
      currentUserId: currentUser?.id ?? 'local_player',
    );

    return GameTableState(
      roomCode: roomCode,
      players: players,
      totalPlayers: config.totalPlayers,
      totalRounds: config.totalRounds,
      defaultPoints: config.defaultPoints,
      currentRound: 1,
      gameStatus: GameStatus.waiting,
      currentTurnIndex: 0,
    );
  }

  /// Generate a random 6-character alphanumeric room code.
  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Generate mock players for the table.
  /// Seat 0 is always the local (current) player.
  List<PlayerSeatModel> _generateMockPlayers({
    required int totalPlayers,
    required String currentUsername,
    required String currentUserId,
  }) {
    final List<PlayerSeatModel> players = [];

    // Seat 0 — local player (bottom center)
    players.add(PlayerSeatModel(
      id: currentUserId,
      username: currentUsername,
      seatIndex: 0,
      isCurrentPlayer: true,
      isCurrentTurn: true,
      status: PlayerStatus.ready,
      connectionStatus: ConnectionStatus.online,
    ));

    // Fill remaining seats with mock opponents
    const mockNames = [
      'Arjun', 'Priya', 'Rahul', 'Sneha',
      'Vikram', 'Ananya', 'Karan', 'Meera',
    ];

    for (int i = 1; i < totalPlayers; i++) {
      final name = mockNames[(i - 1) % mockNames.length];
      players.add(PlayerSeatModel(
        id: 'player_$i',
        username: name,
        seatIndex: i,
        isDealer: i == 1, // First opponent is dealer for mock
        status: PlayerStatus.waiting,
        connectionStatus: ConnectionStatus.online,
      ));
    }

    return players;
  }

  /// Leave the table (placeholder for future API call).
  void leaveTable() {
    // Will trigger socket disconnect + navigation in the future.
  }

  /// Toggle the local player's ready status.
  void toggleReady() {
    final updatedPlayers = state.players.map((p) {
      if (p.isCurrentPlayer) {
        return p.copyWith(
          status: p.status == PlayerStatus.ready
              ? PlayerStatus.waiting
              : PlayerStatus.ready,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(players: updatedPlayers);
  }
}
