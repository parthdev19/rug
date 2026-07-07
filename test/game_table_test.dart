import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/features/create_game/controller/create_game_controller.dart';
import 'package:rug/features/game_table/controller/game_table_controller.dart';
import 'package:rug/features/game_table/controller/game_table_state.dart';
import 'package:rug/features/game_table/models/player_seat_model.dart';
import 'package:rug/features/game_table/presentation/widgets/seat_layout_calculator.dart';
import 'package:rug/shared/models/user_model.dart';
import 'package:rug/shared/providers/common_providers.dart';

void main() {
  group('GameTableController & SeatLayoutCalculator Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();

      // Set mock current user
      container.read(currentUserProvider.notifier).setUser(const UserModel(
            id: 'test_user_id',
            username: 'TestHost',
          ));

      // Listen to providers to keep them active
      container.listen(createGameControllerProvider, (prev, next) {});
      container.listen(gameTableControllerProvider, (prev, next) {});
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state matches CreateGameController configurations', () {
      // Configure 6 players, 120 points, 8 rounds
      final createGameNotifier = container.read(createGameControllerProvider.notifier);
      createGameNotifier.incrementPlayers(); // 4 -> 5
      createGameNotifier.incrementPlayers(); // 5 -> 6
      createGameNotifier.incrementPoints();  // 100 -> 105
      createGameNotifier.incrementRounds();  // 5 -> 6

      // Re-read or build game table controller
      final state = container.read(gameTableControllerProvider);

      expect(state.totalPlayers, 6);
      expect(state.defaultPoints, 105);
      expect(state.totalRounds, 6);
      expect(state.currentRound, 1);
      expect(state.gameStatus, GameStatus.waiting);
      expect(state.roomCode.length, 6);
      expect(state.players.length, 6);
    });

    test('seat 0 is always the local player with correct username and settings', () {
      final state = container.read(gameTableControllerProvider);
      final localPlayer = state.players[0];

      expect(localPlayer.id, 'test_user_id');
      expect(localPlayer.username, 'TestHost');
      expect(localPlayer.seatIndex, 0);
      expect(localPlayer.isCurrentPlayer, true);
      expect(localPlayer.status, PlayerStatus.ready);
      expect(localPlayer.connectionStatus, ConnectionStatus.online);
    });

    test('remaining seats are populated as mock opponents', () {
      final state = container.read(gameTableControllerProvider);
      
      for (int i = 1; i < state.players.length; i++) {
        final p = state.players[i];
        expect(p.id, 'player_$i');
        expect(p.seatIndex, i);
        expect(p.isCurrentPlayer, false);
        expect(p.connectionStatus, ConnectionStatus.online);
      }
    });

    test('toggleReady modifies local player status', () {
      final notifier = container.read(gameTableControllerProvider.notifier);
      
      // Initial is ready
      expect(container.read(gameTableControllerProvider).players[0].status, PlayerStatus.ready);

      // Toggle to waiting
      notifier.toggleReady();
      expect(container.read(gameTableControllerProvider).players[0].status, PlayerStatus.waiting);

      // Toggle back to ready
      notifier.toggleReady();
      expect(container.read(gameTableControllerProvider).players[0].status, PlayerStatus.ready);
    });

    test('SeatLayoutCalculator computes expected coordinates with player 0 at bottom center', () {
      const center = Offset(400, 300);
      const radiusX = 200.0;
      const radiusY = 150.0;
      const playerCount = 4;

      final seats = SeatLayoutCalculator.computeSeats(
        center: center,
        radiusX: radiusX,
        radiusY: radiusY,
        playerCount: playerCount,
      );

      expect(seats.length, 4);

      // Seat 0 (bottom center): angle = pi/2 -> cos(pi/2) = 0, sin(pi/2) = 1
      // x = center.dx + 0 = 400
      // y = center.dy + radiusY = 300 + 150 = 450
      expect(seats[0].dx, closeTo(400.0, 0.001));
      expect(seats[0].dy, closeTo(450.0, 0.001));

      // Seat 1: angle = pi/2 + 2*pi/4 = pi/2 + pi = 3*pi/2 (top center)
      // cos(3*pi/2) = 0, sin(3*pi/2) = -1
      // x = 400
      // y = 300 - 150 = 150
      expect(seats[2].dx, closeTo(400.0, 0.001));
      expect(seats[2].dy, closeTo(150.0, 0.001));
    });
  });
}
