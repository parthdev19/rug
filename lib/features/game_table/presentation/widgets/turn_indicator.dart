/// Pulsing emerald ring indicator for the active player's turn.
///
/// Features a soft emerald pulse glow, animated gradient border ring,
/// and a small "YOUR TURN" badge for the current player.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class TurnIndicator extends StatefulWidget {
  const TurnIndicator({
    required this.isActive,
    required this.child,
    this.size = 58,
    this.showBadge = false,
    super.key,
  });

  final bool isActive;
  final Widget child;
  final double size;
  final bool showBadge;

  @override
  State<TurnIndicator> createState() => _TurnIndicatorState();
}

class _TurnIndicatorState extends State<TurnIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant TurnIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(child: widget.child),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Glow layer
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SplashAnimationConstants.emerald.withValues(
                          alpha: 0.12 + (_pulseAnimation.value * 0.18),
                        ),
                        blurRadius: 14 + (_pulseAnimation.value * 10),
                        spreadRadius: 1 + (_pulseAnimation.value * 3),
                      ),
                    ],
                  ),
                ),
                // Rotating gradient border ring
                Transform.rotate(
                  angle: _pulseAnimation.value * math.pi * 2,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          SplashAnimationConstants.emerald.withValues(alpha: 0.6),
                          SplashAnimationConstants.emerald.withValues(alpha: 0.0),
                          SplashAnimationConstants.emerald.withValues(alpha: 0.3),
                          SplashAnimationConstants.emerald.withValues(alpha: 0.0),
                          SplashAnimationConstants.emerald.withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: widget.size - 4,
                        height: widget.size - 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                // Child (avatar)
                child!,
              ],
            );
          },
          child: widget.child,
        ),
        // "YOUR TURN" badge
        if (widget.showBadge) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: SplashAnimationConstants.emerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: SplashAnimationConstants.emerald.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: const Text(
              'YOUR TURN',
              style: TextStyle(
                color: SplashAnimationConstants.emerald,
                fontSize: 6,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
