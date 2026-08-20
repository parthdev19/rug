/// GoRouter configuration for the RUG application.
///
/// Scalable routing with auth guards, shell routes for bottom nav,
/// and named routes for deep linking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/auth/presentation/auth_screen.dart';
import 'package:rug/features/auth/presentation/auth_loading_screen.dart';
import 'package:rug/features/auth/presentation/email_sign_in_screen.dart';
import 'package:rug/features/auth/presentation/register_screen.dart';
import 'package:rug/features/auth/presentation/forgot_password_screen.dart';
import 'package:rug/features/auth/presentation/otp_verification_screen.dart';
import 'package:rug/features/auth/presentation/reset_password_screen.dart';
import 'package:rug/features/auth/presentation/guest_username_screen.dart';
import 'package:rug/features/auth/presentation/set_username_screen.dart';
import 'package:rug/features/auth/presentation/sign_up_otp_verification_screen.dart';
import 'package:rug/features/home/presentation/home_screen.dart';
import 'package:rug/features/create_game/presentation/create_game_screen.dart';
import 'package:rug/features/game_table/presentation/game_table_screen.dart';
import 'package:rug/features/splash/presentation/splash_screen.dart';
import 'package:rug/routes/route_names.dart';
import 'package:rug/features/screen_tracking/service/screen_tracking_service.dart';
import 'package:rug/shared/providers/common_providers.dart';

/// Notifier that triggers GoRouter redirect re-evaluation whenever auth or user state changes.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(currentUserProvider, (_, __) => notifyListeners());
    _ref.listen(isAuthenticatedProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

final routerNotifierProvider =
    Provider<RouterNotifier>((ref) => RouterNotifier(ref));

/// GoRouter provider for the app's navigation graph.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  final router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final isAuth = ref.read(isAuthenticatedProvider);
      final location = state.uri.path;

      // If user is authenticated, but user is null or is_username_set: false or username is empty/null,
      // force redirection to setUsername screen unless they're already on setUsername, postLoginLoading, or splash.
      if (isAuth &&
          (user == null ||
              !user.isUsernameSet ||
              user.username.trim().isEmpty)) {
        if (location != RouteNames.setUsername &&
            location != RouteNames.postLoginLoading &&
            location != RouteNames.splash) {
          return RouteNames.setUsername;
        }
      }

      // If user has set a username and attempts to visit setUsername or any auth screen, redirect to home.
      if (isAuth &&
          user != null &&
          user.isUsernameSet &&
          user.username.trim().isNotEmpty) {
        if (location == RouteNames.setUsername ||
            (location.startsWith('/auth') &&
                location != RouteNames.postLoginLoading)) {
          return RouteNames.home;
        }
      }

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

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
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

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
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

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
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

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
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

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
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

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
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
            path: 'sign-up-verify-otp',
            name: 'signUpVerifyOtp',
            pageBuilder: (context, state) {
              final email = state.uri.queryParameters['email'] ?? '';
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: SignUpOtpVerificationScreen(email: email),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 0.05);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
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

      // Set Username (mandatory onboarding — shown when is_username_set: false)
      GoRoute(
        path: RouteNames.setUsername,
        name: 'setUsername',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SetUsernameScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.05);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
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

      // Main App (Shell route for bottom nav)
      // TODO: Replace with ShellRoute when bottom nav is implemented
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.postLoginLoading,
        name: 'postLoginLoading',
        builder: (context, state) => const AuthLoadingScreen(),
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
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.05);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
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
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
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

  // Attach the screen tracker to the router delegate so it fires on every
  // GoRouter navigation event (push, pop, redirect, etc.).
  ScreenTracker(
    readUserId: () => ref.read(currentUserIdProvider),
  ).attach(router);

  return router;
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
