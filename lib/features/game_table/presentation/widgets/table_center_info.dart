/// Premium glassmorphism panel displayed at the center of the table.
///
/// Shows current round, remaining rounds, target points, game status,
/// and a placeholder area for played cards. Enhanced with emerald glow,
/// gold border, and responsive sizing.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rug/features/game_table/controller/game_table_state.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class TableCenterInfo extends StatelessWidget {
  const TableCenterInfo({
    required this.currentRound,
    required this.totalRounds,
    required this.defaultPoints,
    required this.gameStatus,
    super.key,
  });

  final int currentRound;
  final int totalRounds;
  final int defaultPoints;
  final GameStatus gameStatus;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxPanelWidth = screenWidth * 0.22;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxPanelWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0C100E).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: SplashAnimationConstants.emerald.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Divider
                Container(
                  width: 40,
                  height: 0.5,
                  color: SplashAnimationConstants.gold.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 10),

                // Round info
                Text(
                  'Round $currentRound / $totalRounds',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),

                // Remaining rounds
                Text(
                  '${totalRounds - currentRound} rounds left',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Points
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: SplashAnimationConstants.gold.withValues(alpha: 0.7),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$defaultPoints pts',
                      style: TextStyle(
                        color: SplashAnimationConstants.gold.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Card area placeholder
                Container(
                  width: 64,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: SplashAnimationConstants.emerald.withValues(alpha: 0.12),
                      width: 0.8,
                    ),
                    color: Colors.white.withValues(alpha: 0.02),
                  ),
                  child: Center(
                    child: Text(
                      '♣',
                      style: TextStyle(
                        color: SplashAnimationConstants.emerald.withValues(alpha: 0.25),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _statusText {
    return switch (gameStatus) {
      GameStatus.waiting => 'WAITING FOR PLAYERS',
      GameStatus.countdown => 'GET READY',
      GameStatus.dealing => 'DEALING CARDS',
      GameStatus.playing => 'GAME IN PROGRESS',
      GameStatus.paused => 'PAUSED',
      GameStatus.finished => 'GAME OVER',
    };
  }

  Color get _statusColor {
    return switch (gameStatus) {
      GameStatus.waiting => SplashAnimationConstants.gold,
      GameStatus.countdown => SplashAnimationConstants.gold,
      GameStatus.dealing => SplashAnimationConstants.emerald,
      GameStatus.playing => SplashAnimationConstants.emerald,
      GameStatus.paused => const Color(0xFFD29922),
      GameStatus.finished => const Color(0xFFDA3633),
    };
  }
}
