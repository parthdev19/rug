/// Premium rounded-rectangle (capsule) card table surface painted via CustomPainter.
///
/// Features a deep emerald felt gradient, metallic gold border,
/// inner shadow vignette, felt texture, and a subtle perspective depth hint.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class TableSurface extends StatelessWidget {
  const TableSurface({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TablePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _TablePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ── Table dimensions (proportional) ────────────────────────────────
    final tableWidth = size.width * 0.82;
    final tableHeight = size.height * 0.67;
    final tableRect = Rect.fromCenter(
      center: center,
      width: tableWidth,
      height: tableHeight,
    );
    final borderRadius = Radius.circular(size.height * 0.08);
    final tableRRect = RRect.fromRectAndRadius(tableRect, borderRadius);

    // Slightly larger RRect for outer effects
    final outerRect = Rect.fromCenter(
      center: center,
      width: tableWidth * 1.03,
      height: tableHeight * 1.04,
    );
    final outerRRect = RRect.fromRectAndRadius(outerRect, borderRadius * 1.1);

    // ── 1. Outer glow ──────────────────────────────────────────────────
    final glowPaint = Paint()
      ..color = SplashAnimationConstants.emerald.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: tableWidth * 1.12,
          height: tableHeight * 1.14,
        ),
        borderRadius * 1.2,
      ),
      glowPaint,
    );

    // ── 2. Table drop shadow ───────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, 4),
          width: tableWidth * 1.03,
          height: tableHeight * 1.04,
        ),
        borderRadius,
      ),
      shadowPaint,
    );

    // ── 3. Main felt surface (radial gradient) ─────────────────────────
    final feltPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.15),
        radius: 1.0,
        colors: const [
          Color(0xFF0F4D35), // Brighter center
          Color(0xFF0A3D2A), // Mid emerald
          Color(0xFF072E1F), // Deep edge
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(tableRect);
    canvas.drawRRect(tableRRect, feltPaint);

    // ── 4. Inner shadow / vignette ─────────────────────────────────────
    // Darker edges to give depth
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.15),
          Colors.black.withValues(alpha: 0.35),
        ],
        stops: const [0.5, 0.8, 1.0],
      ).createShader(tableRect);
    canvas.save();
    canvas.clipRRect(tableRRect);
    canvas.drawRect(tableRect, vignettePaint);
    canvas.restore();

    // ── 5. Inner highlight ring (subtle depth) ─────────────────────────
    final innerRect = Rect.fromCenter(
      center: center,
      width: tableWidth * 0.88,
      height: tableHeight * 0.85,
    );
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      borderRadius * 0.85,
    );
    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = SplashAnimationConstants.emerald.withValues(alpha: 0.06);
    canvas.drawRRect(innerRRect, innerRingPaint);

    // ── 6. Felt texture lines (very subtle cross-hatch) ────────────────
    final texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3
      ..color = const Color(0x04FFFFFF);

    canvas.save();
    canvas.clipRRect(tableRRect);
    for (int i = 0; i < 14; i++) {
      final angle = (i / 14) * math.pi;
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      final halfW = tableWidth * 0.42;
      final halfH = tableHeight * 0.42;
      canvas.drawLine(
        Offset(center.dx - dx * halfW, center.dy - dy * halfH),
        Offset(center.dx + dx * halfW, center.dy + dy * halfH),
        texturePaint,
      );
    }
    canvas.restore();

    // ── 7. Gold border (metallic gradient) ─────────────────────────────
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          SplashAnimationConstants.gold.withValues(alpha: 0.7),
          SplashAnimationConstants.brightGold.withValues(alpha: 0.5),
          SplashAnimationConstants.gold.withValues(alpha: 0.7),
        ],
      ).createShader(tableRect);
    canvas.drawRRect(tableRRect, borderPaint);

    // ── 8. Outer secondary border (depth ring) ─────────────────────────
    final outerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = SplashAnimationConstants.gold.withValues(alpha: 0.12);
    canvas.drawRRect(outerRRect, outerBorderPaint);

    // ── 9. Perspective bottom edge (subtle depth) ──────────────────────
    // A thin darker line at the bottom edge of the table for 3D feel
    final perspectivePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.black.withValues(alpha: 0.3);
    final bottomEdgeRect = Rect.fromLTRB(
      tableRect.left + tableWidth * 0.1,
      tableRect.bottom - 1,
      tableRect.right - tableWidth * 0.1,
      tableRect.bottom,
    );
    canvas.drawLine(
      bottomEdgeRect.topLeft,
      bottomEdgeRect.topRight,
      perspectivePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
