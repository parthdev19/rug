/// State class representing the Create Game configuration state.
library;

class CreateGameState {
  const CreateGameState({
    this.totalPlayers = 4,
    this.defaultPoints = 100,
    this.totalRounds = 5,
    this.isValid = true,
  });

  final int totalPlayers;
  final int defaultPoints;
  final int totalRounds;
  final bool isValid;

  CreateGameState copyWith({
    int? totalPlayers,
    int? defaultPoints,
    int? totalRounds,
    bool? isValid,
  }) {
    return CreateGameState(
      totalPlayers: totalPlayers ?? this.totalPlayers,
      defaultPoints: defaultPoints ?? this.defaultPoints,
      totalRounds: totalRounds ?? this.totalRounds,
      isValid: isValid ?? this.isValid,
    );
  }
}
