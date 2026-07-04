/// The gilded Three of Clubs hero card.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({required this.glow, super.key});

  final double glow;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight;
          final clubWidth = cardWidth * 0.28;
          final clubHeight = clubWidth * (140 / 120);
          final spacing = cardHeight * 0.228;
          final centerY = cardHeight / 2;

          Widget clubAt(double y) => Positioned(
            left: (cardWidth - clubWidth) / 2,
            top: y - clubHeight / 2,
            width: clubWidth,
            height: clubHeight,
            child: SvgPicture.asset(
              'assets/icons/club.svg',
              // Kept explicit: the club must preserve its authored aspect ratio.
              // ignore: avoid_redundant_argument_values
              fit: BoxFit.contain,
            ),
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _HeroCardPainter(glow: glow)),
              clubAt(centerY - spacing),
              clubAt(centerY),
              clubAt(centerY + spacing),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCardPainter extends CustomPainter {
  const _HeroCardPainter({required this.glow});
  final double glow;

  // ── Palette from reference ─────────────────────────────────────────────────
  static const Color _baseDark = Color(0xFF0F1F1A);
  static const Color _baseMid = Color(0xFF1F3B2E);
  static const Color _emerald = Color(0xFF00FFB2);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _goldBright = Color(0xFFFFD166);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // 16dp corner radius as per spec — scale proportionally to card width.
    final cornerR = Radius.circular(size.width * 0.071); // ≈16dp at 226px wide
    final outerRRect = RRect.fromRectAndRadius(rect.deflate(1.5), cornerR);

    // ── 1. Emerald outer glow bloom (behind everything) ─────────────────────
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..color = _emerald.withValues(alpha: 0.18 + glow * 0.30)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + glow * 14),
    );

    // ── 2. Card face — dark green radial gradient ────────────────────────────
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.1,
          colors: [_baseMid, _baseDark, Color(0xFF060F0B)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // ── 3. Subtle diagonal sheen (gives the card depth / material feel) ──────
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.04),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.02),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    // ── 4. Outer border — gold, 2.5dp ────────────────────────────────────────
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_goldBright, _gold, Color(0xFF8A6A00), _gold, _goldBright],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(rect),
    );

    // ── 5. Inner border — gold, 1.5dp, inset 9px ────────────────────────────
    final innerR = Radius.circular(cornerR.x * 0.72);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(9), innerR),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _gold.withValues(alpha: 0.70),
    );

    // ── 6. Corner tech / circuit decorations ─────────────────────────────────
    _drawCornerDecor(canvas, size);

    // ── 7. Top-left index: "3" + "♣" ─────────────────────────────────────────
    _drawIndex(canvas, size, mirrored: false);

    // ── 8. Bottom-right index: rotated 180° ──────────────────────────────────
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(math.pi);
    _drawIndex(canvas, size, mirrored: true);
    canvas.restore();
  }

  // ── Index label (top-left, or bottom-right via caller's canvas transform) ──

  void _drawIndex(Canvas canvas, Size size, {required bool mirrored}) {
    final glowShadow = Shadow(
      color: _emerald.withValues(alpha: 0.85 + glow * 0.15),
      blurRadius: 8 + glow * 8,
    );

    // "3"
    final numPainter = TextPainter(
      text: TextSpan(
        text: '3',
        style: TextStyle(
          color: _emerald,
          fontSize: size.width * 0.155,
          fontWeight: FontWeight.w700,
          height: 1.0,
          shadows: [glowShadow],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // "♣"
    final suitPainter = TextPainter(
      text: TextSpan(
        text: '♣',
        style: TextStyle(
          color: _emerald,
          fontSize: size.width * 0.10,
          fontWeight: FontWeight.w700,
          height: 1.0,
          shadows: [glowShadow],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const originX = 13.0;
    const originY = 12.0;

    numPainter.paint(canvas, const Offset(originX, originY));
    suitPainter.paint(
      canvas,
      Offset(
        originX + (numPainter.width - suitPainter.width) / 2,
        originY + numPainter.height + 1,
      ),
    );
  }

  // ── Ornate corner flourishes matching the reference card ─────────────────

  void _drawCornerDecor(Canvas canvas, Size size) {
    // Two paint levels: bright gold for main bracket, dimmer for fill detail.
    final mainPaint = Paint()
      ..color = _gold.withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final detailPaint = Paint()
      ..color = _gold.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;

    // Place bracket origin just inside the inner border (inset 11px).
    const inset = 11.0;
    final arm = size.width * 0.092; // length of each bracket arm

    for (final corner in _cornerOrigins(size, inset)) {
      _drawOrnateBracket(
        canvas,
        mainPaint,
        detailPaint,
        corner.$1,
        corner.$2,
        arm,
      );
    }
  }

  List<(Offset, _CornerDir)> _cornerOrigins(Size size, double inset) => [
    (Offset(inset, inset), _CornerDir.topLeft),
    (Offset(size.width - inset, inset), _CornerDir.topRight),
    (Offset(inset, size.height - inset), _CornerDir.bottomLeft),
    (Offset(size.width - inset, size.height - inset), _CornerDir.bottomRight),
  ];

  void _drawOrnateBracket(
    Canvas canvas,
    Paint main,
    Paint detail,
    Offset o,
    _CornerDir dir,
    double arm,
  ) {
    final sx = (dir == _CornerDir.topLeft || dir == _CornerDir.bottomLeft)
        ? 1.0
        : -1.0;
    final sy = (dir == _CornerDir.topLeft || dir == _CornerDir.topRight)
        ? 1.0
        : -1.0;

    // ── Main L-bracket ────────────────────────────────────────────────────────
    final path = Path()
      ..moveTo(o.dx, o.dy + sy * arm)
      ..lineTo(o.dx, o.dy)
      ..lineTo(o.dx + sx * arm, o.dy);
    canvas.drawPath(path, main);

    // ── Tick marks at arm midpoints (circuit board feel) ─────────────────────
    canvas.drawLine(
      Offset(o.dx, o.dy + sy * arm * 0.50),
      Offset(o.dx + sx * arm * 0.20, o.dy + sy * arm * 0.50),
      detail,
    );
    canvas.drawLine(
      Offset(o.dx + sx * arm * 0.50, o.dy),
      Offset(o.dx + sx * arm * 0.50, o.dy + sy * arm * 0.20),
      detail,
    );

    // ── Small square jewel dot at the corner vertex ───────────────────────────
    const dotR = 2.2;
    canvas.drawRect(
      Rect.fromCenter(center: o, width: dotR * 2, height: dotR * 2),
      Paint()..color = _goldBright.withValues(alpha: 0.90),
    );

    // ── Tiny flourish curl at arm tips ────────────────────────────────────────
    // Vertical arm tip — small outward tick.
    final vtx = o.dx + sx * arm * 0.18;
    final vty = o.dy + sy * arm;
    canvas.drawLine(
      Offset(vtx - sx * 2, vty),
      Offset(vtx + sx * 3, vty),
      detail,
    );
    // Horizontal arm tip — small outward tick.
    final htx = o.dx + sx * arm;
    final hty = o.dy + sy * arm * 0.18;
    canvas.drawLine(
      Offset(htx, hty - sy * 2),
      Offset(htx, hty + sy * 3),
      detail,
    );

    // ── Diagonal inner filigree line ──────────────────────────────────────────
    canvas.drawLine(
      Offset(o.dx + sx * arm * 0.30, o.dy + sy * arm * 0.04),
      Offset(o.dx + sx * arm * 0.04, o.dy + sy * arm * 0.30),
      detail,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroCardPainter old) => old.glow != glow;
}

enum _CornerDir { topLeft, topRight, bottomLeft, bottomRight }
