/// Short transition displayed after a successful sign-in.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';
import 'package:rug/routes/route_names.dart';
import 'package:rug/shared/providers/common_providers.dart';

class AuthLoadingScreen extends ConsumerStatefulWidget {
  const AuthLoadingScreen({super.key});

  @override
  ConsumerState<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends ConsumerState<AuthLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Brief intentional pause for visual polish.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final user = ref.read(currentUserProvider);

    // If user is null, or backend flagged is_username_set: false, or username is null/empty,
    // redirect to the set-username onboarding screen before entering the home flow.
    if (user == null || !user.isUsernameSet || user.username.trim().isEmpty) {
      context.go(RouteNames.setUsername);
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF050807),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: SplashAnimationConstants.gold,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Entering the table…',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

