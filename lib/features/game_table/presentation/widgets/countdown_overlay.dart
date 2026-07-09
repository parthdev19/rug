/// Full-screen countdown overlay for 3 → 2 → 1 → GO.
///
/// Each number scales in with overshoot, glows, then fades out.
/// "GO" uses emerald color with a flash effect.
library;

import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class CountdownOverlay extends StatelessWidget {
  const CountdownOverlay({
    required this.value,
    super.key,
  });

  /// Current countdown value: 3, 2, 1, or 0 (GO).
  final int value;

  @override
  Widget build(BuildContext context) {
    final isGo = value == 0;
    final displayText = isGo ? 'GO' : '$value';
    final color = isGo ? SplashAnimationConstants.emerald : SplashAnimationConstants.gold;

    return IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(value),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, animValue, child) {
              // Scale: 0.3 → overshoot → 1.0
              final scale = 0.3 + (animValue * 0.7);
              // Opacity: fade in fast, stay visible
              final opacity = animValue.clamp(0.0, 1.0);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glow behind text
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: color,
                      fontSize: isGo ? 72 : 84,
                      fontWeight: FontWeight.w900,
                      letterSpacing: isGo ? 8 : 2,
                      shadows: [
                        Shadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 30,
                        ),
                        Shadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 60,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isGo) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Cards are being dealt',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
