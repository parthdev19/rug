/// Cinematic launch experience for RUG.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/splash/controller/splash_controller.dart';
import 'package:rug/features/splash/widgets/floating_card_animation.dart';
import 'package:rug/features/splash/widgets/glow_layer.dart';
import 'package:rug/features/splash/widgets/loading_bar.dart';
import 'package:rug/features/splash/widgets/particle_background.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/features/splash/widgets/splash_logo.dart';
import 'package:rug/routes/route_names.dart';
import 'package:rug/services/device/device_info_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final SplashAnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = SplashAnimationController(vsync: this);
    Future.wait([
      _anim.start(),
      DeviceInfoService.instance.sendDeviceInfo(),
    ]).then((_) {
      if (mounted) context.go(RouteNames.auth);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashAnimationConstants.background,
      body: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Static background gradient ──────────────────────────────────
            const _Background(),

            // ── Atmospheric glow (repaints only on glow values) ─────────────
            AnimatedBuilder(
              animation: _anim.cardListenable,
              builder: (context, child) => GlowLayer(
                intensity: _anim.glowIntensity.value,
                pulse: _anim.impactPulse.value,
                idlePulse: _anim.glowPulse.value,
              ),
            ),

            // ── Floating particles (independent repaint boundary) ───────────
            ParticleBackground(
              entryAnimation: _anim.flightProgress,
              floatAnimation: _anim.floatOffset,
              impactAnimation: _anim.impactPulse,
            ),

            // ── Foreground: tagline + card + loading ────────────────────────
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Tagline retains the existing entry animation.
                      Positioned(
                        top: constraints.maxHeight * 0.09,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _anim.entryListenable,
                          builder: (context, child) => Opacity(
                            opacity: _anim.logoOpacity.value,
                            child: Transform.translate(
                              offset: Offset(0, _anim.logoOffset.value),
                              child: Transform.scale(
                                scale: _anim.logoScale.value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SplashLogo(),
                                    Opacity(
                                      opacity: _anim.taglineOpacity.value,
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          _anim.taglineOffset.value,
                                        ),
                                        child: const SplashTagline(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Hero card — its own RepaintBoundary inside.
                      Positioned(
                        top: constraints.maxHeight * 0.23,
                        left: 0,
                        right: 0,
                        bottom: constraints.maxHeight * 0.18,
                        child: Center(
                          child: FloatingCardAnimation(controller: _anim),
                        ),
                      ),

                      // Loading bar — appears after card settles.
                      Positioned(
                        bottom: constraints.maxHeight * 0.03,
                        child: AnimatedBuilder(
                          animation: _anim.loadingListenable,
                          builder: (context, child) => Opacity(
                            opacity: _anim.loadingOpacity.value,
                            child: LoadingBar(
                              progress: _anim.loadingProgress.value,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Vignette (static, never repaints) ──────────────────────────
            const _Vignette(),
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, 0.16),
          radius: 1.05,
          colors: [
            SplashAnimationConstants.backgroundGreen,
            SplashAnimationConstants.background,
          ],
          stops: [0, 0.78],
        ),
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.86,
            colors: [Colors.transparent, Color(0xB3000000)],
            stops: [0.55, 1],
          ),
        ),
      ),
    );
  }
}
