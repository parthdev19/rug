import 'package:flutter/material.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

/// ── WELCOME HEADER ──────────────────────────────────────────────────────────
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({
    required this.username,
    required this.isGuest,
    required this.onSettingsPressed,
    required this.onProfilePressed,
    super.key,
  });

  final String username;
  final bool isGuest;
  final VoidCallback onSettingsPressed;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Welcome Greeting & Username + Guest Badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome,',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isGuest) ...[
                const SizedBox(height: 6),
                const GuestBadge(),
              ],
            ],
          ),
        ),

        // Right Row: Settings and Profile Buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderIconButton(
              icon: Icons.settings_outlined,
              onPressed: onSettingsPressed,
            ),
            const SizedBox(width: 12),
            _HeaderIconButton(
              icon: Icons.person_outline_rounded,
              onPressed: onProfilePressed,
            ),
          ],
        ),
      ],
    );
  }
}

/// ── GUEST BADGE ─────────────────────────────────────────────────────────────
class GuestBadge extends StatelessWidget {
  const GuestBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0C100E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SplashAnimationConstants.emerald.withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.face_unlock_rounded,
            color: SplashAnimationConstants.emerald,
            size: 12,
          ),
          SizedBox(width: 4),
          Text(
            'GUEST PLAYER',
            style: TextStyle(
              color: SplashAnimationConstants.emerald,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// ── HEADER ICON BUTTON ──────────────────────────────────────────────────────
class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF0C100E),
            shape: BoxShape.circle,
            border: Border.all(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            widget.icon,
            color: SplashAnimationConstants.gold,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// ── PRIMARY ACTION CARD (JOIN GAME) ─────────────────────────────────────────
class PrimaryActionCard extends StatefulWidget {
  const PrimaryActionCard({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  State<PrimaryActionCard> createState() => _PrimaryActionCardState();
}

class _PrimaryActionCardState extends State<PrimaryActionCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF18C88A),
                Color(0xFF0F8A64),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: SplashAnimationConstants.emerald.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Card Details
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Join Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Enter a room code and join an existing table.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── SECONDARY ACTION CARD (CREATE GAME) ─────────────────────────────────────
class SecondaryActionCard extends StatefulWidget {
  const SecondaryActionCard({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  State<SecondaryActionCard> createState() => _SecondaryActionCardState();
}

class _SecondaryActionCardState extends State<SecondaryActionCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C100E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Circular Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SplashAnimationConstants.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: SplashAnimationConstants.gold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              // Card Details
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Start a new game and invite friends.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: SplashAnimationConstants.gold,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── FUTURE SECTION PLACEHOLDER CARD ──────────────────────────────────────────
class FutureSectionPlaceholder extends StatelessWidget {
  const FutureSectionPlaceholder({
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF070B09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: SplashAnimationConstants.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(
                  color: SplashAnimationConstants.gold,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
