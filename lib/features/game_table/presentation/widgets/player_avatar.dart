/// Premium circular player avatar with gold border, emerald glow,
/// and connection status indicator.
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar circle with gold border + soft glow
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: player.isCurrentTurn
                  ? SplashAnimationConstants.emerald
                  : SplashAnimationConstants.gold.withValues(alpha: 0.6),
              width: player.isCurrentTurn ? 2.5 : 2.0,
            ),
            color: const Color(0xFF0C100E),
            boxShadow: [
              // Soft emerald ambient glow on all avatars
              BoxShadow(
                color: SplashAnimationConstants.emerald.withValues(
                  alpha: player.isCurrentTurn ? 0.3 : 0.06,
                ),
                blurRadius: player.isCurrentTurn ? 14 : 6,
                spreadRadius: player.isCurrentTurn ? 2 : 0,
              ),
              // Subtle gold rim glow
              BoxShadow(
                color: SplashAnimationConstants.gold.withValues(alpha: 0.08),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: player.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      player.avatarUrl!,
                      width: size - 6,
                      height: size - 6,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildInitials(),
                    ),
                  )
                : _buildInitials(),
          ),
        ),

        // Online status indicator
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _connectionColor,
              border: Border.all(color: const Color(0xFF0C100E), width: 2),
              boxShadow: [
                BoxShadow(
                  color: _connectionColor.withValues(alpha: 0.4),
                  blurRadius: 3,
                ),
              ],
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
        fontSize: size * 0.36,
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
