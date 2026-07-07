/// Glassmorphism panel displayed at the center of the table.
///
/// Shows current round, game status, total points, and a
/// placeholder area for played cards.
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0C100E).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.15),
              width: 0.8,
            ),
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
              const SizedBox(height: 8),

              // Round info
              Text(
                'Round $currentRound / $totalRounds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),

              // Points
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.stars_rounded,
                    color: SplashAnimationConstants.gold.withValues(alpha: 0.7),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$defaultPoints pts',
                    style: TextStyle(
                      color: SplashAnimationConstants.gold.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Card area placeholder
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    '♣',
                    style: TextStyle(
                      color: SplashAnimationConstants.emerald.withValues(alpha: 0.3),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _statusText {
    return switch (gameStatus) {
      GameStatus.waiting => 'WAITING FOR PLAYERS',
      GameStatus.playing => 'GAME IN PROGRESS',
      GameStatus.paused => 'PAUSED',
      GameStatus.finished => 'GAME OVER',
    };
  }

  Color get _statusColor {
    return switch (gameStatus) {
      GameStatus.waiting => SplashAnimationConstants.gold,
      GameStatus.playing => SplashAnimationConstants.emerald,
      GameStatus.paused => const Color(0xFFD29922),
      GameStatus.finished => const Color(0xFFDA3633),
    };
  }
}
