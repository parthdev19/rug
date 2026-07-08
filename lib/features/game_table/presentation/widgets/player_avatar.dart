/// Circular player avatar with connection status indicator and turn highlight.
library;

import 'package:flutter/material.dart';
import 'package:rug/features/game_table/models/player_seat_model.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    required this.player,
    this.size = 48,
    super.key,
  });

  final PlayerSeatModel player;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderColor = player.isCurrentTurn
        ? SplashAnimationConstants.emerald
        : player.isCurrentPlayer
            ? SplashAnimationConstants.emerald.withValues(alpha: 0.5)
            : SplashAnimationConstants.gold.withValues(alpha: 0.4);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar circle
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: player.isCurrentTurn ? 2.5 : 1.5,
            ),
            color: const Color(0xFF0C100E),
            boxShadow: player.isCurrentTurn
                ? [
                    BoxShadow(
                      color: SplashAnimationConstants.emerald.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: player.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      player.avatarUrl!,
                      width: size - 4,
                      height: size - 4,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitials(),
                    ),
                  )
                : _buildInitials(),
          ),
        ),

        // Connection status indicator
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _connectionColor,
              border: Border.all(color: const Color(0xFF0C100E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials() {
    final initials = player.username.isNotEmpty
        ? player.username[0].toUpperCase()
        : '?';

    return Text(
      initials,
      style: TextStyle(
        color: player.isCurrentPlayer
            ? SplashAnimationConstants.emerald
            : SplashAnimationConstants.gold,
        fontSize: size * 0.38,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Color get _connectionColor {
    return switch (player.connectionStatus) {
      ConnectionStatus.online => const Color(0xFF2EA043),
      ConnectionStatus.offline => const Color(0xFFDA3633),
      ConnectionStatus.reconnecting => const Color(0xFFD29922),
    };
  }
}
