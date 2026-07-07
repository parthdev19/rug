/// Premium landscape game table screen.
///
/// Locks orientation to landscape on entry, restores portrait on exit.
/// Renders an oval felt table with dynamically positioned player seats,
/// a center info panel, top header bar, and bottom action controls.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/game_table/controller/game_table_controller.dart';
import 'package:rug/features/game_table/presentation/widgets/bottom_controls.dart';
import 'package:rug/features/game_table/presentation/widgets/player_seat.dart';
import 'package:rug/features/game_table/presentation/widgets/seat_layout_calculator.dart';
import 'package:rug/features/game_table/presentation/widgets/table_center_info.dart';
import 'package:rug/features/game_table/presentation/widgets/table_header.dart';
import 'package:rug/features/game_table/presentation/widgets/table_surface.dart';
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
    final screenSize = MediaQuery.sizeOf(context);

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
                    center: Alignment(0.0, 0.0),
                    radius: 1.2,
                    colors: [
                      Color(0xFF04180F), // Subtle emerald glow
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

            // ── 3. Center info ──────────────────────────────────────────
            Center(
              child: TableCenterInfo(
                currentRound: state.currentRound,
                totalRounds: state.totalRounds,
                defaultPoints: state.defaultPoints,
                gameStatus: state.gameStatus,
              ),
            ),

            // ── 4. Player seats ─────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final tableCenter = Offset(
                  constraints.maxWidth / 2,
                  constraints.maxHeight / 2,
                );
                // Seat ellipse is slightly smaller than the table
                // to place avatars on the edge of the table
                final seatRadiusX = screenSize.width * 0.38;
                final seatRadiusY = screenSize.height * 0.34;

                final seatPositions = SeatLayoutCalculator.computeSeats(
                  center: tableCenter,
                  radiusX: seatRadiusX,
                  radiusY: seatRadiusY,
                  playerCount: state.players.length,
                );

                return Stack(
                  children: List.generate(state.players.length, (index) {
                    final player = state.players[index];
                    final pos = seatPositions[index];

                    // Seat widget dimensions (approx)
                    const seatWidth = 72.0;
                    const seatHeight = 80.0;

                    return Positioned(
                      left: pos.dx - seatWidth / 2,
                      top: pos.dy - seatHeight / 2,
                      width: seatWidth,
                      height: seatHeight,
                      child: PlayerSeat(
                        player: player,
                        animationDelay: Duration(milliseconds: 100 + (index * 80)),
                      ),
                    );
                  }),
                );
              },
            ),

            // ── 5. Top header bar ───────────────────────────────────────
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: SafeArea(
                child: TableHeader(
                  roomCode: state.roomCode,
                  currentRound: state.currentRound,
                  totalRounds: state.totalRounds,
                  totalPlayers: state.totalPlayers,
                  onSettingsPressed: () {
                    // Settings placeholder
                  },
                  onExitPressed: () {
                    _showExitDialog(context);
                  },
                ),
              ),
            ),

            // ── 6. Bottom controls ──────────────────────────────────────
            Positioned(
              bottom: 8,
              left: screenSize.width * 0.25,
              right: screenSize.width * 0.25,
              child: const SafeArea(
                child: BottomControls(),
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
