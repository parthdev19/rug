/// Screen for the notifications feature.
library;

import 'package:flutter/material.dart';

/// Notifications screen placeholder.
/// TODO: Implement the notifications UI.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
