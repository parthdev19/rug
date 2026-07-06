import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/create_game/controller/create_game_controller.dart';
import 'package:rug/features/create_game/presentation/widgets/number_selector.dart';
import 'package:rug/features/create_game/presentation/widgets/settings_card.dart';
import 'package:rug/features/home/presentation/widgets/lobby_background.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';
import 'package:rug/widgets/buttons/primary_button.dart';

class CreateGameScreen extends ConsumerWidget {
  const CreateGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameControllerProvider);
    final notifier = ref.read(createGameControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: LobbyBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── HEADER: BACK BUTTON ───────────────────────────
                          Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C100E),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: SplashAnimationConstants.gold
                                        .withValues(alpha: 0.15),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: SplashAnimationConstants.gold,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── SCREEN TITLE & SUBTITLE ───────────────────────
                          const Text(
                            'Create Game',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Configure your game settings before creating a new room.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── CONFIGURATION CARDS ────────────────────────────
                          SettingsCard(
                            title: 'TOTAL PLAYERS',
                            icon: Icons.people_alt_outlined,
                            child: NumberSelector(
                              value: state.totalPlayers,
                              minValue: 4,
                              maxValue: 9,
                              label: state.totalPlayers == 1 ? 'Player' : 'Players',
                              onDecrement: notifier.decrementPlayers,
                              onIncrement: notifier.incrementPlayers,
                            ),
                          ),
                          const SizedBox(height: 16),

                          SettingsCard(
                            title: 'DEFAULT POINTS',
                            icon: Icons.emoji_events_outlined,
                            child: NumberSelector(
                              value: state.defaultPoints,
                              minValue: 100,
                              maxValue: 170,
                              label: 'Points',
                              onDecrement: notifier.decrementPoints,
                              onIncrement: notifier.incrementPoints,
                            ),
                          ),
                          const SizedBox(height: 16),

                          SettingsCard(
                            title: 'TOTAL ROUNDS',
                            icon: Icons.loop_rounded,
                            child: NumberSelector(
                              value: state.totalRounds,
                              minValue: 1,
                              maxValue: 20,
                              label: state.totalRounds == 1 ? 'Round' : 'Rounds',
                              onDecrement: notifier.decrementRounds,
                              onIncrement: notifier.incrementRounds,
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 32),

                          // ── PRIMARY ACTION BUTTON ─────────────────────────
                          PrimaryButton(
                            label: 'Create Game',
                            onPressed: () {
                              if (notifier.validate()) {
                                // Navigate to the private room (API integration will be added later)
                                context.push(RouteNames.privateRoom);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid game configuration.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
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
