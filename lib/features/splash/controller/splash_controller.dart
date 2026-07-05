/// Coordinated animation timeline for the cinematic splash experience.
///
/// Seven dedicated AnimationControllers replace the previous monolithic design:
///
///   _entry        — background fade, logo/tagline entrance (600ms)
///   _cardFlight   — off-screen → center curved path + scale arc (850ms)
///   _rotation     — 3-axis physics-like tumble during flight (850ms, synced)
///   _bounce       — landing overshoot + settle (380ms, fires after flight)
///   _float        — idle hover/breathe loop after landing (2800ms, looping)
///   _glowPulse    — slow emerald bloom pulse (1600ms, looping)
///   _loading      — monotonic 0→1 loading bar fill (1800ms, starts at settle)
///
/// Separation lets each axis have independent easing without coupling.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

/// Owns all animation controllers and exposes semantic tracks to the UI.
class SplashAnimationController {
  SplashAnimationController({required TickerProvider vsync})
    : _entry = AnimationController(
        vsync: vsync,
        duration: SplashAnimationConstants.entryDuration,
      ),
      _cardFlight = AnimationController(
        vsync: vsync,
        duration: SplashAnimationConstants.flightDuration,
      ),
      _rotation = AnimationController(
        vsync: vsync,
        duration: SplashAnimationConstants.flightDuration,
      ),
      _bounce = AnimationController(
        vsync: vsync,
        duration: SplashAnimationConstants.bounceDuration,
      ),
      _float = AnimationController(
        vsync: vsync,
        duration: SplashAnimationConstants.floatDuration,
      ),
      _glowPulse = AnimationController(
        vsync: vsync,
        duration: SplashAnimationConstants.glowPulseDuration,
      ),
      _loading = AnimationController(
        vsync: vsync,
        duration: const Duration(seconds: 2),
      ) {
    _buildTracks();
  }

  // ── Controllers ───────────────────────────────────────────────────────────

  final AnimationController _entry;
  final AnimationController _cardFlight;
  final AnimationController _rotation;
  final AnimationController _bounce;
  final AnimationController _float;
  final AnimationController _glowPulse;
  final AnimationController _loading;

  // ── Public listenables (merged for AnimatedBuilder) ───────────────────────

  /// Merge of everything that drives the background + logo + tagline.
  late final Listenable entryListenable;

  /// Merge of everything that drives the card widget.
  late final Listenable cardListenable;

  /// Drives the loading bar and its label.
  late final Listenable loadingListenable;

  // ── Logo / Tagline tracks ──────────────────────────────────────────────────

  late final Animation<double> backgroundOpacity;
  late final Animation<double> logoOpacity;
  late final Animation<double> logoScale;
  late final Animation<double> logoOffset;
  late final Animation<double> taglineOpacity;
  late final Animation<double> taglineOffset;

  // ── Card tracks ───────────────────────────────────────────────────────────

  /// Normalized 0→1 flight progress (used for path / scale interpolation).
  late final Animation<double> flightProgress;

  /// Raw flight value that can exceed 1.0 during bounce overshoot.
  /// UI clamps this themselves for opacity.
  late final Animation<double> bounceScale;

  /// Curved flight value for translation path only.
  late final Animation<double> flightCurved;

  // 3-axis rotation animations, each with independent easing.

  late final Animation<double> rotX;
  late final Animation<double> rotY;
  late final Animation<double> rotZ;

  // Post-landing idle.

  late final Animation<double> floatOffset; // Y pixel drift
  late final Animation<double> floatRotZ; // subtle Z tilt
  late final Animation<double> floatScale; // 1.00 ↔ 1.02 breathe

  // ── Glow / Impact ─────────────────────────────────────────────────────────

  late final Animation<double> impactPulse; // 0→1→0 on landing
  late final Animation<double> glowIntensity; // approach glow
  late final Animation<double> glowPulse; // idle pulse amplitude

  // ── Loading bar ───────────────────────────────────────────────────────────

  late final Animation<double> loadingOpacity;
  late final Animation<double> loadingProgress;

  // ── Build ─────────────────────────────────────────────────────────────────

