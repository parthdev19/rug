/// Compact card widget for display in the player hand and dealing animation.
///
/// Two modes: face-up (shows rank + suit) and face-down (card back pattern).
library;

import 'package:flutter/material.dart';
import 'package:rug/features/game_table/models/card_model.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class MiniCard extends StatelessWidget {
  const MiniCard({
    this.card,
    this.faceUp = true,
    this.width = 42,
    this.height = 60,
    super.key,
  });

  /// The card to display. If null and faceUp is true, shows a blank card.
  final PlayingCard? card;

  /// Whether to show the card face or back.
  final bool faceUp;

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: faceUp && card != null ? _buildFace() : _buildBack(),
      ),
    );
  }

  Widget _buildFace() {
    final c = card!;
    final textColor = c.isRed ? const Color(0xFFD32F2F) : const Color(0xFF212121);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFE0D6C2),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank + suit at top-left
            Text(
              c.rankLabel,
              style: TextStyle(
                color: textColor,
                fontSize: height * 0.2,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
            Text(
              c.suitSymbol,
              style: TextStyle(
                color: textColor,
                fontSize: height * 0.15,
                height: 1.0,
              ),
            ),
            const Spacer(),
            // Center suit
            Center(
              child: Text(
                c.suitSymbol,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.3),
                  fontSize: height * 0.28,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: SplashAnimationConstants.gold.withValues(alpha: 0.3),
          width: 1,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A3D2A),
            Color(0xFF072E1F),
            Color(0xFF0A3D2A),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: width * 0.6,
          height: height * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: SplashAnimationConstants.gold.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              '♣',
              style: TextStyle(
                color: SplashAnimationConstants.gold.withValues(alpha: 0.25),
                fontSize: height * 0.22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
