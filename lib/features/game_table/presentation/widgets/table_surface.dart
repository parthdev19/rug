/// Premium oval card table surface painted via CustomPainter.
///
/// Features a deep emerald felt gradient, gold border,
/// inner highlight ring, and a soft outer glow.
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
    final radiusX = size.width * 0.42;
    final radiusY = size.height * 0.38;

    // ── 1. Outer glow ──────────────────────────────────────────────────
    final glowPaint = Paint()
      ..color = SplashAnimationConstants.emerald.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radiusX * 2.25, height: radiusY * 2.25),
      glowPaint,
    );

    // ── 2. Table shadow ────────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, 4),
        width: radiusX * 2.06,
        height: radiusY * 2.06,
      ),
      shadowPaint,
    );

    // ── 3. Main felt surface (radial gradient) ─────────────────────────
    final feltRect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );
    final feltPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.2),
        radius: 1.0,
        colors: [
          const Color(0xFF0F4D35), // Brighter center
          const Color(0xFF0A3D2A), // Mid emerald
          const Color(0xFF072E1F), // Deep edge
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(feltRect);
    canvas.drawOval(feltRect, feltPaint);

    // ── 4. Inner highlight ring (subtle depth) ─────────────────────────
    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = SplashAnimationConstants.emerald.withValues(alpha: 0.08);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radiusX * 1.7,
        height: radiusY * 1.7,
      ),
      innerRingPaint,
    );

    // ── 5. Felt texture lines (very subtle) ────────────────────────────
    final texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3
      ..color = Colors.white.withValues(alpha: 0.02);

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * math.pi;
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      canvas.drawLine(
        Offset(center.dx - dx * radiusX * 0.8, center.dy - dy * radiusY * 0.8),
        Offset(center.dx + dx * radiusX * 0.8, center.dy + dy * radiusY * 0.8),
        texturePaint,
      );
    }

    // ── 6. Gold border ─────────────────────────────────────────────────
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
      ).createShader(feltRect);
    canvas.drawOval(feltRect, borderPaint);

    // ── 7. Outer secondary border (very thin, for depth) ───────────────
    final outerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = SplashAnimationConstants.gold.withValues(alpha: 0.15);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radiusX * 2.06,
        height: radiusY * 2.06,
      ),
      outerBorderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
