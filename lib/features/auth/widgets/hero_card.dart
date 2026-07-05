/// Animated Hero Card for the Authentication Screen.
///
/// Wraps the splash screen HeroCard and applies continuous floating
/// and pulsing glow animations.
library;

import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/hero_card.dart' as splash;
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class HeroCard extends StatefulWidget {
  const HeroCard({super.key});

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _glowController;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Float animation runs on a 2800ms loop to match the splash screen idle timing
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // Continuous float slow up and down (total movement of ~4 pixels, i.e., -2.0 to +2.0)
    _floatAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // Glow pulse animation runs on a 1600ms loop
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight;
        final cardWidth = cardHeight * SplashAnimationConstants.cardAspectRatio;
        final borderRadius = Radius.circular(cardWidth * 0.071);

        return AnimatedBuilder(
          animation: Listenable.merge([_floatController, _glowController]),
          builder: (context, child) {
            final floatVal = _floatAnimation.value;
            final glowVal = _glowAnimation.value;

            return Transform.translate(
              offset: Offset(0, floatVal),
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(borderRadius),
                  boxShadow: [
                    // Premium ambient depth shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.70),
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 16),
                    ),
                    // Pulsing emerald glow
                    BoxShadow(
                      color: SplashAnimationConstants.emerald.withValues(
                        alpha: (0.10 + glowVal * 0.35).clamp(0.0, 1.0),
                      ),
                      blurRadius: 24 + glowVal * 36,
                      spreadRadius: glowVal * 6,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(borderRadius),
                  child: splash.HeroCard(glow: glowVal),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
