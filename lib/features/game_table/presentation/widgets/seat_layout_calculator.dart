/// Named-position seat calculator for 5–9 players around a rounded-rectangle table.
///
/// Each player count has explicit named positions (bottomCenter, leftCenter,
/// topLeft, topCenter, etc.) defined as fractional offsets from the table center.
/// Player 0 is always at bottom-center (current user).
library;

import 'package:flutter/material.dart';

class SeatLayoutCalculator {
  SeatLayoutCalculator._();

  /// Computes seat positions for [playerCount] players around a table.
  ///
  /// Positions are absolute pixel offsets. The table is centered at [center]
  /// with dimensions [tableWidth] × [tableHeight].
  static List<Offset> computeSeats({
    required Offset center,
    required double tableWidth,
    required double tableHeight,
    required int playerCount,
  }) {
    final halfW = tableWidth / 2;
    final halfH = tableHeight / 2;

    // Named position offsets relative to center.
    // Seats sit ON the table edge so avatars slightly overlap the border.
    // Y values: positive = below center, negative = above center.
    // X values: positive = right of center, negative = left of center.

    Offset pos(double xFraction, double yFraction) {
      return Offset(
        center.dx + halfW * xFraction,
        center.dy + halfH * yFraction,
      );
    }

    return switch (playerCount) {
      5 => [
        // 0: Bottom Center (current user)
        pos(0.0, 1.0),
        // 1: Right Center
        pos(1.0, 0.0),
        // 2: Top Center
        pos(0.0, -1.0),
        // 3: Top Left
        pos(-0.65, -1.0),
        // 4: Left Center
        pos(-1.0, 0.0),
      ],
      6 => [
        // 0: Bottom Center
        pos(0.0, 1.0),
        // 1: Right Center
        pos(1.0, 0.0),
        // 2: Top Right
        pos(0.55, -1.0),
        // 3: Top Center
        pos(-0.05, -1.0),
        // 4: Top Left
        pos(-0.60, -1.0),
        // 5: Left Center
        pos(-1.0, 0.0),
      ],
      7 => [
        // 0: Bottom Center
        pos(0.0, 1.0),
        // 1: Right Center
        pos(1.0, 0.0),
        // 2: Top Right
        pos(0.68, -1.0),
        // 3: Top Center Right
        pos(0.22, -1.0),
        // 4: Top Center Left
        pos(-0.22, -1.0),
        // 5: Top Left
        pos(-0.68, -1.0),
        // 6: Left Center
        pos(-1.0, 0.0),
      ],
      8 => [
        // 0: Bottom Center
        pos(0.0, 1.0),
        // 1: Bottom Right
        pos(0.75, 0.75),
        // 2: Right Center
        pos(1.0, -0.05),
        // 3: Top Right
        pos(0.58, -1.0),
        // 4: Top Left
        pos(-0.58, -1.0),
        // 5: Left Center
        pos(-1.0, -0.05),
        // 6: Bottom Left
        pos(-0.75, 0.75),
        // 7: Top Center
        pos(0.0, -1.0),
      ],
      9 => [
        // 0: Bottom Center
        pos(0.0, 1.0),
        // 1: Bottom Right
        pos(0.78, 0.70),
        // 2: Right Center
        pos(1.0, -0.05),
        // 3: Top Right
        pos(0.65, -1.0),
        // 4: Top Center Right
        pos(0.20, -1.0),
        // 5: Top Center
        pos(-0.20, -1.0),
        // 6: Top Left
        pos(-0.65, -1.0),
        // 7: Left Center
        pos(-1.0, -0.05),
        // 8: Bottom Left
        pos(-0.78, 0.70),
      ],
      // Fallback: place all at center (shouldn't happen with 5–9 constraint)
      _ => List.generate(playerCount, (_) => center),
    };
  }
}
