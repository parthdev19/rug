/// Premium landscape game table screen.
///
/// Locks orientation to landscape on entry, restores portrait on exit.
/// Renders a capsule (rounded-rectangle) felt table with dynamically
/// positioned player seats, a center info panel, auto-hiding top toolbar,
/// and auto-hiding bottom action controls with swipe-to-reveal gestures.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/game_table/controller/game_table_controller.dart';
import 'package:rug/features/game_table/presentation/widgets/auto_hide_bar.dart';
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

  // Auto-hide bar keys for programmatic control
  final _topBarKey = GlobalKey<AutoHideBarState>();
  final _bottomBarKey = GlobalKey<AutoHideBarState>();

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

  /// Check if any player whose isCurrentPlayer=true also has isCurrentTurn=true.
  bool _isLocalPlayerTurn() {
    final state = ref.read(gameTableControllerProvider);
    return state.players.any((p) => p.isCurrentPlayer && p.isCurrentTurn);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameTableControllerProvider);
    final screenSize = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.paddingOf(context);
    final isMyTurn = _isLocalPlayerTurn();

    // Table proportions (matching TableSurface painter)
    final tableWidth = screenSize.width * 0.82;
    final tableHeight = screenSize.height * 0.67;
    final cornerRadius = screenSize.height * 0.08;
    final tableCenter = Offset(screenSize.width / 2, screenSize.height / 2);

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
                // Seat positions along the table perimeter
                final seatPositions = SeatLayoutCalculator.computeSeats(
                  center: tableCenter,
                  tableWidth: tableWidth,
                  tableHeight: tableHeight,
                  playerCount: state.players.length,
                  cornerRadius: cornerRadius,
                );

                // Seat widget dimensions
                const seatWidth = 76.0;
                const seatHeight = 96.0;

                return Stack(
                  children: List.generate(state.players.length, (index) {
                    final player = state.players[index];
                    final pos = seatPositions[index];

                    return Positioned(
                      left: pos.dx - seatWidth / 2,
                      top: pos.dy - seatHeight / 2,
                      width: seatWidth,
                      height: seatHeight,
                      child: PlayerSeat(
                        player: player,
                        animationDelay:
                            Duration(milliseconds: 100 + (index * 80)),
                      ),
                    );
                  }),
                );
              },
            ),

            // ── 5. Top swipe detection zone ─────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 44 + safePadding.top,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) > 0) {
                    // Swiped downward → show top bar
                    _topBarKey.currentState?.show();
                  }
                },
              ),
            ),

            // ── 6. Top toolbar (auto-hide) ──────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: AutoHideBar(
                    key: _topBarKey,
                    direction: AxisDirection.up,
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
              ),
            ),

            // ── 7. Bottom swipe detection zone ──────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 44 + safePadding.bottom,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < 0) {
                    // Swiped upward → show bottom bar
                    _bottomBarKey.currentState?.show();
                  }
                },
              ),
            ),

            // ── 8. Bottom controls (auto-hide) ─────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AutoHideBar(
                    key: _bottomBarKey,
                    direction: AxisDirection.down,
                    forceVisible: isMyTurn,
                    child: const BottomControls(),
                  ),
                ),
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
