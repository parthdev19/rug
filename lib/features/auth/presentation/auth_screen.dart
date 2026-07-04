/// Screen for the auth feature.
library;

import 'package:flutter/material.dart';

/// Auth screen placeholder.
/// TODO: Implement the auth UI.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Auth',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
