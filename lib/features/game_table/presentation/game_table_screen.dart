/// Premium landscape game table screen.
///
/// Orchestrates all game phases: waiting → countdown → dealing → playing.
/// Renders a casino-quality capsule table, dynamically positioned player seats,
/// a menu icon with popup panel, and phase-specific overlays.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/game_table/controller/game_table_controller.dart';
import 'package:rug/features/game_table/controller/game_table_state.dart';
import 'package:rug/features/game_table/presentation/widgets/bottom_controls.dart';
import 'package:rug/features/game_table/presentation/widgets/countdown_overlay.dart';
import 'package:rug/features/game_table/presentation/widgets/deal_animation_overlay.dart';
import 'package:rug/features/game_table/presentation/widgets/player_hand.dart';
import 'package:rug/features/game_table/presentation/widgets/player_seat.dart';
import 'package:rug/features/game_table/presentation/widgets/seat_layout_calculator.dart';
import 'package:rug/features/game_table/presentation/widgets/table_center_info.dart';
import 'package:rug/features/game_table/presentation/widgets/table_header.dart';
import 'package:rug/features/game_table/presentation/widgets/table_surface.dart';
import 'package:rug/features/game_table/presentation/widgets/waiting_panel.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class GameTableScreen extends ConsumerStatefulWidget {
  const GameTableScreen({super.key});

  @override
  ConsumerState<GameTableScreen> createState() => _GameTableScreenState();
}

class _GameTableScreenState extends ConsumerState<GameTableScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Lock to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Screen entrance fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();

    // Restore portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameTableControllerProvider);
    final notifier = ref.read(gameTableControllerProvider.notifier);
    final screenSize = MediaQuery.sizeOf(context);

    // Table proportions (matching TableSurface painter)
    final tableWidth = screenSize.width * 0.82;
    final tableHeight = screenSize.height * 0.67;
    final tableCenter = Offset(screenSize.width / 2, screenSize.height / 2);

    // Seat positions
    final seatPositions = SeatLayoutCalculator.computeSeats(
      center: tableCenter,
      tableWidth: tableWidth,
      tableHeight: tableHeight,
      playerCount: state.players.length,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // ── 1. Background gradient ──────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Color(0xFF04180F),
                      Color(0xFF020807),
                      Colors.black,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // ── 2. Table surface ────────────────────────────────────────
            const Positioned.fill(
              child: TableSurface(),
            ),

            // ── 3. Center content (phase-dependent) ─────────────────────
            if (state.gameStatus == GameStatus.waiting)
              Center(
                child: WaitingPanel(
                  roomCode: state.roomCode,
                  currentPlayers: state.players.length,
                  totalPlayers: state.totalPlayers,
                  currentRound: state.currentRound,
                  defaultPoints: state.defaultPoints,
                  isHost: state.isHost,
                  onStartGame: () => notifier.startGame(),
                ),
              )
            else if (state.gameStatus == GameStatus.playing)
              Center(
                child: TableCenterInfo(
                  currentRound: state.currentRound,
                  totalRounds: state.totalRounds,
                  defaultPoints: state.defaultPoints,
                  gameStatus: state.gameStatus,
                ),
              ),

            // ── 4. Player seats ─────────────────────────────────────────
            ...List.generate(state.players.length, (index) {
              final player = state.players[index];
              final pos = seatPositions[index];

              // Seat widget dimensions
              const seatWidth = 80.0;
              const seatHeight = 100.0;

              return Positioned(
                left: pos.dx - seatWidth / 2,
                top: pos.dy - seatHeight / 2,
                width: seatWidth,
                height: seatHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlayerSeat(
                      player: player,
                      animationDelay:
                          Duration(milliseconds: 100 + (index * 80)),
                    ),
                    // Opponent card stack (during playing state)
                    if (state.gameStatus == GameStatus.playing &&
                        !player.isCurrentPlayer &&
                        state.playerHands.isNotEmpty &&
                        index < state.playerHands.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: OpponentCardStack(
                          cardCount: state.playerHands[index].length,
                        ),
                      ),
                  ],
                ),
              );
            }),

            // ── 5. Countdown overlay ────────────────────────────────────
            if (state.gameStatus == GameStatus.countdown)
              Positioned.fill(
                child: CountdownOverlay(value: state.countdownValue),
              ),

            // ── 6. Dealing animation ────────────────────────────────────
            if (state.gameStatus == GameStatus.dealing)
              Positioned.fill(
                child: DealAnimationOverlay(
                  playerCount: state.players.length,
                  seatPositions: seatPositions,
                  onComplete: () => notifier.onDealingComplete(),
                ),
              ),

            // ── 7. Current player's hand (during playing) ───────────────
            if (state.gameStatus == GameStatus.playing &&
                state.playerHands.isNotEmpty)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: PlayerHandFan(
                    cards: state.playerHands.isNotEmpty
                        ? state.playerHands[0]
                        : [],
                  ),
                ),
              ),

            // ── 8. Bottom controls (playing state only) ─────────────────
            if (state.gameStatus == GameStatus.playing)
              const Positioned(
                bottom: 76,
                left: 0,
                right: 0,
                child: BottomControls(),
              ),

            // ── 9. Menu icon (always visible) ───────────────────────────
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              child: TableMenuButton(
                roomCode: state.roomCode,
                currentRound: state.currentRound,
                totalRounds: state.totalRounds,
                totalPlayers: state.totalPlayers,
                defaultPoints: state.defaultPoints,
                onLeavePressed: () => _showExitDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C100E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
            ),
          ),
          title: const Text(
            'Leave Table?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Are you sure you want to leave the game table?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/home');
              },
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: Color(0xFFDA3633),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
