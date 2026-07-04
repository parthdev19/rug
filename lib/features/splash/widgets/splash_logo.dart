/// RUG crest, wordmark, and signature tagline.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App icon / crest
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF080B09),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Color(0x3327FF75), blurRadius: 24),
            ],
          ),
          child: const _Crest(),
        ),

        // 36dp space between icon and title (spec: 32–40dp)
        const SizedBox(height: 36),

        // Decorative "·— RUG —·" wordmark row
        const _WordmarkRow(),

        // 24dp space between title and tagline (spec: 20–28dp)
        const SizedBox(height: 24),
      ],
    );
  }
}

/// "RUG" title flanked by gold ornamental lines and dots.
class _WordmarkRow extends StatelessWidget {
  const _WordmarkRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ·— RUG —·
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left ornament: dot + line
            const _GoldDot(),
            const SizedBox(width: 6),
            _goldLine(44),
            const SizedBox(width: 10),

            // Title
            const Text(
              'RUG',
              style: TextStyle(
                color: SplashAnimationConstants.gold,
                fontSize: 31,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                height: 1,
              ),
            ),

            // Right ornament: line + dot
            const SizedBox(width: 10),
            _goldLine(44),
            const SizedBox(width: 6),
            const _GoldDot(),
          ],
        ),
      ],
    );
  }

  Widget _goldLine(double width) {
    return Container(
      width: width,
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            SplashAnimationConstants.gold,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _GoldDot extends StatelessWidget {
  const _GoldDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: SplashAnimationConstants.gold,
      ),
    );
  }
}

class SplashTagline extends StatelessWidget {
  const SplashTagline({super.key});

  // Picked once per app launch — Random() without a seed uses system entropy.
  static final String _text = _taglines[math.Random().nextInt(_taglines.length)];

  static const List<String> _taglines = [
    'EVERY PLAYER WANTS\nTHE THREE OF CLUBS.',
    'ONLY ONE CARD CHANGES\nEVERYTHING — THE THREE OF CLUBS.',
    'EVERYONE WANTS IT.\nONLY ONE CAN HOLD IT.',
    'GET THE THREE OF CLUBS.\nWIN THE GAME.',
    'EVERY PLAYER WANTS THE 3♣.',
    'ALL PLAYERS WANT\nTHE THREE OF CLUBS.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xCFF4F0E6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.45,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 10),
        // Gold ornament: ·····◆·····
        _OrnamentRow(),
      ],
    );
  }
}

class _OrnamentRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dots(5),
        const SizedBox(width: 5),
        _diamond(),
        const SizedBox(width: 5),
        _dots(5),
      ],
    );
  }

  Widget _dots(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SplashAnimationConstants.gold.withValues(
                alpha: 0.5 + i * 0.08,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _diamond() {
    return Transform.rotate(
      angle: 0.785398, // 45°
      child: Container(
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          color: SplashAnimationConstants.gold,
        ),
      ),
    );
  }
}

class _Crest extends StatelessWidget {
  const _Crest();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        Positioned(top: 10, child: _GoldPip()),
        Positioned(left: 13, top: 24, child: _GoldPip()),
        Positioned(right: 13, top: 24, child: _GoldPip()),
        Positioned(
          bottom: 7,
          child: Text(
            'RUG',
            style: TextStyle(
              color: SplashAnimationConstants.gold,
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoldPip extends StatelessWidget {
  const _GoldPip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [SplashAnimationConstants.brightGold, Color(0xFFB77D00)],
        ),
        boxShadow: [BoxShadow(color: Color(0x88FFD85A), blurRadius: 7)],
      ),
    );
  }
}
