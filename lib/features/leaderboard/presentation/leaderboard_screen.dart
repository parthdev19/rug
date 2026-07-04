/// Screen for the leaderboard feature.
library;

import 'package:flutter/material.dart';

/// Leaderboard screen placeholder.
/// TODO: Implement the leaderboard UI.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Leaderboard',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
