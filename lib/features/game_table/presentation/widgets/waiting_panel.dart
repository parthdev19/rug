/// Premium waiting state panel displayed at the table center before game starts.
///
/// Shows room info, player status, and host-only START GAME button.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class WaitingPanel extends StatefulWidget {
  const WaitingPanel({
    required this.roomCode,
    required this.currentPlayers,
    required this.totalPlayers,
    required this.currentRound,
    required this.defaultPoints,
    required this.isHost,
    required this.onStartGame,
    super.key,
  });

  final String roomCode;
  final int currentPlayers;
  final int totalPlayers;
  final int currentRound;
  final int defaultPoints;
  final bool isHost;
  final VoidCallback onStartGame;

  @override
  State<WaitingPanel> createState() => _WaitingPanelState();
}

class _WaitingPanelState extends State<WaitingPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = (screenWidth * 0.32).clamp(220.0, 320.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: panelWidth,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C100E).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: SplashAnimationConstants.emerald.withValues(alpha: 0.08),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated waiting text
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final dotCount = (_pulseController.value * 3).floor() + 1;
                  final dots = '.' * dotCount;
                  return Text(
                    'Waiting for Players$dots',
                    style: TextStyle(
                      color: SplashAnimationConstants.gold.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Player count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: SplashAnimationConstants.emerald.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: SplashAnimationConstants.emerald.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      color: SplashAnimationConstants.emerald.withValues(alpha: 0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.currentPlayers} / ${widget.totalPlayers}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Players',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Divider
              Container(
                width: 50,
                height: 0.5,
                color: SplashAnimationConstants.gold.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 14),

              // Room code
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.roomCode));
                  HapticFeedback.lightImpact();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tag_rounded,
                      color: SplashAnimationConstants.gold.withValues(alpha: 0.6),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.roomCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.copy_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Round & Points
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Round ${widget.currentRound}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  Text(
                    '${widget.defaultPoints} pts',
                    style: TextStyle(
                      color: SplashAnimationConstants.gold.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Host: START GAME button / Non-host: Waiting text
              if (widget.isHost)
                _StartGameButton(onPressed: widget.onStartGame)
              else
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: 0.4 + (_pulseController.value * 0.4),
                      child: const Text(
                        'Waiting for Host...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartGameButton extends StatefulWidget {
  const _StartGameButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_StartGameButton> createState() => _StartGameButtonState();
}

class _StartGameButtonState extends State<_StartGameButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F6B3A),
                Color(0xFF0A5530),
                Color(0xFF084425),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: SplashAnimationConstants.emerald.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: SplashAnimationConstants.emerald,
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                'START GAME',
                style: TextStyle(
                  color: SplashAnimationConstants.emerald,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
