/// Animation constants for consistent timing and curves.
library;

import 'package:flutter/material.dart';

class AnimationConstants {
  AnimationConstants._();

  // === Durations ===
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  static const Duration dramatic = Duration(milliseconds: 1200);

  // === Card-specific Durations ===
  static const Duration cardFlip = Duration(milliseconds: 400);
  static const Duration cardDeal = Duration(milliseconds: 300);
  static const Duration cardShuffle = Duration(milliseconds: 600);
  static const Duration cardFan = Duration(milliseconds: 500);

  // === Curves ===
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeOutExpo;
  static const Curve smoothCurve = Curves.easeInOutQuart;
  static const Curve springCurve = Curves.easeOutBack;
  static const Curve cardCurve = Curves.easeInOutCubic;

  // === Stagger Delays ===
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration cardStaggerDelay = Duration(milliseconds: 80);
}
