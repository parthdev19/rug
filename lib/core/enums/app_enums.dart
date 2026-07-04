/// Shared enums used across the RUG application.
library;

/// Application environment flavors.
enum AppFlavor {
  dev,
  staging,
  prod,
}

/// Theme mode selection.
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Network request status for async operations.
enum RequestStatus {
  initial,
  loading,
  success,
  error,
}

/// Card suits for the game.
enum CardSuit {
  clubs('♣'),
  diamonds('♦'),
  hearts('♥'),
  spades('♠');

  const CardSuit(this.symbol);
  final String symbol;
}

/// Card ranks (Ace through King).
enum CardRank {
  ace(1, 'A'),
  two(2, '2'),
  three(3, '3'),
  four(4, '4'),
  five(5, '5'),
  six(6, '6'),
  seven(7, '7'),
  eight(8, '8'),
  nine(9, '9'),
  ten(10, '10'),
  jack(11, 'J'),
  queen(12, 'Q'),
  king(13, 'K');

  const CardRank(this.value, this.label);
  final int value;
  final String label;
}

/// Player connection status.
enum PlayerStatus {
  online,
  offline,
  inGame,
  idle,
  away,
}

/// Game room status.
enum RoomStatus {
  waiting,
  starting,
  inProgress,
  finished,
  cancelled,
}

/// Match result for a player.
enum MatchResult {
  win,
  loss,
  draw,
  abandoned,
}

/// WebSocket connection state.
enum WsConnectionState {
  connecting,
  connected,
  disconnected,
  reconnecting,
  error,
}

/// Notification type.
enum NotificationType {
  friendRequest,
  gameInvite,
  matchResult,
  reward,
  system,
  promotion,
}
