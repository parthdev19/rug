/// Composite player seat widget positioned around the table.
///
/// Shows avatar, username, status, dealer chip, and
/// slide-in entrance animation. Turn glow is handled by [TurnIndicator].
library;

import 'package:flutter/material.dart';
import 'package:rug/features/game_table/models/player_seat_model.dart';
import 'package:rug/features/game_table/presentation/widgets/player_avatar.dart';
import 'package:rug/features/game_table/presentation/widgets/turn_indicator.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class PlayerSeat extends StatefulWidget {
  const PlayerSeat({
    required this.player,
    this.animationDelay = Duration.zero,
    super.key,
  });

  final PlayerSeatModel player;
  final Duration animationDelay;

  @override
  State<PlayerSeat> createState() => _PlayerSeatState();
}

class _PlayerSeatState extends State<PlayerSeat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.animationDelay, () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Turn indicator wrapping the avatar
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                TurnIndicator(
                  isActive: widget.player.isCurrentTurn,
                  size: 58,
                  showBadge: widget.player.isCurrentTurn &&
                      widget.player.isCurrentPlayer,
                  child: PlayerAvatar(
                    player: widget.player,
                    size: 48,
                  ),
                ),
                // Dealer chip — positioned to avoid avatar overlap
                if (widget.player.isDealer)
                  Positioned(
                    top: -2,
                    right: -10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            SplashAnimationConstants.brightGold,
                            SplashAnimationConstants.gold,
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFF0C100E),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SplashAnimationConstants.gold.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'D',
                          style: TextStyle(
                            color: Color(0xFF0C100E),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),

            // Username with text shadow for readability
            Text(
              widget.player.isCurrentPlayer ? 'You' : widget.player.username,
              style: TextStyle(
                color: widget.player.isCurrentPlayer
                    ? SplashAnimationConstants.emerald
                    : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                shadows: const [
                  Shadow(
                    color: Color(0xCC000000),
                    blurRadius: 4,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Status badge
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _statusColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                _statusText,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _statusText {
    return switch (widget.player.status) {
      PlayerStatus.waiting => 'WAITING',
      PlayerStatus.ready => 'READY',
      PlayerStatus.playing => 'PLAYING',
      PlayerStatus.folded => 'FOLDED',
    };
  }

  Color get _statusColor {
    return switch (widget.player.status) {
      PlayerStatus.waiting => SplashAnimationConstants.gold,
      PlayerStatus.ready => SplashAnimationConstants.emerald,
      PlayerStatus.playing => SplashAnimationConstants.emerald,
      PlayerStatus.folded => const Color(0xFFDA3633),
    };
  }
}
