/// Card animation utilities for the RUG game.
///
/// Provides reusable animation builders for card flip, deal,
/// fan-out, and shuffle effects.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rug/animations/animation_constants.dart';

/// Animated card flip effect (front ↔ back).
class CardFlipAnimation extends StatefulWidget {
  const CardFlipAnimation({
    super.key,
    required this.front,
    required this.back,
    this.duration = AnimationConstants.cardFlip,
    this.onFlipComplete,
  });

  final Widget front;
  final Widget back;
  final Duration duration;
  final VoidCallback? onFlipComplete;

  @override
  State<CardFlipAnimation> createState() => CardFlipAnimationState();
}

class CardFlipAnimationState extends State<CardFlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFrontVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  /// Flips the card.
  void flip() {
    if (_controller.isAnimating) return;

    if (_isFrontVisible) {
      _controller.forward().then((_) {
        _isFrontVisible = false;
        widget.onFlipComplete?.call();
      });
    } else {
      _controller.reverse().then((_) {
        _isFrontVisible = true;
        widget.onFlipComplete?.call();
      });
    }
  }

  /// Returns whether the front is currently visible.
  bool get isFrontVisible => _isFrontVisible;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * math.pi;
        final isFront = angle < math.pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle),
          child: isFront
              ? widget.front
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: widget.back,
                ),
        );
      },
    );
  }
}

/// Card deal animation — slides and fades a card into position.
class CardDealAnimation extends StatelessWidget {
  const CardDealAnimation({
    super.key,
    required this.child,
    required this.index,
    this.totalCards = 5,
  });

  final Widget child;
  final int index;
  final int totalCards;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AnimationConstants.cardDeal +
          AnimationConstants.cardStaggerDelay * index,
      curve: AnimationConstants.cardCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Card fan animation — arranges cards in a fan pattern.
class CardFanTransform {
  CardFanTransform._();

  /// Calculates the rotation angle for a card at [index] in a fan of [totalCards].
  static double fanAngle(int index, int totalCards) {
    const fanSpread = 30.0; // Total spread in degrees
    final step = totalCards > 1 ? fanSpread / (totalCards - 1) : 0;
    return (-fanSpread / 2 + step * index) * math.pi / 180;
  }

  /// Calculates the vertical offset for a card at [index] in a fan.
  static double fanOffsetY(int index, int totalCards) {
    final mid = (totalCards - 1) / 2;
    final distance = (index - mid).abs();
    return distance * 5.0; // Cards at edges are slightly lower
  }
}
