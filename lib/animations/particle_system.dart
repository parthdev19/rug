/// Lightweight particle effect system using CustomPainter.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A single particle.
class Particle {
  Particle({required this.position, required this.velocity, required this.color, required this.size, required this.life});
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life; // 0.0 to 1.0
}

/// Renders a particle burst effect (e.g., win celebration).
class ParticleSystem extends StatefulWidget {
  const ParticleSystem({super.key, this.particleCount = 30, this.colors, this.duration = const Duration(seconds: 2), this.autoStart = true});
  final int particleCount;
  final List<Color>? colors;
  final Duration duration;
  final bool autoStart;

  @override
  State<ParticleSystem> createState() => ParticleSystemState();
}

class ParticleSystemState extends State<ParticleSystem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final _random = math.Random();

  static const _defaultColors = [Color(0xFFFFD700), Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFFFFE66D), Color(0xFF95E1D3)];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.autoStart) start();
  }

  void start() {
    _initParticles();
    _controller.forward(from: 0);
  }

  void _initParticles() {
    _particles.clear();
    final colors = widget.colors ?? _defaultColors;
    for (var i = 0; i < widget.particleCount; i++) {
      _particles.add(Particle(
        position: Offset.zero,
        velocity: Offset((_random.nextDouble() - 0.5) * 300, -_random.nextDouble() * 400 - 100),
        color: colors[_random.nextInt(colors.length)],
        size: _random.nextDouble() * 6 + 2,
        life: 1.0,
      ));
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(particles: _particles, progress: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.progress});
  final List<Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final p in particles) {
      final life = (1 - progress).clamp(0.0, 1.0);
      final pos = center + p.velocity * progress;
      final gravity = Offset(0, 200 * progress * progress);
      final paint = Paint()..color = p.color.withValues(alpha: life)..style = PaintingStyle.fill;
      canvas.drawCircle(pos + gravity, p.size * life, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
