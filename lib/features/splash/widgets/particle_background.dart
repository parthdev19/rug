/// Low-cost deterministic ambient and impact particles.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({
    required this.entryAnimation,
    required this.floatAnimation,
    required this.impactAnimation,
    super.key,
  });

  final Animation<double> entryAnimation;
  final Animation<double> floatAnimation;
  final Animation<double> impactAnimation;

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> {
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = math.Random(3);
    _particles = List.generate(
      SplashAnimationConstants.particleCount.toInt(),
      (_) => _Particle(
        x: random.nextDouble(),
        y: 0.30 + random.nextDouble() * 0.62,
        speed: 0.018 + random.nextDouble() * 0.035,
        radius: 0.6 + random.nextDouble() * 1.5,
        opacity: 0.10 + random.nextDouble() * 0.34,
        phase: random.nextDouble() * math.pi * 2,
        gold: random.nextDouble() > 0.78,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.entryAnimation,
          widget.floatAnimation,
          widget.impactAnimation,
        ]),
        builder: (context, child) => CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            // Use floatAnimation as the continuous drift driver post-entry.
            progress: widget.entryAnimation.value +
                widget.floatAnimation.value * 0.4,
            impact: widget.impactAnimation.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.opacity,
    required this.phase,
    required this.gold,
  });
  final double x;
  final double y;
  final double speed;
  final double radius;
  final double opacity;
  final double phase;
  final bool gold;
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.impact,
  });
  final List<_Particle> particles;
  final double progress;
  final double impact;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final drift = math.sin(particle.phase + progress * math.pi * 2) * 7;
      final y = ((particle.y - progress * particle.speed) % 1) * size.height;
      final position = Offset(particle.x * size.width + drift, y);
      final twinkle = 0.62 + math.sin(particle.phase + progress * 18) * 0.38;
      final color = particle.gold
          ? SplashAnimationConstants.gold
          : SplashAnimationConstants.emerald;
      final alpha = particle.opacity * twinkle * (0.65 + impact * 0.35);
      canvas.drawCircle(
        position,
        particle.radius * (1 + impact * 0.45),
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress || old.impact != impact;
}
