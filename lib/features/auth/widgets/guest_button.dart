/// Premium Guest Sign-In button for the Authentication Screen.
///
/// Renders a text button with 'PLAY AS GUEST' in uppercase metallic gold,
/// applying letter spacing, a soft glow shadow, and a fade animation on press.
library;

import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class GuestButton extends StatefulWidget {
  const GuestButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  State<GuestButton> createState() => _GuestButtonState();
}

class _GuestButtonState extends State<GuestButton> {
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _opacity = 0.6),
      onTapUp: (_) {
        setState(() => _opacity = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _opacity = 1.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Text(
            'PLAY AS GUEST',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SplashAnimationConstants.gold,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              shadows: [
                Shadow(
                  color: SplashAnimationConstants.gold.withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
                Shadow(
                  color: SplashAnimationConstants.brightGold.withValues(alpha: 0.20),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