  void _buildTracks() {
    // ── Entry ──────────────────────────────────────────────────────────────

    backgroundOpacity = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    logoOpacity = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.20, 0.65, curve: Curves.easeOut),
    );
    logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _entry,
        curve: const Interval(0.18, 0.68, curve: Curves.easeOutBack),
      ),
    );
    logoOffset = Tween<double>(begin: 14.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entry,
        curve: const Interval(0.18, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    taglineOpacity = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.45, 0.90, curve: Curves.easeOut),
    );
    taglineOffset = Tween<double>(begin: 8.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entry,
        curve: const Interval(0.45, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    // ── Flight path ────────────────────────────────────────────────────────

    flightCurved = CurvedAnimation(
      parent: _cardFlight,
      curve: SplashAnimationConstants.flightCurve,
    );

    // Raw flight value for normalized progress reading.
    flightProgress = _cardFlight.view;

    // ── Scale arc: 0.40 → 1.15 → 1.00 ────────────────────────────────────
    //
    // TweenSequence produces: during flight 0.40→1.15, during bounce 1.15→1.00.
    // The bounce controller then takes over for the overshoot->settle.

    bounceScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: SplashAnimationConstants.scaleStart,
          end: SplashAnimationConstants.scalePeak,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 100,
      ),
    ]).animate(_cardFlight);

    // ── 3-Axis rotation — independent easing per axis ──────────────────────
    //
    // Each axis uses a TweenSequence: approach arc → overshoot → settle.
    // Weight split: 72% approach, 28% overshoot-settle (matches _CardDealCurve
    // timing feel but without sharing a single parent).

    rotY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: SplashAnimationConstants.rotYStart,
          end: SplashAnimationConstants.rotYLand,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 68,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: SplashAnimationConstants.rotYLand,
          end: SplashAnimationConstants.rotYRest,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 32,
      ),
    ]).animate(_rotation);

    rotX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: SplashAnimationConstants.rotXStart,
          end: SplashAnimationConstants.rotXLand,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: SplashAnimationConstants.rotXLand,
          end: SplashAnimationConstants.rotXRest,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
    ]).animate(_rotation);

    rotZ = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: SplashAnimationConstants.rotZStart,
          end: SplashAnimationConstants.rotZLand,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: SplashAnimationConstants.rotZLand,
          end: SplashAnimationConstants.rotZRest,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_rotation);

    // ── Bounce overshoot scale: 1.15 → 1.07 → 1.00 ────────────────────────

    // bounceScale post-flight is driven by _bounce controller separately.
    // The floating_card_animation widget merges both to get a seamless value.

    // ── Glow ───────────────────────────────────────────────────────────────

    // Approach glow: brightens as card arrives (driven by cardFlight).
    glowIntensity = CurvedAnimation(
      parent: _cardFlight,
      curve: Curves.easeInQuad,
    );

    // Impact pulse: 0→1→0 during bounce.
    impactPulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0), weight: 70),
    ]).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeOut));

    // Idle glow pulse: sine-like 0→1→0 loop.
    glowPulse = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0),
          weight: 50,
        ),
      ],
    ).animate(CurvedAnimation(parent: _glowPulse, curve: Curves.easeInOutSine));

    // ── Idle float (looping sine) ──────────────────────────────────────────

    floatOffset = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -SplashAnimationConstants.maxAmbientOffset,
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -SplashAnimationConstants.maxAmbientOffset,
          end: 0,
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: SplashAnimationConstants.maxAmbientOffset,
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: SplashAnimationConstants.maxAmbientOffset,
          end: 0,
        ),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOutSine));

    floatRotZ = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -SplashAnimationConstants.maxAmbientRotation,
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -SplashAnimationConstants.maxAmbientRotation,
          end: 0,
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: SplashAnimationConstants.maxAmbientRotation,
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: SplashAnimationConstants.maxAmbientRotation,
          end: 0,
        ),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOutSine));

    floatScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.0 + SplashAnimationConstants.breatheAmplitude,
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0 + SplashAnimationConstants.breatheAmplitude,
          end: 1.0,
        ),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOutSine));

    // ── Loading bar ────────────────────────────────────────────────────────
    //
    // Appears after card has settled (bounce complete).

    loadingOpacity = CurvedAnimation(
      parent: _bounce,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
    // Monotonic 0→1 fill driven by its own dedicated controller.
    loadingProgress = CurvedAnimation(
      parent: _loading,
      curve: Curves.easeInOutCubic,
    );

    // ── Listenable groups ─────────────────────────────────────────────────

    entryListenable = Listenable.merge([_entry]);
    cardListenable = Listenable.merge([
      _cardFlight,
      _rotation,
      _bounce,
      _float,
      _glowPulse,
    ]);
    loadingListenable = Listenable.merge([_bounce, _loading]);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Runs the full sequence and resolves when the loading bar is visible.
  Future<void> start() async {
    // Step 1: Background + logo/tagline entrance.
    await _entry.forward();

    // Step 2: Card deal begins 0ms after entry ends (entry already had 500ms
    // delay baked in via dealDelay — both controllers fire together for
    // precise timing, but the card's appearance starts from off-screen).
    await Future.wait([_cardFlight.forward(), _rotation.forward()]);

    // Step 3: Card has landed — run bounce + start idle loops + fill loading bar.
    await _bounce.forward();
    unawaited(_float.repeat());
    unawaited(_glowPulse.repeat());
    // Await loading fill so navigation happens only after the temporary 50s load.
    await _loading.forward();
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  void dispose() {
    _entry.dispose();
    _cardFlight.dispose();
    _rotation.dispose();
    _bounce.dispose();
    _float.dispose();
    _glowPulse.dispose();
    _loading.dispose();
  }

  // ── Convenience getters used by SplashScreen ──────────────────────────────

  /// Whether the card flight phase is complete.
  bool get isLanded => _cardFlight.isCompleted;

  /// Whether the bounce phase is complete.
  bool get isSettled => _bounce.isCompleted;

  /// Raw 0→1 progress of the bounce controller (for rotation snap-to-rest).
  double get bounceProgress => _bounce.value;

  /// Scale during flight (0.40 → 1.15).
  double get flightScale => bounceScale.value;

  /// Scale overshoot during bounce (1.15 → 1.07 → 1.00).
  double get bounceScaleValue {
    // Cubic ease-out overshoot: starts where flight ended (1.15), dips
    // slightly, then settles to 1.00.
    final t = Curves.easeOutBack.transform(_bounce.value);
    return _lerpBounceScale(t);
  }

  static double _lerpBounceScale(double t) {
    // 1.15 → 1.00 with a small undershoot pocket via easeOutBack.
    return 1.15 + (1.00 - 1.15) * t;
  }

  /// Combined card scale: flight scale during flight, bounce scale after.
  double get cardScale {
    if (!isLanded) return flightScale;
    if (!isSettled) return bounceScaleValue;
    return floatScale.value;
  }

  /// Opacity driven by how far the card has traveled (fades in fast).
  double get cardOpacity => math.min(_cardFlight.value * 4, 1.0);

  /// Combined glow: approach + idle pulse + impact.
  double get cardGlow {
    final approach = glowIntensity.value * 0.45;
    final pulse = (isSettled ? glowPulse.value * 0.18 : 0.0);
    final impact = impactPulse.value * 0.55;
    return (approach + pulse + impact).clamp(0.0, 1.0);
  }
}
