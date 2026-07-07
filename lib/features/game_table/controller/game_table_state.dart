/// State class representing the game table's current state.
library;

import 'package:rug/features/game_table/models/player_seat_model.dart';

/// The overall status of the game.
enum GameStatus { waiting, playing, paused, finished }

class GameTableState {
  const GameTableState({
    this.roomCode = '',
    this.players = const [],
    this.totalPlayers = 4,
    this.currentRound = 1,
    this.totalRounds = 5,
    this.defaultPoints = 100,
    this.gameStatus = GameStatus.waiting,
    this.currentTurnIndex = 0,
  });

  final String roomCode;
  final List<PlayerSeatModel> players;
  final int totalPlayers;
  final int currentRound;
  final int totalRounds;
  final int defaultPoints;
  final GameStatus gameStatus;
  final int currentTurnIndex;

  GameTableState copyWith({
    String? roomCode,
    List<PlayerSeatModel>? players,
    int? totalPlayers,
    int? currentRound,
    int? totalRounds,
    int? defaultPoints,
    GameStatus? gameStatus,
    int? currentTurnIndex,
  }) {
    return GameTableState(
      roomCode: roomCode ?? this.roomCode,
      players: players ?? this.players,
      totalPlayers: totalPlayers ?? this.totalPlayers,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      defaultPoints: defaultPoints ?? this.defaultPoints,
      gameStatus: gameStatus ?? this.gameStatus,
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
    );
  }
}
