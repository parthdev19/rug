import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/features/auth/widgets/hero_card.dart' as auth_widgets;
import 'package:rug/features/home/controller/home_controller.dart';
import 'package:rug/features/home/presentation/widgets/lobby_background.dart';
import 'package:rug/features/home/presentation/widgets/lobby_widgets.dart';
import 'package:rug/shared/providers/common_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
                          // Action logic when settings is pressed.
                          // E.g., open a popup, settings bottom sheet, etc.
                        },
                        onProfilePressed: () {
                          // E.g., navigate to profile screen
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
                          ref.read(homeControllerProvider.notifier).createGame();
                          // Future navigation hook for private lobby screen
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
