/// The gilded Three of Clubs hero card.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({required this.glow, super.key});

  final double glow;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _HeroCardPainter(glow: glow),
        size: Size.infinite,
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

    // ── 9. Three center pip clubs, vertically aligned ────────────────────────
    _drawCenterPips(canvas, size);
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

  // ── Three vertically-aligned center pip clubs ──────────────────────────────

  void _drawCenterPips(Canvas canvas, Size size) {
    // Larger pips matching the reference — 28% of card width.
    final pipSize = size.width * 0.28;
    // Tighter vertical spacing so all three fit comfortably.
    final spacing = size.height * 0.228;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final positions = [
      Offset(centerX, centerY - spacing),
      Offset(centerX, centerY),
      Offset(centerX, centerY + spacing),
    ];

    for (final pos in positions) {
      _drawClubPip(canvas, pos, pipSize);
    }
  }

  // ── Draws a single premium club pip centered at [center] with diameter [size]

  void _drawClubPip(Canvas canvas, Offset center, double size) {
    final r = size / 2;

    // ── 1. Wide outer glow (soft emerald bloom behind everything) ────────────
    canvas.drawCircle(
      center,
      r * 1.7,
      Paint()
        ..color = _emerald.withValues(alpha: 0.16 + glow * 0.20)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + glow * 12),
    );

    // Club geometry — fuller lobes matching the reference silhouette.
    // circleR is larger (0.48 vs old 0.44) for rounder, leaf-like lobes.
    final circleR = r * 0.48;
    final topCenter  = center.translate(0,       -r * 0.24);
    final leftCenter = center.translate(-r * 0.36, r * 0.14);
    final rightCenter= center.translate( r * 0.36, r * 0.14);
    final stemW      = r * 0.20;
    final stemTop    = center.dy + r * 0.32;
    final stemBottom = center.dy + r * 0.74;
    final flareW     = r * 0.58;
    final flareH     = r * 0.17;

    // Full club silhouette path.
    final clubPath = Path()
      ..addOval(Rect.fromCircle(center: topCenter,   radius: circleR))
      ..addOval(Rect.fromCircle(center: leftCenter,  radius: circleR))
      ..addOval(Rect.fromCircle(center: rightCenter, radius: circleR))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(
          center.dx - stemW, stemTop, center.dx + stemW, stemBottom,
        ),
        Radius.circular(stemW),
      ))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, stemBottom),
          width:  flareW * 2,
          height: flareH * 2,
        ),
        Radius.circular(flareH),
      ));

    // ── 2. Gradient fill: vivid bright highlight → rich mid → deep dark core ──
    canvas.save();
    canvas.clipPath(clubPath);
    final gradRect = Rect.fromCenter(center: center, width: size, height: size);
    canvas.drawRect(
      gradRect,
      Paint()
        ..shader = const RadialGradient(
          // Highlight offset top-left, matching the reference's light source.
          center: Alignment(-0.15, -0.40),
          radius: 0.95,
          colors: [
            Color(0xFFAAFFE0), // bright near-white emerald specular
            Color(0xFF00FFB2), // vivid emerald
            Color(0xFF00D494), // mid green
            Color(0xFF00804A), // deep mid
            Color(0xFF004A2A), // dark core
          ],
          stops: [0.0, 0.18, 0.45, 0.72, 1.0],
        ).createShader(gradRect),
    );

    // ── 3. Inner specular hot spot (white-ish) on top lobe ───────────────────
    canvas.drawCircle(
      topCenter.translate(-circleR * 0.18, -circleR * 0.22),
      circleR * 0.42,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22 + glow * 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.restore();

    // ── 4. Gold ring outline — gradient shimmer around the full club ──────────
    final strokeW = r * 0.16;
    canvas.drawPath(
      clubPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _goldBright.withValues(alpha: 1.0),
            _gold.withValues(alpha: 0.85),
            const Color(0xFF8A6A00).withValues(alpha: 0.70),
            _gold.withValues(alpha: 0.85),
            _goldBright.withValues(alpha: 1.0),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(
          Rect.fromCenter(center: center, width: size + strokeW, height: size + strokeW),
        ),
    );

    // ── 5. Gold specular arc on top lobe (catches the light) ─────────────────
    canvas.drawArc(
      Rect.fromCircle(center: topCenter, radius: circleR * 0.65),
      -2.6,
      1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.11
        ..color = _goldBright.withValues(alpha: 0.80 + glow * 0.20)
        ..strokeCap = StrokeCap.round,
    );

    // ── 6. Sparkle particles — 8 alternating gold/emerald at two radii ────────
    const angles = [0.0, 0.785, 1.571, 2.356, 3.142, 3.927, 4.712, 5.498];
    for (var i = 0; i < angles.length; i++) {
      final isGold  = i.isEven;
      final dist    = r * (isGold ? 1.32 : 1.55);
      final sparkPos = Offset(
        center.dx + math.cos(angles[i]) * dist,
        center.dy + math.sin(angles[i]) * dist,
      );
      final sparkColor = isGold ? _goldBright : _emerald;
      final sparkR     = r * (isGold ? 0.072 : 0.052);
      final alpha      = (0.80 + glow * 0.20) * (isGold ? 1.0 : 0.85);

      // Soft halo.
      canvas.drawCircle(
        sparkPos, sparkR * 3.2,
        Paint()
          ..color = sparkColor.withValues(alpha: alpha * 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Solid dot.
      canvas.drawCircle(
        sparkPos, sparkR,
        Paint()..color = sparkColor.withValues(alpha: alpha),
      );
    }
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
    final arm   = size.width * 0.092; // length of each bracket arm

    for (final corner in _cornerOrigins(size, inset)) {
      _drawOrnateBracket(canvas, mainPaint, detailPaint, corner.$1, corner.$2, arm);
    }
  }

  List<(Offset, _CornerDir)> _cornerOrigins(Size size, double inset) => [
    (Offset(inset, inset),                          _CornerDir.topLeft),
    (Offset(size.width - inset, inset),             _CornerDir.topRight),
    (Offset(inset, size.height - inset),            _CornerDir.bottomLeft),
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
    final sx = (dir == _CornerDir.topLeft || dir == _CornerDir.bottomLeft) ? 1.0 : -1.0;
    final sy = (dir == _CornerDir.topLeft || dir == _CornerDir.topRight)   ? 1.0 : -1.0;

    // ── Main L-bracket ────────────────────────────────────────────────────────
    final path = Path()
      ..moveTo(o.dx,            o.dy + sy * arm)
      ..lineTo(o.dx,            o.dy)
      ..lineTo(o.dx + sx * arm, o.dy);
    canvas.drawPath(path, main);

    // ── Tick marks at arm midpoints (circuit board feel) ─────────────────────
    canvas.drawLine(
      Offset(o.dx,                    o.dy + sy * arm * 0.50),
      Offset(o.dx + sx * arm * 0.20,  o.dy + sy * arm * 0.50),
      detail,
    );
    canvas.drawLine(
      Offset(o.dx + sx * arm * 0.50,  o.dy),
      Offset(o.dx + sx * arm * 0.50,  o.dy + sy * arm * 0.20),
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
