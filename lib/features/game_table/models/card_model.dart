/// Playing card model and deck utilities for the RUG card game.
///
/// Represents a standard 52-card deck with shuffle and distribution logic.
library;

import 'dart:math';

/// The four card suits.
enum Suit { clubs, diamonds, hearts, spades }

/// Card ranks from Ace through King.
enum Rank { ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king }

/// A single playing card.
class PlayingCard {
  const PlayingCard({required this.suit, required this.rank});

  /// Create a card from index 0–51.
  factory PlayingCard.fromIndex(int index) {
    return PlayingCard(
      suit: Suit.values[index ~/ 13],
      rank: Rank.values[index % 13],
    );
  }

  final Suit suit;
  final Rank rank;

  /// Unique index 0–51.
  int get index => suit.index * 13 + rank.index;

  /// Display label for the rank.
  String get rankLabel => switch (rank) {
    Rank.ace => 'A',
    Rank.two => '2',
    Rank.three => '3',
    Rank.four => '4',
    Rank.five => '5',
    Rank.six => '6',
    Rank.seven => '7',
    Rank.eight => '8',
    Rank.nine => '9',
    Rank.ten => '10',
    Rank.jack => 'J',
    Rank.queen => 'Q',
    Rank.king => 'K',
  };

  /// Unicode suit symbol.
  String get suitSymbol => switch (suit) {
    Suit.clubs => '♣',
    Suit.diamonds => '♦',
    Suit.hearts => '♥',
    Suit.spades => '♠',
  };

  /// Whether this suit is red.
  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  @override
  String toString() => '$rankLabel$suitSymbol';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard && suit == other.suit && rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}

/// Utility class for deck operations.
class Deck {
  Deck._();

  /// Returns a full 52-card deck in order.
  static List<PlayingCard> fullDeck() {
    return [
      for (final suit in Suit.values)
        for (final rank in Rank.values) PlayingCard(suit: suit, rank: rank),
    ];
  }

  /// Shuffles a deck in-place and returns it.
  static List<PlayingCard> shuffle(List<PlayingCard> deck, [Random? rng]) {
    final random = rng ?? Random();
    deck.shuffle(random);
    return deck;
  }

  /// Distributes cards equally among [playerCount] players.
  ///
  /// Returns a record with `hands` (list of lists) and `drawPile` (remaining).
  static ({List<List<PlayingCard>> hands, List<PlayingCard> drawPile}) distribute({
    required List<PlayingCard> deck,
    required int playerCount,
  }) {
    final cardsPerPlayer = deck.length ~/ playerCount;
    final hands = <List<PlayingCard>>[];

    for (int i = 0; i < playerCount; i++) {
      hands.add(deck.sublist(i * cardsPerPlayer, (i + 1) * cardsPerPlayer));
    }

    final drawPile = deck.sublist(playerCount * cardsPerPlayer);
    return (hands: hands, drawPile: drawPile);
  }
}
