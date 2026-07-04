/// Screen for the game_lobby feature.
library;

import 'package:flutter/material.dart';

/// GameLobby screen placeholder.
/// TODO: Implement the game_lobby UI.
class GameLobbyScreen extends StatelessWidget {
  const GameLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'GameLobby',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
