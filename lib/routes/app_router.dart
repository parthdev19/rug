/// GoRouter configuration for the RUG application.
///
/// Scalable routing with auth guards, shell routes for bottom nav,
/// and named routes for deep linking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/presentation/auth_screen.dart';
import 'package:rug/features/splash/presentation/splash_screen.dart';
import 'package:rug/routes/route_names.dart';
import 'package:rug/shared/providers/common_providers.dart';

/// GoRouter provider — reads auth state for redirects.
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final currentPath = state.uri.path;
      final isOnAuth = currentPath.startsWith(RouteNames.auth);
      final isOnSplash = currentPath == RouteNames.splash;

      // Allow splash screen always
      if (isOnSplash) return null;

      // Not authenticated → redirect to auth
      if (!isAuthenticated && !isOnAuth) return RouteNames.auth;

      // Authenticated but on auth screen → redirect to home
      if (isAuthenticated && isOnAuth) return RouteNames.home;

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: RouteNames.auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) =>
                const _PlaceholderScreen(name: 'Login'),
          ),
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (context, state) =>
                const _PlaceholderScreen(name: 'Register'),
          ),
        ],
      ),

      // Main App (Shell route for bottom nav)
      // TODO: Replace with ShellRoute when bottom nav is implemented
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(name: 'Home'),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const _PlaceholderScreen(name: 'Profile'),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const _PlaceholderScreen(name: 'Settings'),
      ),

      // Game
      GoRoute(
        path: RouteNames.gameLobby,
        name: 'gameLobby',
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Game Lobby'),
      ),
      GoRoute(
        path: RouteNames.privateRoom,
        name: 'privateRoom',
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Private Room'),
      ),
      GoRoute(
        path: RouteNames.multiplayerTable,
        name: 'multiplayerTable',
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Multiplayer Table'),
      ),
      GoRoute(
        path: RouteNames.onlineMatch,
        name: 'onlineMatch',
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Online Match'),
      ),

      // Social
      GoRoute(
        path: RouteNames.friends,
        name: 'friends',
        builder: (context, state) => const _PlaceholderScreen(name: 'Friends'),
      ),
      GoRoute(
        path: RouteNames.leaderboard,
        name: 'leaderboard',
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Leaderboard'),
      ),

      // Economy
      GoRoute(
        path: RouteNames.rewards,
        name: 'rewards',
        builder: (context, state) => const _PlaceholderScreen(name: 'Rewards'),
      ),
      GoRoute(
        path: RouteNames.wallet,
        name: 'wallet',
        builder: (context, state) => const _PlaceholderScreen(name: 'Wallet'),
      ),

      // Notifications
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Notifications'),
      ),
    ],
    errorBuilder: (context, state) =>
        _PlaceholderScreen(name: '404 — ${state.uri.path}'),
  );
});

/// Temporary placeholder screen.
/// Will be replaced with actual feature screens.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$name Screen\n(Placeholder)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
