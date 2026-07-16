/// GoRouter configuration for the RUG application.
///
/// Scalable routing with auth guards, shell routes for bottom nav,
/// and named routes for deep linking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/presentation/auth_screen.dart';
import 'package:rug/features/auth/presentation/email_sign_in_screen.dart';
import 'package:rug/features/auth/presentation/register_screen.dart';
import 'package:rug/features/auth/presentation/forgot_password_screen.dart';
import 'package:rug/features/auth/presentation/otp_verification_screen.dart';
import 'package:rug/features/auth/presentation/reset_password_screen.dart';
import 'package:rug/features/auth/presentation/guest_username_screen.dart';
import 'package:rug/features/home/presentation/home_screen.dart';
import 'package:rug/features/create_game/presentation/create_game_screen.dart';
import 'package:rug/features/game_table/presentation/game_table_screen.dart';
import 'package:rug/features/splash/presentation/splash_screen.dart';
import 'package:rug/routes/route_names.dart';
import 'package:rug/services/device/screen_tracker_service.dart';
import 'package:rug/shared/providers/common_providers.dart';

/// GoRouter provider — reads auth state for redirects.
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    observers: [
      ScreenTrackerObserver(
        readUserId: () => ref.read(currentUserIdProvider),
      ),
    ],
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
            pageBuilder: (context, state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const EmailSignInScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.05);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  final offsetAnimation = animation.drive(tween);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'register',
            name: 'register',
            pageBuilder: (context, state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const RegisterScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.05);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  final offsetAnimation = animation.drive(tween);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'forgot-password',
            name: 'forgotPassword',
            pageBuilder: (context, state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const ForgotPasswordScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.05);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  final offsetAnimation = animation.drive(tween);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'verify-otp',
            name: 'verifyOtp',
            pageBuilder: (context, state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const OtpVerificationScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.05);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  final offsetAnimation = animation.drive(tween);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'reset-password',
            name: 'resetPassword',
            pageBuilder: (context, state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const ResetPasswordScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.05);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  final offsetAnimation = animation.drive(tween);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'guest-username',
            name: 'guestUsername',
            pageBuilder: (context, state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: const GuestUsernameScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.05);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  final offsetAnimation = animation.drive(tween);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      // Main App (Shell route for bottom nav)
      // TODO: Replace with ShellRoute when bottom nav is implemented
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
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
        path: RouteNames.createGame,
        name: 'createGame',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const CreateGameScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.05);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              final tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );
              final offsetAnimation = animation.drive(tween);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: RouteNames.gameTable,
        name: 'gameTable',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const GameTableScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
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

/// NavigatorObserver that monitors and logs user screen entries to the backend API.
class ScreenTrackerObserver extends NavigatorObserver {
  ScreenTrackerObserver({required this.readUserId});

  final String? Function() readUserId;
  String? _lastScreen;
  bool _isInGame = false;

  // List of route names representing the main active game screen
  static const _gameRoutes = {
    'gameTable',
    'multiplayerTable',
    'onlineMatch',
  };

  // Top-level non-game route names that signify returning from the game
  static const _nonGameRoutes = {
    'splash',
    'auth',
    'login',
    'register',
    'forgotPassword',
    'verifyOtp',
    'resetPassword',
    'guestUsername',
    'home',
    'profile',
    'settings',
    'createGame',
    'friends',
    'leaderboard',
    'rewards',
    'wallet',
    'notifications',
  };

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _processRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _processRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _processRoute(newRoute);
    }
  }

  void _processRoute(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName == null || routeName.isEmpty) return;

    final formattedName = _formatScreenName(routeName);
    final isGameScreen = _gameRoutes.contains(routeName);

    if (isGameScreen) {
      if (!_isInGame) {
        _isInGame = true;
        _sendScreenTrack(formattedName);
      }
    } else {
      if (_isInGame) {
        if (_nonGameRoutes.contains(routeName)) {
          _isInGame = false;
          if (_lastScreen != formattedName) {
            _sendScreenTrack(formattedName);
          }
        }
      } else {
        if (_lastScreen != formattedName) {
          _sendScreenTrack(formattedName);
        }
      }
    }
  }

  void _sendScreenTrack(String formattedName) {
    _lastScreen = formattedName;
    final userId = readUserId();
    ScreenTrackerService.instance.trackScreen(formattedName, userId: userId);
  }

  String _formatScreenName(String name) {
    switch (name) {
      case 'forgotPassword':
        return 'forgot_password_screen';
      case 'verifyOtp':
        return 'verify_otp_screen';
      case 'resetPassword':
        return 'reset_password_screen';
      case 'guestUsername':
        return 'guest_username_screen';
      case 'createGame':
        return 'create_game_screen';
      case 'gameTable':
        return 'game_table_screen';
      case 'gameLobby':
        return 'game_lobby_screen';
      case 'privateRoom':
        return 'private_room_screen';
      case 'multiplayerTable':
        return 'multiplayer_table_screen';
      case 'onlineMatch':
        return 'online_match_screen';
      default:
        // Convert camelCase to snake_case and append _screen
        final regex = RegExp(r'(?<=[a-z])[A-Z]');
        String snake = name
            .replaceAllMapped(regex, (m) => '_${m.group(0)!.toLowerCase()}')
            .toLowerCase();
        if (!snake.endsWith('_screen')) {
          snake = '${snake}_screen';
        }
        return snake;
    }
  }
}
