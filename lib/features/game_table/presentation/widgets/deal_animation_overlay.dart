/// Animated card dealing overlay.
///
/// Shows a deck in the center, then animates cards flying one-by-one
/// to each player's seat position in round-robin order.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rug/features/game_table/presentation/widgets/mini_card.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class DealAnimationOverlay extends StatefulWidget {
  const DealAnimationOverlay({
    required this.playerCount,
    required this.seatPositions,
    required this.onComplete,
    super.key,
  });

  /// Number of players at the table.
  final int playerCount;

  /// Pixel positions of each player seat (index 0 = current user at bottom).
  final List<Offset> seatPositions;

  /// Called when dealing animation finishes.
  final VoidCallback onComplete;

  @override
  State<DealAnimationOverlay> createState() => _DealAnimationOverlayState();
}

class _DealAnimationOverlayState extends State<DealAnimationOverlay> {
  final List<_FlyingCardState> _flyingCards = [];
  int _totalCardsDealt = 0;
  bool _dealingComplete = false;

  int get _cardsPerPlayer => 52 ~/ widget.playerCount;
  int get _totalCardsToAnimate {
    // Animate the first 2 rounds of dealing for visual effect, then batch the rest.
    // Full animation of all cards would be too long.
    final fullRounds = (_cardsPerPlayer).clamp(1, 3);
    return fullRounds * widget.playerCount;
  }

  @override
  void initState() {
    super.initState();
    _startDealing();
  }

  Future<void> _startDealing() async {
    // Short delay before dealing begins
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    for (int i = 0; i < _totalCardsToAnimate; i++) {
      if (!mounted) return;

      final playerIndex = i % widget.playerCount;
      final targetPos = widget.seatPositions[playerIndex];

      setState(() {
        _flyingCards.add(_FlyingCardState(
          id: i,
          targetPosition: targetPos,
          delay: Duration.zero,
        ));
        _totalCardsDealt = i + 1;
      });

      // Stagger: faster for subsequent cards
      await Future.delayed(Duration(milliseconds: i < widget.playerCount ? 180 : 100));
    }

    // Short pause after last card
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() => _dealingComplete = true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final deckCenter = Offset(screenSize.width / 2, screenSize.height / 2);

    return IgnorePointer(
      child: Stack(
        children: [
          // Deck stack at center (shrinks as cards are dealt)
          if (!_dealingComplete)
            Positioned(
              left: deckCenter.dx - 24,
              top: deckCenter.dy - 34,
              child: _DeckStack(
                remaining: (_totalCardsToAnimate - _totalCardsDealt)
                    .clamp(0, _totalCardsToAnimate),
                total: _totalCardsToAnimate,
              ),
            ),

          // Flying cards
          for (final card in _flyingCards)
            _FlyingCard(
              key: ValueKey(card.id),
              startPosition: deckCenter,
              endPosition: card.targetPosition,
              delay: card.delay,
            ),
        ],
      ),
    );
  }
}

class _FlyingCardState {
  const _FlyingCardState({
    required this.id,
    required this.targetPosition,
    required this.delay,
  });

  final int id;
  final Offset targetPosition;
  final Duration delay;
}

class _FlyingCard extends StatefulWidget {
  const _FlyingCard({
    required this.startPosition,
    required this.endPosition,
    required this.delay,
    super.key,
  });

  final Offset startPosition;
  final Offset endPosition;
  final Duration delay;

  @override
  State<_FlyingCard> createState() => _FlyingCardWidgetState();
}

class _FlyingCardWidgetState extends State<_FlyingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _positionAnim;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _positionAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _rotationAnim = Tween<double>(
      begin: (math.Random().nextDouble() - 0.5) * 0.4,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _positionAnim.value;
        final currentX = widget.startPosition.dx +
            (widget.endPosition.dx - widget.startPosition.dx) * t;
        final currentY = widget.startPosition.dy +
            (widget.endPosition.dy - widget.startPosition.dy) * t;

        return Positioned(
          left: currentX - 18,
          top: currentY - 26,
          child: Opacity(
            opacity: _opacityAnim.value,
            child: Transform.rotate(
              angle: _rotationAnim.value,
              child: const MiniCard(
                faceUp: false,
                width: 36,
                height: 52,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeckStack extends StatelessWidget {
  const _DeckStack({required this.remaining, required this.total});

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final stackHeight = (remaining / total * 6).clamp(0.0, 6.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stacked card backs
        SizedBox(
          width: 48,
          height: 68 + stackHeight,
          child: Stack(
            children: [
              // Shadow cards
              for (int i = 0; i < stackHeight.ceil().clamp(0, 3); i++)
                Positioned(
                  left: 0,
                  top: stackHeight - (i * 2.0),
                  child: Container(
                    width: 48,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFF072E1F),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: SplashAnimationConstants.gold.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              // Top card
              Positioned(
                left: 0,
                top: 0,
                child: const MiniCard(
                  faceUp: false,
                  width: 48,
                  height: 68,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
