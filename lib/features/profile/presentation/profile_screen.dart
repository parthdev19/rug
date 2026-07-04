/// Screen for the profile feature.
library;

import 'package:flutter/material.dart';

/// Profile screen placeholder.
/// TODO: Implement the profile UI.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
