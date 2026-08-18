/// Cinematic launch experience for RUG.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/assets/asset_paths.dart';
import 'package:rug/features/splash/controller/splash_controller.dart';
import 'package:rug/features/splash/widgets/floating_card_animation.dart';
import 'package:rug/features/splash/widgets/glow_layer.dart';
import 'package:rug/features/splash/widgets/loading_bar.dart';
import 'package:rug/features/splash/widgets/particle_background.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/features/splash/widgets/splash_logo.dart';
import 'package:rug/features/screen_tracking/models/screen_info_model.dart';
import 'package:rug/features/screen_tracking/repository/screen_info_repository.dart';
import 'package:rug/routes/route_names.dart';
import 'package:rug/services/device/device_info_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/services/audio/sound_manager.dart';
import 'package:rug/services/storage/secure_storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final SplashAnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = SplashAnimationController(vsync: this);
    _runStartupSequence();
  }

  /// The server assigns/returns the device-level user ID from device-info.
  /// Submit the initial screen only after that response has been processed, so
  /// screen-info always has an available and current user ID.
  Future<void> _runStartupSequence() async {
    final animation = _anim.start(
      onCardFlightStart: () {
        unawaited(SoundManager.instance.playSfx(AssetPaths.splashCardSwipe));
      },
    );
    final deviceInfoAccepted = await DeviceInfoService.instance
        .sendDeviceInfo();

    if (deviceInfoAccepted) {
      await _trackInitialScreen();
    }

    // Check & restore existing authenticated session
    final restoredUser = await ref
        .read(authControllerProvider.notifier)
        .restoreSession();

    await animation;
    if (!mounted) return;

    if (restoredUser != null) {
      if (!restoredUser.isUsernameSet ||
          restoredUser.username.trim().isEmpty) {
        context.go(RouteNames.setUsername);
      } else {
        context.go(RouteNames.home);
      }
    } else {
      context.go(RouteNames.auth);
    }
  }

  Future<void> _trackInitialScreen() async {
    final userId = await SecureStorageService.instance.getDeviceUserId();
    if (userId == null || userId <= 0) {
      AppLogger.warning(
        'Skipping initial screen info — device-info returned no valid user_id',
      );
      return;
    }

    await ScreenInfoRepository.instance.trackScreen(
      userId: userId,
      entry: ScreenInfoModel(
        screenName: 'splash_screen',
        screenTime: DateTime.now().toUtc(),
      ),
    );
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
