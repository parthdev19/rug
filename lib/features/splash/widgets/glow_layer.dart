/// Atmospheric lighting and card-receiving ripple.
///
/// Accepts separate [intensity] (approach glow 0→1) and [pulse] (impact
/// ripple 0→1→0) and [idlePulse] (post-land slow bloom 0→1) so that each
/// phase has independent control without sharing a single parent controller.
library;

import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class GlowLayer extends StatelessWidget {
  const GlowLayer({
    required this.intensity,
    required this.pulse,
    required this.idlePulse,
    super.key,
  });

  /// 0→1 as card approaches (driven by flight progress).
  final double intensity;

  /// 0→1→0 impact burst on landing (driven by bounce controller).
  final double pulse;

  /// 0→1 slow idle bloom after card settles (driven by glowPulse controller).
  final double idlePulse;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GlowPainter(
          intensity: intensity,
          pulse: pulse,
          idlePulse: idlePulse,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter({
    required this.intensity,
    required this.pulse,
    required this.idlePulse,
  });

  final double intensity;
  final double pulse;
  final double idlePulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);

    // ── Atmospheric approach glow ───────────────────────────────────────────
    // Grows from nothing as the card flies in; dims slightly at rest then
    // the idlePulse takes over with a slow bloom.
    final combinedIntensity = intensity + idlePulse * 0.35;
    final glowRadius = size.shortestSide * (0.38 + pulse * 0.09 + idlePulse * 0.06);

    final atmospherePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          SplashAnimationConstants.emerald.withValues(
            alpha: (0.17 * combinedIntensity).clamp(0.0, 1.0),
          ),
          SplashAnimationConstants.deepEmerald.withValues(
            alpha: (0.11 * combinedIntensity).clamp(0.0, 1.0),
          ),
          Colors.transparent,
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));

    canvas.drawCircle(center, glowRadius, atmospherePaint);

    // ── Impact ripple rings ─────────────────────────────────────────────────
    if (pulse <= 0) return;

    final rippleCenter = Offset(center.dx, size.height * 0.75);
    for (var i = 0; i < 3; i++) {
      final phase = (pulse + i * 0.18).clamp(0.0, 1.0);
      final rect = Rect.fromCenter(
        center: rippleCenter,
        width: size.width * (0.30 + phase * 0.58),
        height: 22 + phase * 46,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = SplashAnimationConstants.gold.withValues(
            alpha: (1 - phase) * 0.7,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) =>
      old.intensity != intensity ||
      old.pulse != pulse ||
      old.idlePulse != idlePulse;
}
