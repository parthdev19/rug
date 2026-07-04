/// Screen for the rewards feature.
library;

import 'package:flutter/material.dart';

/// Rewards screen placeholder.
/// TODO: Implement the rewards UI.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Rewards',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
