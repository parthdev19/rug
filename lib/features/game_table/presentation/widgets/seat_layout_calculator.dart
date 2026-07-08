/// Utility class that computes seat positions around a rounded-rectangle table.
///
/// Player 0 (local player) is always at the bottom center.
/// Remaining players are distributed evenly along the remaining perimeter
/// of the rounded rectangle, walking clockwise from bottom-right.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

class SeatLayoutCalculator {
  SeatLayoutCalculator._();

  /// Computes [playerCount] positions arranged around a rounded rectangle.
  ///
  /// The rectangle is centered at [center] with the given [tableWidth] and
  /// [tableHeight]. Player 0 is always at bottom-center. Remaining players
  /// are spaced evenly along the perimeter clockwise.
  static List<Offset> computeSeats({
    required Offset center,
    required double tableWidth,
    required double tableHeight,
    required int playerCount,
    required double cornerRadius,
  }) {
    if (playerCount <= 0) return [];

    // Table bounds
    final halfW = tableWidth / 2;
    final halfH = tableHeight / 2;
    final r = cornerRadius.clamp(0.0, math.min(halfW, halfH));

    // Compute the total perimeter of the rounded rectangle
    final straightH = (tableWidth - 2 * r); // top and bottom straight edges
    final straightV = (tableHeight - 2 * r); // left and right straight edges
    final cornerArc = math.pi * r / 2; // quarter circle arc length
    final totalPerimeter = 2 * straightH + 2 * straightV + 4 * cornerArc;

    // Build a list of perimeter segments starting from bottom-center,
    // going clockwise. Each segment is (length, function(t) → Offset)
    // where t goes from 0..1 along that segment.
    //
    // Starting point: bottom-center = (center.dx, center.dy + halfH)
    // Clockwise: → bottom-right straight → BR corner arc → right straight ↑
    //            → TR corner arc → top straight ← → TL corner arc
    //            → left straight ↓ → BL corner arc → bottom-left straight →
    //
    // We split the bottom straight into two halves (right half, then later left half).

    final segments = <_Segment>[];

    // Bottom-center to bottom-right corner start
    // Bottom straight right half: from center.dx to center.dx + halfW - r
    segments.add(_Segment(
      length: halfW - r,
      point: (t) => Offset(
        center.dx + t * (halfW - r),
        center.dy + halfH,
      ),
    ));

    // Bottom-right corner arc (quarter circle, clockwise: from bottom to right)
    segments.add(_Segment(
      length: cornerArc,
      point: (t) {
        final angle = (math.pi / 2) - t * (math.pi / 2); // π/2 → 0
        return Offset(
          center.dx + halfW - r + r * math.cos(angle),
          center.dy + halfH - r + r * math.sin(angle),
        );
      },
    ));

    // Right side straight (bottom-right to top-right, going up)
    segments.add(_Segment(
      length: straightV,
      point: (t) => Offset(
        center.dx + halfW,
        center.dy + halfH - r - t * straightV,
      ),
    ));

    // Top-right corner arc (clockwise: from right to top)
    segments.add(_Segment(
      length: cornerArc,
      point: (t) {
        final angle = 0 - t * (math.pi / 2); // 0 → -π/2
        return Offset(
          center.dx + halfW - r + r * math.cos(angle),
          center.dy - halfH + r + r * math.sin(angle),
        );
      },
    ));

    // Top side straight (right to left)
    segments.add(_Segment(
      length: straightH,
      point: (t) => Offset(
        center.dx + halfW - r - t * straightH,
        center.dy - halfH,
      ),
    ));

    // Top-left corner arc (clockwise: from top to left)
    segments.add(_Segment(
      length: cornerArc,
      point: (t) {
        final angle = -math.pi / 2 - t * (math.pi / 2); // -π/2 → -π
        return Offset(
          center.dx - halfW + r + r * math.cos(angle),
          center.dy - halfH + r + r * math.sin(angle),
        );
      },
    ));

    // Left side straight (top-left to bottom-left, going down)
    segments.add(_Segment(
      length: straightV,
      point: (t) => Offset(
        center.dx - halfW,
        center.dy - halfH + r + t * straightV,
      ),
    ));

    // Bottom-left corner arc (clockwise: from left to bottom)
    segments.add(_Segment(
      length: cornerArc,
      point: (t) {
        final angle = math.pi - t * (math.pi / 2); // π → π/2
        return Offset(
          center.dx - halfW + r + r * math.cos(angle),
          center.dy + halfH - r + r * math.sin(angle),
        );
      },
    ));

    // Bottom-left straight back to center
    segments.add(_Segment(
      length: halfW - r,
      point: (t) => Offset(
        center.dx - halfW + r + t * (halfW - r),
        center.dy + halfH,
      ),
    ));

    // Player 0 is at bottom-center
    final seats = <Offset>[
      Offset(center.dx, center.dy + halfH),
    ];

    if (playerCount == 1) return seats;

    // Distribute remaining (playerCount - 1) players evenly along the perimeter.
    // We skip the bottom-center zone (a small gap around player 0).
    const gapFraction = 0.06; // 6% of perimeter is reserved for player 0's zone
    final usablePerimeter = totalPerimeter * (1.0 - gapFraction);
    final startDistance = totalPerimeter * (gapFraction / 2);
    final spacing = usablePerimeter / (playerCount - 1 + 1);
    // +1 so we get even gaps between players AND the edges of the gap zone

    for (int i = 1; i < playerCount; i++) {
      final targetDistance = startDistance + i * spacing;
      seats.add(_pointAtDistance(segments, targetDistance));
    }

    return seats;
  }

  /// Walk along the segments to find the point at a given cumulative distance.
  static Offset _pointAtDistance(List<_Segment> segments, double distance) {
    double remaining = distance;
    for (final seg in segments) {
      if (remaining <= seg.length) {
        final t = seg.length > 0 ? remaining / seg.length : 0.0;
        return seg.point(t);
      }
      remaining -= seg.length;
    }
    // If we overshoot, wrap around or clamp to last point
    return segments.last.point(1.0);
  }
}

class _Segment {
  const _Segment({required this.length, required this.point});
  final double length;
  final Offset Function(double t) point;
}
