/// Bottom action button panel for the current player.
///
/// Compact, centered, with Play Card, Pass, Ready, Leave buttons.
/// Wrapped by AutoHideBar in the parent screen.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class BottomControls extends StatelessWidget {
  const BottomControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0C100E).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: SplashAnimationConstants.gold.withValues(alpha: 0.12),
                  width: 0.8,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(label: 'Play Card', icon: Icons.style_rounded),
                  SizedBox(width: 12),
                  _ActionButton(label: 'Pass', icon: Icons.skip_next_rounded),
                  SizedBox(width: 12),
                  _ActionButton(label: 'Ready', icon: Icons.check_circle_outline_rounded),
                  SizedBox(width: 12),
                  _ActionButton(label: 'Leave', icon: Icons.exit_to_app_rounded, isDestructive: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFDA3633).withValues(alpha: 0.5)
        : SplashAnimationConstants.emerald.withValues(alpha: 0.5);

    return Opacity(
      opacity: 0.6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
