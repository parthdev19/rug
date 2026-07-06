import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class LobbyBackground extends StatefulWidget {
  const LobbyBackground({required this.child, super.key});

  final Widget child;

  @override
  State<LobbyBackground> createState() => _LobbyBackgroundState();
}

class _LobbyBackgroundState extends State<LobbyBackground> with TickerProviderStateMixin {
  late final AnimationController _tickerController;
  late final AnimationController _floatController;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // ── Particle simulation controller ──────────────────────────────────────
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // ── Floating clubs animation controller ─────────────────────────────────
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Initialize 45 random particles
    for (int i = 0; i < 45; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 2.0 + 0.8,
          speed: _random.nextDouble() * 0.0012 + 0.0004,
          opacity: _random.nextDouble() * 0.35 + 0.15,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tickerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── 1. Radial Vignette Background ────────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              gradient: RadialGradient(
                center: Alignment(0.0, -0.3),
                radius: 1.3,
                colors: [
                  Color(0xFF031A12), // Subtle deep green glow
                  Color(0xFF000302), // Fading to deep luxury black
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),

        // ── 2. Floating Clubs (Low Opacity) ──────────────────────────────────
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final floatOffset = math.sin(_floatController.value * 2 * math.pi) * 8.0;
            final rotateAngle = _floatController.value * 2 * math.pi;

            return Stack(
              children: [
                // Top-Left Club
                Positioned(
                  left: -20,
                  top: 100 + floatOffset,
                  child: Opacity(
                    opacity: 0.03,
                    child: Transform.rotate(
                      angle: rotateAngle * 0.2,
                      child: SvgPicture.asset(
                        'assets/icons/club.svg',
                        width: 140,
                        height: 140,
                        colorFilter: const ColorFilter.mode(
                          SplashAnimationConstants.emerald,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                // Middle-Right Club
                Positioned(
                  right: -40,
                  top: 320 - floatOffset,
                  child: Opacity(
                    opacity: 0.025,
                    child: Transform.rotate(
                      angle: -rotateAngle * 0.15,
                      child: SvgPicture.asset(
                        'assets/icons/club.svg',
                        width: 180,
                        height: 180,
                        colorFilter: const ColorFilter.mode(
                          SplashAnimationConstants.emerald,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom-Left Club
                Positioned(
                  left: 30,
                  bottom: 120 + floatOffset * 0.8,
                  child: Opacity(
                    opacity: 0.02,
                    child: Transform.rotate(
                      angle: rotateAngle * 0.1,
                      child: SvgPicture.asset(
                        'assets/icons/club.svg',
                        width: 100,
                        height: 100,
                        colorFilter: const ColorFilter.mode(
                          SplashAnimationConstants.emerald,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // ── 3. Floating Ambient Particles ────────────────────────────────────
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _tickerController,
            builder: (context, child) {
              // Update particle positions
              for (final p in _particles) {
                p.y -= p.speed;
                if (p.y < 0) {
                  p.y = 1.0;
                  p.x = _random.nextDouble();
                }
              }
              return CustomPaint(
                painter: _ParticlePainter(particles: _particles),
              );
            },
          ),
        ),

        // ── 4. Main Lobby UI ─────────────────────────────────────────────────
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });

  double x;
  double y;
  final double radius;
  final double speed;
  final double opacity;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles});

  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SplashAnimationConstants.emerald
      ..style = PaintingStyle.fill;

    for (final p in particles) {
      final pos = Offset(p.x * size.width, p.y * size.height);
      paint.color = SplashAnimationConstants.emerald.withValues(alpha: p.opacity);
      canvas.drawCircle(pos, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
