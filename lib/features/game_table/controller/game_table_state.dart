/// State class representing the game table's current state.
///
/// Tracks game phases from waiting → countdown → dealing → playing → finished.
library;

import 'package:rug/features/game_table/models/card_model.dart';
import 'package:rug/features/game_table/models/player_seat_model.dart';

/// The overall status of the game.
enum GameStatus { waiting, countdown, dealing, playing, paused, finished }

class GameTableState {
  const GameTableState({
    this.roomCode = '',
    this.players = const [],
    this.totalPlayers = 5,
    this.currentRound = 1,
    this.totalRounds = 5,
    this.defaultPoints = 100,
    this.gameStatus = GameStatus.waiting,
    this.currentTurnIndex = 0,
    this.isHost = true,
    this.countdownValue = 3,
    this.playerHands = const [],
    this.drawPile = const [],
    this.dealerIndex = 0,
    this.dealingComplete = false,
  });

  final String roomCode;
  final List<PlayerSeatModel> players;
  final int totalPlayers;
  final int currentRound;
  final int totalRounds;
  final int defaultPoints;
  final GameStatus gameStatus;
  final int currentTurnIndex;
  final bool isHost;
  final int countdownValue;
  final List<List<PlayingCard>> playerHands;
  final List<PlayingCard> drawPile;
  final int dealerIndex;
  final bool dealingComplete;

  GameTableState copyWith({
    String? roomCode,
    List<PlayerSeatModel>? players,
    int? totalPlayers,
    int? currentRound,
    int? totalRounds,
    int? defaultPoints,
    GameStatus? gameStatus,
    int? currentTurnIndex,
    bool? isHost,
    int? countdownValue,
    List<List<PlayingCard>>? playerHands,
    List<PlayingCard>? drawPile,
    int? dealerIndex,
    bool? dealingComplete,
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
      isHost: isHost ?? this.isHost,
      countdownValue: countdownValue ?? this.countdownValue,
      playerHands: playerHands ?? this.playerHands,
      drawPile: drawPile ?? this.drawPile,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      dealingComplete: dealingComplete ?? this.dealingComplete,
    );
  }
}
