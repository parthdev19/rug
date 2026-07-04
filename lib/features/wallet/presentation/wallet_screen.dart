/// Screen for the wallet feature.
library;

import 'package:flutter/material.dart';

/// Wallet screen placeholder.
/// TODO: Implement the wallet UI.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Wallet',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
