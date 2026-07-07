/// Utility class that computes seat positions around an elliptical table.
///
/// Player 0 (local player) is always at the bottom center (6 o'clock position).
/// Remaining players are distributed clockwise starting from bottom-right.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

class SeatLayoutCalculator {
  SeatLayoutCalculator._();

  /// Computes [playerCount] positions arranged around an ellipse.
  ///
  /// The ellipse is centered at [center] with semi-axes [radiusX] and [radiusY].
  /// Player 0 is always at the bottom (angle = π/2).
  /// Remaining players are spaced clockwise.
  static List<Offset> computeSeats({
    required Offset center,
    required double radiusX,
    required double radiusY,
    required int playerCount,
  }) {
    final List<Offset> seats = [];
    final double angleStep = (2 * math.pi) / playerCount;

    for (int i = 0; i < playerCount; i++) {
      // Start at π/2 (bottom center) and go clockwise
      // Clockwise in screen coordinates means increasing angle
      final double angle = (math.pi / 2) + (i * angleStep);

      final double x = center.dx + radiusX * math.cos(angle);
      final double y = center.dy + radiusY * math.sin(angle);

      seats.add(Offset(x, y));
    }

    return seats;
  }
}
