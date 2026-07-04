/// Splash loading label and smoothly filling gold rail.
library;

import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class LoadingBar extends StatelessWidget {
  const LoadingBar({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'INITIALIZING TABLE...',
            style: TextStyle(
              color: SplashAnimationConstants.gold,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.65,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 2,
              child: Stack(
                children: [
                  const ColoredBox(
                    color: Color(0xFF433B24),
                    child: SizedBox.expand(),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0, 1),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFB88620),
                            SplashAnimationConstants.brightGold,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SplashAnimationConstants.gold,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
