/// Screen for the home feature.
library;

import 'package:flutter/material.dart';

/// Home screen placeholder.
/// TODO: Implement the home UI.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Home',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
