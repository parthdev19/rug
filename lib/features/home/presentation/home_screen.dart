import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/features/auth/widgets/hero_card.dart' as auth_widgets;
import 'package:rug/features/home/controller/home_controller.dart';
import 'package:rug/features/home/presentation/widgets/lobby_background.dart';
import 'package:rug/features/home/presentation/widgets/lobby_widgets.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';
import 'package:rug/shared/providers/common_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0C100E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: SplashAnimationConstants.gold.withValues(alpha: 0.3),
          ),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go(RouteNames.auth);
              }
            },
            child: const Text(
              'LOGOUT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final isGuest = ref.read(isGuestProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0C100E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.settings_outlined,
                  color: SplashAnimationConstants.gold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'SETTINGS & ACCOUNT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: SplashAnimationConstants.emerald.withValues(alpha: 0.2),
                    radius: 22,
                    child: Text(
                      (user?.username.isNotEmpty == true)
                          ? user!.username[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        color: SplashAnimationConstants.emerald,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? 'Player',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user?.email != null && user!.email!.isNotEmpty)
                          Text(
                            user.email!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          )
                        else if (isGuest)
                          const Text(
                            'Guest Account',
                            style: TextStyle(
                              color: SplashAnimationConstants.emerald,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => _showLogoutConfirmation(context, ref),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E0A0A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE53935).withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFE53935),
                      size: 22,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Sign out of your RUG session',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFE53935),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isGuest = ref.watch(isGuestProvider);
    final username = user?.username ?? 'Player';

    return Scaffold(
      backgroundColor: Colors.black,
      body: LobbyBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── WELCOME HEADER & USER SETTINGS ─────────────────────
                      WelcomeHeader(
                        username: username,
                        isGuest: isGuest,
                        onSettingsPressed: () {
                          _showSettingsBottomSheet(context, ref);
                        },
                        onProfilePressed: () {
                          _showSettingsBottomSheet(context, ref);
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── HERO CARD WIDGET (FLOATING & PULSING) ──────────────
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: auth_widgets.HeroCard(),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── PRIMARY ACTION CARD (JOIN GAME) ────────────────────
                      PrimaryActionCard(
                        onPressed: () {
                          ref.read(homeControllerProvider.notifier).joinGame('');
                          // Future navigation hook for entering a room code
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── SECONDARY ACTION CARD (CREATE GAME) ──────────────────
                      SecondaryActionCard(
                        onPressed: () {
                          context.push(RouteNames.createGame);
                        },
                      ),
                      const SizedBox(height: 36),

                      // ── FUTURE SECTIONS SECTION TITLE ──────────────────────
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
                        child: Text(
                          'GAMING CENTER',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      // ── 2x2 GRID OF FUTURE FEATURE PLACEHOLDERS ────────────
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.25,
                        children: const [
                          FutureSectionPlaceholder(
                            title: 'Friends',
                            icon: Icons.people_outline_rounded,
                          ),
                          FutureSectionPlaceholder(
                            title: 'Leaderboard',
                            icon: Icons.leaderboard_outlined,
                          ),
                          FutureSectionPlaceholder(
                            title: 'Profile',
                            icon: Icons.portrait_rounded,
                          ),
                          FutureSectionPlaceholder(
                            title: 'Rewards',
                            icon: Icons.emoji_events_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
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
