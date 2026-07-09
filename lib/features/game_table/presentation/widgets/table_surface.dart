/// Premium casino-style rounded-rectangle table surface via CustomPainter.
///
/// Features a realistic felt gradient, thick metallic gold border,
/// wooden rim effect, casino spotlight, inner shadow vignette,
/// fine felt texture, and perspective depth hint.
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

    // ── Table dimensions ───────────────────────────────────────────────
    final tableWidth = size.width * 0.82;
    final tableHeight = size.height * 0.67;
    final borderRadius = Radius.circular(size.height * 0.08);

    // Main table rect
    final tableRect = Rect.fromCenter(
      center: center,
      width: tableWidth,
      height: tableHeight,
    );
    final tableRRect = RRect.fromRectAndRadius(tableRect, borderRadius);

    // Wood rim (slightly larger)
    final rimRect = Rect.fromCenter(
      center: center,
      width: tableWidth + 14,
      height: tableHeight + 14,
    );
    final rimRRect = RRect.fromRectAndRadius(
      rimRect,
      borderRadius * 1.08,
    );

    // Outer shadow rect
    final outerRect = Rect.fromCenter(
      center: center,
      width: tableWidth + 20,
      height: tableHeight + 20,
    );
    final outerRRect = RRect.fromRectAndRadius(
      outerRect,
      borderRadius * 1.12,
    );

    // ── 1. Outer glow ──────────────────────────────────────────────────
    final glowPaint = Paint()
      ..color = SplashAnimationConstants.emerald.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: tableWidth + 60,
          height: tableHeight + 60,
        ),
        borderRadius * 1.3,
      ),
      glowPaint,
    );

    // ── 2. Table drop shadow ───────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, 6),
          width: tableWidth + 16,
          height: tableHeight + 16,
        ),
        borderRadius * 1.1,
      ),
      shadowPaint,
    );

    // ── 3. Wood rim ────────────────────────────────────────────────────
    // Dark wood band between outer border and felt
    final rimPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.1),
        radius: 1.2,
        colors: const [
          Color(0xFF2A1A0C), // Lighter wood center
          Color(0xFF1A0E05), // Dark wood edge
          Color(0xFF110A03), // Very dark rim bottom
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rimRect);
    canvas.drawRRect(rimRRect, rimPaint);

    // Wood grain lines (very subtle)
    final grainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4
      ..color = const Color(0x0DFFFFFF);
    canvas.save();
    canvas.clipRRect(rimRRect);
    // Exclude the inner felt area from grain
    for (int i = 0; i < 8; i++) {
      final yOffset = rimRect.top + (rimRect.height * (i / 8.0));
      canvas.drawLine(
        Offset(rimRect.left, yOffset),
        Offset(rimRect.right, yOffset),
        grainPaint,
      );
    }
    canvas.restore();

    // ── 4. Main felt surface (radial gradient) ─────────────────────────
    final feltPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.12),
        radius: 1.0,
        colors: const [
          Color(0xFF12573D), // Warm bright center
          Color(0xFF0F4D35), // Mid felt
          Color(0xFF0A3D2A), // Darker ring
          Color(0xFF072E1F), // Deep edge
          Color(0xFF052518), // Darkest edge
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(tableRect);
    canvas.drawRRect(tableRRect, feltPaint);

    // ── 5. Casino spotlight ────────────────────────────────────────────
    // Simulates overhead lighting hitting the center of the table
    final spotlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.2),
        radius: 0.6,
        colors: [
          Colors.white.withValues(alpha: 0.04),
          Colors.white.withValues(alpha: 0.015),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(tableRect);
    canvas.save();
    canvas.clipRRect(tableRRect);
    canvas.drawRect(tableRect, spotlightPaint);
    canvas.restore();

    // ── 6. Inner shadow / vignette ─────────────────────────────────────
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.08),
          Colors.black.withValues(alpha: 0.22),
          Colors.black.withValues(alpha: 0.4),
        ],
        stops: const [0.4, 0.65, 0.85, 1.0],
      ).createShader(tableRect);
    canvas.save();
    canvas.clipRRect(tableRRect);
    canvas.drawRect(tableRect, vignettePaint);
    canvas.restore();

    // ── 7. Inner highlight ring ────────────────────────────────────────
    final innerRect = Rect.fromCenter(
      center: center,
      width: tableWidth * 0.88,
      height: tableHeight * 0.84,
    );
    final innerRRect = RRect.fromRectAndRadius(innerRect, borderRadius * 0.82);
    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = SplashAnimationConstants.emerald.withValues(alpha: 0.05);
    canvas.drawRRect(innerRRect, innerRingPaint);

    // ── 8. Felt texture ────────────────────────────────────────────────
    final texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.25
      ..color = const Color(0x03FFFFFF);

    canvas.save();
    canvas.clipRRect(tableRRect);
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * math.pi;
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      final halfW = tableWidth * 0.44;
      final halfH = tableHeight * 0.44;
      canvas.drawLine(
        Offset(center.dx - dx * halfW, center.dy - dy * halfH),
        Offset(center.dx + dx * halfW, center.dy + dy * halfH),
        texturePaint,
      );
    }
    canvas.restore();

    // ── 9. Gold border (thick metallic) ────────────────────────────────
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          SplashAnimationConstants.gold.withValues(alpha: 0.85),
          SplashAnimationConstants.brightGold.withValues(alpha: 0.65),
          SplashAnimationConstants.gold.withValues(alpha: 0.9),
          SplashAnimationConstants.brightGold.withValues(alpha: 0.55),
          SplashAnimationConstants.gold.withValues(alpha: 0.85),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(tableRect);
    canvas.drawRRect(tableRRect, borderPaint);

    // ── 10. Gold edge highlights ───────────────────────────────────────
    // Top-left bright highlight
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = SplashAnimationConstants.brightGold.withValues(alpha: 0.25);
    // Draw just the top portion of the border for a specular highlight
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(
      tableRect.left,
      tableRect.top - 2,
      tableRect.right * 0.6,
      tableRect.top + tableHeight * 0.3,
    ));
    canvas.drawRRect(tableRRect, highlightPaint);
    canvas.restore();

    // ── 11. Outer rim gold accent ──────────────────────────────────────
    final outerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = SplashAnimationConstants.gold.withValues(alpha: 0.1);
    canvas.drawRRect(outerRRect, outerBorderPaint);

    // ── 12. Bottom perspective shadow ──────────────────────────────────
    final perspectivePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(
      Offset(tableRect.left + tableWidth * 0.12, rimRect.bottom),
      Offset(tableRect.right - tableWidth * 0.12, rimRect.bottom),
      perspectivePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
