/// Perspective card deal and ambient resting motion.
///
/// The card enters from outside the screen upper-left, travels a curved
/// arc toward the player (center-screen), then idles with a 3-pixel
/// breathing float after landing.
///
/// All transforms use Matrix4 with a perspective entry so the card gains
/// physical depth — the top edge becomes visible mid-flight.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rug/features/splash/controller/splash_controller.dart';
import 'package:rug/features/splash/widgets/hero_card.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class FloatingCardAnimation extends StatelessWidget {
  const FloatingCardAnimation({required this.controller, super.key});

  final SplashAnimationController controller;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final cardWidth = math.min(screenSize.width * 0.51, 226.0);
    final cardHeight = cardWidth / SplashAnimationConstants.cardAspectRatio;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller.cardListenable,
        builder: (context, child) {
          return _buildCard(context, screenSize, cardWidth, cardHeight);
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Size screenSize,
    double cardWidth,
    double cardHeight,
  ) {
    final isLanded = controller.isLanded;
    final isSettled = controller.isSettled;

    // ── Curved flight path ──────────────────────────────────────────────────
    //
    // The card starts at (startDx, startDy) in screen-relative coordinates
    // (negative = off screen). The path curves: it doesn't travel in a
    // straight line — the X component uses a slightly different curve than
    // Y, producing a natural arc like a thrown card.

    final flightT = controller.flightCurved.value; // easeOutExpo 0→1

    // Slower X deceleration vs faster Y gives a curving arc.
    final arcTx = Curves.easeOutCubic.transform(flightT.clamp(0.0, 1.0));
    final arcTy = flightT.clamp(0.0, 1.0);

    final startDx = SplashAnimationConstants.flightStartDx * screenSize.width;
    final startDy = SplashAnimationConstants.flightStartDy * screenSize.height;

    // During flight: interpolate from off-screen toward 0,0 (center).
    // After landing: idle float takes over.
    double dx;
    double dy;

    if (!isLanded) {
      dx = startDx * (1.0 - arcTx);
      dy = startDy * (1.0 - arcTy);
    } else {
      // Bounce adds a tiny upward tick then settles.
      final bounceT = Curves.easeOutBack.transform(
        controller.bounceProgress,
      );
      dy = startDy * 0 + (-6.0 * (1.0 - bounceT)); // 6px upward on land
      dx = 0;

      if (isSettled) {
        dy = controller.floatOffset.value;
        dx = 0;
      }
    }

    // ── Scale arc ──────────────────────────────────────────────────────────

    final scale = controller.cardScale;

    // ── 3-Axis rotation ────────────────────────────────────────────────────
    //
    // During flight: driven by _rotation controller (TweenSequence with overshoot).
    // After landing: driven by idle floatRotZ only.

    final double rX;
    final double rY;
    final double rZ;

    if (!isLanded) {
      rX = controller.rotX.value;
      rY = controller.rotY.value;
      rZ = controller.rotZ.value;
    } else if (!isSettled) {
      // Snap remaining rotation to rest during bounce.
      final t = controller.bounceProgress;
      rX = controller.rotX.value * (1.0 - t);
      rY = controller.rotY.value * (1.0 - t);
      rZ = controller.rotZ.value * (1.0 - t);
    } else {
      rX = 0;
      rY = 0;
      rZ = controller.floatRotZ.value;
    }

    // ── Matrix4 transform ──────────────────────────────────────────────────
    //
    // setEntry(3,2, perspective) sets the vanishing-point depth so that
    // rotating X/Y actually reveals the card's edge — giving it thickness.

    final transform = Matrix4.identity()
      ..setEntry(3, 2, SplashAnimationConstants.perspective)
      ..translateByDouble(dx, dy, 0.0, 1.0)
      ..rotateX(rX)
      ..rotateY(rY)
      ..rotateZ(rZ)
      ..scaleByDouble(scale, scale, 1.0, 1.0);

    // ── Shadow — shifts with perspective ───────────────────────────────────

    final shadowOffset = Offset(
      12.0 * (1.0 - flightT.clamp(0.0, 1.0)),
      18.0 + 10.0 * flightT.clamp(0.0, 1.0),
    );
    final impactV = controller.impactPulse.value;
    final glowV = controller.cardGlow;

    return Opacity(
      opacity: controller.cardOpacity,
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              // Depth shadow — offset drops as card approaches.
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 20 + flightT * 34,
                spreadRadius: 2 + impactV * 6,
                offset: shadowOffset,
              ),
              // Emerald glow that grows on approach + pulses at rest.
              BoxShadow(
                color: SplashAnimationConstants.emerald.withValues(
                  alpha: (0.08 + glowV * 0.32).clamp(0.0, 1.0),
                ),
                blurRadius: 28 + glowV * 40,
                spreadRadius: glowV * 8,
              ),
              // Gold rim light on impact.
              if (impactV > 0)
                BoxShadow(
                  color: SplashAnimationConstants.gold.withValues(
                    alpha: impactV * 0.4,
                  ),
                  blurRadius: 20 + impactV * 20,
                  spreadRadius: impactV * 4,
                ),
            ],
          ),
          child: HeroCard(glow: glowV),
        ),
      ),
    );
  }
}
