/// Screen for the friends feature.
library;

import 'package:flutter/material.dart';

/// Friends screen placeholder.
/// TODO: Implement the friends UI.
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Friends',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
