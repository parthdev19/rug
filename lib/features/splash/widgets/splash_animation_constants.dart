/// Visual and timing constants for the RUG splash sequence.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashAnimationConstants {
  SplashAnimationConstants._();

  // ── Durations ────────────────────────────────────────────────────────────

  /// Background + logo entrance.
  static const Duration entryDuration = Duration(milliseconds: 600);

  /// Card flies from off-screen to center.
  static const Duration flightDuration = Duration(milliseconds: 850);

  /// Delay before the card deal begins (after entry starts).
  static const Duration dealDelay = Duration(milliseconds: 500);

  /// Bounce/settle after card lands.
  static const Duration bounceDuration = Duration(milliseconds: 380);

  /// Idle float loop period.
  static const Duration floatDuration = Duration(milliseconds: 2800);

  /// Glow pulse loop period.
  static const Duration glowPulseDuration = Duration(milliseconds: 1600);

  // ── Card Geometry ─────────────────────────────────────────────────────────

  static const double cardAspectRatio = 0.64;
  static const double particleCount = 26;

  /// Perspective entry for Matrix4 — gives the card physical thickness.
  static const double perspective = 0.0018;

  // ── 3D Rotation Arcs (radians) ────────────────────────────────────────────
  //
  // The card is thrown from the dealer's upper-left, so it tumbles:
  //   RotateY: -65° → +25° → 0°  (card face sweeps from hidden to visible)
  //   RotateX:  18° →  -6° → 0°  (top edge tips forward on impact)
  //   RotateZ: -20° →  +5° → 0°  (counter-clockwise throw arc)

  static final double rotYStart = _deg(-65);
  static final double rotYLand = _deg(25);
  static const double rotYRest = 0.0;

  static final double rotXStart = _deg(18);
  static final double rotXLand = _deg(-6);
  static const double rotXRest = 0.0;

  static final double rotZStart = _deg(-20);
  static final double rotZLand = _deg(5);
  static const double rotZRest = 0.0;

  // ── Scale Arc ─────────────────────────────────────────────────────────────

  /// Card spawns at this scale (far away, off-screen).
  static const double scaleStart = 0.40;

  /// Peaks slightly above 1.0 on arrival for a dramatic "rushing in" feel.
  static const double scalePeak = 1.15;

  /// Final resting scale.
  static const double scaleRest = 1.00;

  // ── Flight Path ───────────────────────────────────────────────────────────

  /// Card enters from upper-left, beyond the screen boundary.
  /// Expressed as multiples of screen width/height (negative = off-screen).
  static const double flightStartDx = -1.4; // screen widths from center
  static const double flightStartDy = -1.6; // screen heights from center

  // ── Ambient / Idle ────────────────────────────────────────────────────────

  /// Max pixel drift of the idle float.
  static const double maxAmbientOffset = 3.0;

  /// Max idle rotation (≈ 0.5°).
  static const double maxAmbientRotation = 0.00873; // 0.5° in radians

  /// Idle breathing scale amplitude (1.00 ↔ 1.02).
  static const double breatheAmplitude = 0.02;

  // ── Colors ────────────────────────────────────────────────────────────────

  static const Color background = Color(0xFF050807);
  static const Color backgroundGreen = Color(0xFF07150E);
  static const Color emerald = Color(0xFF4BFF8A);
  static const Color deepEmerald = Color(0xFF073F25);
  static const Color gold = Color(0xFFE7C463);
  static const Color brightGold = Color(0xFFFFE59A);
  static const Color ivory = Color(0xFFF4F0E6);

  // ── Curves ────────────────────────────────────────────────────────────────

  /// Fast initial throw velocity, decelerates heavily on approach.
  static const Curve flightCurve = Curves.easeOutExpo;

  /// Overshoot past landing position, then snap back.
  static const Curve overshootCurve = _OvershootCurve(tension: 4.0);

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _deg(double degrees) => degrees * (math.pi / 180);
}

/// Custom spring-overshoot curve.
/// At t=0.85 it reaches ~1.08 (8% overshoot), then settles to 1.0 at t=1.
class _OvershootCurve extends Curve {
  const _OvershootCurve({required this.tension});

  final double tension;

  @override
  double transformInternal(double t) {
    // Quintic ease-out with a tunable overshoot pocket.
    return 1 +
        (tension + 1) *
            math.pow(t - 1, 3).toDouble() +
        tension * math.pow(t - 1, 2).toDouble();
  }
}
