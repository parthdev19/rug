/// Screen for the settings feature.
library;

import 'package:flutter/material.dart';

/// Settings screen placeholder.
/// TODO: Implement the settings UI.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
