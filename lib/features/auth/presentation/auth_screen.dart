/// Premium Authentication Screen for RUG.
///
/// Implements a dark, luxury, minimal UI with a subtle emerald glow behind
/// the Three of Clubs card, a metallic gold title, and responsive action buttons.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/widgets/auth_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
          gradient: RadialGradient(
            center: Alignment(0.0, -0.15), // Positioned behind the hero card
            radius: 0.9,
            colors: [
              Color(0xFF04180F), // Very subtle emerald glow
              Colors.black,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxHeight < 680;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 3),

                          // ── TITLE: RUG ───────────────────────────────────────────
                          const _AuthTitle(),

                          Spacer(flex: isSmallScreen ? 2 : 3),

                          // ── HERO CARD ────────────────────────────────────────────
                          SizedBox(
                            height: constraints.maxHeight * (isSmallScreen ? 0.38 : 0.43),
                            child: const Center(
                              child: HeroCard(),
                            ),
                          ),

                          Spacer(flex: isSmallScreen ? 3 : 4),

                          // ── GOOGLE BUTTON ────────────────────────────────────────
                          GoogleButton(
                            onPressed: () {
                              // Action triggered on Continue with Google
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── EMAIL BUTTON ─────────────────────────────────────────
                          EmailButton(
                            onPressed: () {
                              context.push(RouteNames.login);
                            },
                          ),

                          const SizedBox(height: 24),

                          // ── DIVIDER ──────────────────────────────────────────────
                          const _GoldDivider(),

                          const SizedBox(height: 24),

                          // ── GUEST BUTTON ─────────────────────────────────────────
                          GuestButton(
                            onPressed: () {
                              // Action triggered on Play as Guest
                            },
                          ),

                          const Spacer(flex: 4),

                          // ── LEGAL TEXT ───────────────────────────────────────────
                          const LegalSection(),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Metallic gold text title 'RUG' with a soft gold glow.
class _AuthTitle extends StatelessWidget {
  const _AuthTitle();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background text with shadows for the soft gold glow effect
        Text(
          'RUG',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.5,
            color: Colors.transparent,
            shadows: [
              Shadow(
                color: SplashAnimationConstants.gold.withValues(alpha: 0.50),
                blurRadius: 18,
              ),
              Shadow(
                color: SplashAnimationConstants.brightGold.withValues(alpha: 0.30),
                blurRadius: 36,
              ),
            ],
          ),
        ),
        // Foreground text with metallic gold gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              SplashAnimationConstants.brightGold,
              SplashAnimationConstants.gold,
              Color(0xFFB3922E), // Rich metallic shadow gold
              SplashAnimationConstants.gold,
              SplashAnimationConstants.brightGold,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'RUG',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.5,
              color: Colors.white, // Required for ShaderMask to apply
            ),
          ),
        ),
      ],
    );
  }
}

/// A thin metallic gold divider with a centered 'OR'.
class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  SplashAnimationConstants.gold.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: SplashAnimationConstants.gold,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SplashAnimationConstants.gold.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
