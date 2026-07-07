/// Data model representing a single player seat at the game table.
library;

/// The current status of a player at the table.
enum PlayerStatus { waiting, ready, playing, folded }

/// The network connection status of a player.
enum ConnectionStatus { online, offline, reconnecting }

class PlayerSeatModel {
  const PlayerSeatModel({
    required this.id,
    required this.username,
    required this.seatIndex,
    this.avatarUrl,
    this.isCurrentPlayer = false,
    this.isDealer = false,
    this.isCurrentTurn = false,
    this.status = PlayerStatus.waiting,
    this.connectionStatus = ConnectionStatus.online,
  });

  final String id;
  final String username;
  final int seatIndex;
  final String? avatarUrl;
  final bool isCurrentPlayer;
  final bool isDealer;
  final bool isCurrentTurn;
  final PlayerStatus status;
  final ConnectionStatus connectionStatus;

  PlayerSeatModel copyWith({
    String? id,
    String? username,
    int? seatIndex,
    String? avatarUrl,
    bool? isCurrentPlayer,
    bool? isDealer,
    bool? isCurrentTurn,
    PlayerStatus? status,
    ConnectionStatus? connectionStatus,
  }) {
    return PlayerSeatModel(
      id: id ?? this.id,
      username: username ?? this.username,
      seatIndex: seatIndex ?? this.seatIndex,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isCurrentPlayer: isCurrentPlayer ?? this.isCurrentPlayer,
      isDealer: isDealer ?? this.isDealer,
      isCurrentTurn: isCurrentTurn ?? this.isCurrentTurn,
      status: status ?? this.status,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }
}
