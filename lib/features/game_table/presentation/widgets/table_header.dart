/// Top bar for the game table screen.
///
/// Displays room code, round count, player count, settings, and exit.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class TableHeader extends StatelessWidget {
  const TableHeader({
    required this.roomCode,
    required this.currentRound,
    required this.totalRounds,
    required this.totalPlayers,
    required this.onSettingsPressed,
    required this.onExitPressed,
    super.key,
  });

  final String roomCode;
  final int currentRound;
  final int totalRounds;
  final int totalPlayers;
  final VoidCallback onSettingsPressed;
  final VoidCallback onExitPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0C100E).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.12),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Room code
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: roomCode));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Room code copied!'),
                      backgroundColor: SplashAnimationConstants.emerald.withValues(alpha: 0.8),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tag_rounded,
                      color: SplashAnimationConstants.gold.withValues(alpha: 0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      roomCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.copy_rounded,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 12,
                    ),
                  ],
                ),
              ),

              // Round indicator
              _InfoChip(
                icon: Icons.loop_rounded,
                label: 'R$currentRound/$totalRounds',
              ),

              // Player count
              _InfoChip(
                icon: Icons.people_alt_outlined,
                label: '$totalPlayers',
              ),

              // Settings + Exit
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderButton(
                    icon: Icons.settings_outlined,
                    onPressed: onSettingsPressed,
                  ),
                  const SizedBox(width: 8),
                  _HeaderButton(
                    icon: Icons.exit_to_app_rounded,
                    onPressed: onExitPressed,
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: SplashAnimationConstants.gold, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatefulWidget {
  const _HeaderButton({
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive
        ? const Color(0xFFDA3633)
        : SplashAnimationConstants.gold;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF0C100E),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(widget.icon, color: color, size: 16),
        ),
      ),
    );
  }
}
