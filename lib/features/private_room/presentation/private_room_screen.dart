/// Screen for the private_room feature.
library;

import 'package:flutter/material.dart';

/// PrivateRoom screen placeholder.
/// TODO: Implement the private_room UI.
class PrivateRoomScreen extends StatelessWidget {
  const PrivateRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'PrivateRoom',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
