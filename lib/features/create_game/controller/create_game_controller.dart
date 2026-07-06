/// Controller managing the state and actions of the Create Game configuration.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/create_game/controller/create_game_state.dart';

part 'create_game_controller.g.dart';

@riverpod
class CreateGameController extends _$CreateGameController {
  @override
  CreateGameState build() {
    return const CreateGameState();
  }

  /// Increment the total players count (maximum of 9).
  void incrementPlayers() {
    if (state.totalPlayers < 9) {
      state = state.copyWith(totalPlayers: state.totalPlayers + 1);
    }
  }

  /// Decrement the total players count (minimum of 4).
  void decrementPlayers() {
    if (state.totalPlayers > 4) {
      state = state.copyWith(totalPlayers: state.totalPlayers - 1);
    }
  }

  /// Increment default points count in steps of 5 (maximum of 170).
  void incrementPoints() {
    if (state.defaultPoints < 170) {
      state = state.copyWith(defaultPoints: state.defaultPoints + 5);
    }
  }

  /// Decrement default points count in steps of 5 (minimum of 100).
  void decrementPoints() {
    if (state.defaultPoints > 100) {
      state = state.copyWith(defaultPoints: state.defaultPoints - 5);
    }
  }

  /// Increment total rounds count (maximum of 20).
  void incrementRounds() {
    if (state.totalRounds < 20) {
      state = state.copyWith(totalRounds: state.totalRounds + 1);
    }
  }

  /// Decrement total rounds count (minimum of 1).
  void decrementRounds() {
    if (state.totalRounds > 1) {
      state = state.copyWith(totalRounds: state.totalRounds - 1);
    }
  }

  /// Validates the configured values.
  bool validate() {
    final playersOk = state.totalPlayers >= 4 && state.totalPlayers <= 9;
    final pointsOk = state.defaultPoints >= 100 && state.defaultPoints <= 170;
    final roundsOk = state.totalRounds >= 1 && state.totalRounds <= 20;
    final valid = playersOk && pointsOk && roundsOk;
    state = state.copyWith(isValid: valid);
    return valid;
  }
}
