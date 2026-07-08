/// Controller managing game table state and actions.
///
/// Handles game phases: waiting → countdown → dealing → playing.
library;

import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/create_game/controller/create_game_controller.dart';
import 'package:rug/features/game_table/controller/game_table_state.dart';
import 'package:rug/features/game_table/models/card_model.dart';
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
      ));
    }

    return players;
  }

  // ── Game Flow ──────────────────────────────────────────────────────────

  /// Host starts the game. Begins countdown sequence.
  Future<void> startGame() async {
    if (!state.isHost || state.gameStatus != GameStatus.waiting) return;

    // Mark all players as ready
    final readyPlayers = state.players
        .map((p) => p.copyWith(status: PlayerStatus.ready))
        .toList();
    state = state.copyWith(
      players: readyPlayers,
      gameStatus: GameStatus.countdown,
      countdownValue: 3,
    );

    // 3 → 2 → 1 → GO
    for (int i = 3; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (state.gameStatus != GameStatus.countdown) return; // cancelled
      state = state.copyWith(countdownValue: i);
    }

    // Short pause after GO
    await Future.delayed(const Duration(milliseconds: 600));

    // Begin dealing
    _dealCards();
  }

  /// Shuffle and distribute cards to all players.
  void _dealCards() {
    final deck = Deck.shuffle(Deck.fullDeck());
    final result = Deck.distribute(
      deck: deck,
      playerCount: state.players.length,
    );

    // Mark players as playing
    final playingPlayers = state.players
        .map((p) => p.copyWith(status: PlayerStatus.playing))
        .toList();

    state = state.copyWith(
      gameStatus: GameStatus.dealing,
      players: playingPlayers,
      playerHands: result.hands,
      drawPile: result.drawPile,
    );
  }

  /// Called when dealing animation completes.
  void onDealingComplete() {
    // Set current turn to player after dealer
    final turnIndex = (state.dealerIndex + 1) % state.players.length;
    final updatedPlayers = state.players.asMap().entries.map((e) {
      return e.value.copyWith(isCurrentTurn: e.key == turnIndex);
    }).toList();

    state = state.copyWith(
      gameStatus: GameStatus.playing,
      dealingComplete: true,
      currentTurnIndex: turnIndex,
      players: updatedPlayers,
    );
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
