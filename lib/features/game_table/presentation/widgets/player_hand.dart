/// Player hand display widget.
///
/// For the current user: shows face-up cards in a horizontal fan.
/// For other players: shows a small stack of card backs with a count badge.
library;

import 'package:flutter/material.dart';
import 'package:rug/features/game_table/models/card_model.dart';
import 'package:rug/features/game_table/presentation/widgets/mini_card.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

/// Horizontal fan of face-up cards for the current player.
/// Displayed at the bottom of the screen.
class PlayerHandFan extends StatelessWidget {
  const PlayerHandFan({
    required this.cards,
    super.key,
  });

  final List<PlayingCard> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    // Card overlap: tighter with more cards
    const cardWidth = 42.0;
    final totalCards = cards.length;
    final overlapFraction = totalCards > 8 ? 0.55 : 0.45;
    final visibleWidth = cardWidth * (1 - overlapFraction);
    final totalWidth = cardWidth + (totalCards - 1) * visibleWidth;
    final maxWidth = screenWidth * 0.75;
    final scale = totalWidth > maxWidth ? maxWidth / totalWidth : 1.0;

    return Transform.scale(
      scale: scale,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: totalWidth,
        height: 64,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(totalCards, (index) {
            return Positioned(
              left: index * visibleWidth,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 40)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: MiniCard(
                  card: cards[index],
                  faceUp: true,
                  width: cardWidth,
                  height: 60,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Small card-back stack with count badge for opponent players.
class OpponentCardStack extends StatelessWidget {
  const OpponentCardStack({
    required this.cardCount,
    super.key,
  });

  final int cardCount;

  @override
  Widget build(BuildContext context) {
    if (cardCount == 0) return const SizedBox.shrink();

    return SizedBox(
      width: 28,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Stacked backs
          if (cardCount > 1)
            Positioned(
              left: 2,
              top: 2,
              child: Container(
                width: 22,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF072E1F),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: SplashAnimationConstants.gold.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 22,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A3D2A), Color(0xFF072E1F)],
                ),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
          ),
          // Count badge
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0C100E),
                border: Border.all(
                  color: SplashAnimationConstants.gold.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Text(
                  '$cardCount',
                  style: const TextStyle(
                    color: SplashAnimationConstants.gold,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
