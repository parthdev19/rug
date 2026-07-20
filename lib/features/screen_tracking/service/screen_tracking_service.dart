/// Automatic screen tracking service.
///
/// Listens to GoRouter's routerDelegate for route changes and posts every
/// unique screen transition to the backend via [ScreenInfoRepository].
///
/// Game Table special handling:
/// The API is called once when the user *enters* a game screen.  While
/// [_isInGameScreen] is `true` any further navigation events within the game
/// are silently ignored.  Tracking resumes when the user returns to a
/// top-level non-game route.
library;

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:rug/features/screen_tracking/models/screen_info_model.dart';
import 'package:rug/features/screen_tracking/repository/screen_info_repository.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/services/storage/secure_storage_service.dart';

/// Route names that represent the main game screen.
///
/// Extend this set if new game screens are added.
const _kGameScreenRoutes = {
  'gameTable',
  'multiplayerTable',
  'onlineMatch',
};

/// Top-level non-game route names that signal the user has left the game.
const _kNonGameRoutes = {
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

/// Hard-coded snake_case overrides for camelCase route names that do not
/// follow a simple camelCase → snake_case conversion.
const _kRouteNameOverrides = {
  'forgotPassword': 'forgot_password_screen',
  'verifyOtp': 'verify_otp_screen',
  'resetPassword': 'reset_password_screen',
  'guestUsername': 'guest_username_screen',
  'createGame': 'create_game_screen',
  'gameTable': 'game_table_screen',
  'gameLobby': 'game_lobby_screen',
  'privateRoom': 'private_room_screen',
  'multiplayerTable': 'multiplayer_table_screen',
  'onlineMatch': 'online_match_screen',
};

/// Converts a camelCase GoRouter route name to a snake_case screen name and
/// appends `_screen` if not already present.
String formatScreenName(String routeName) {
  if (_kRouteNameOverrides.containsKey(routeName)) {
    return _kRouteNameOverrides[routeName]!;
  }
  final regex = RegExp(r'(?<=[a-z])[A-Z]');
  String snake = routeName
      .replaceAllMapped(regex, (m) => '_${m.group(0)!.toLowerCase()}')
      .toLowerCase();
  if (!snake.endsWith('_screen')) {
    snake = '${snake}_screen';
  }
  return snake;
}

/// Hooks into GoRouter's delegate and tracks every unique screen change.
///
/// Usage — call [attach] once after the router is created:
/// ```dart
/// final tracker = ScreenTracker(readUserId: () => ref.read(currentUserIdProvider));
/// tracker.attach(router);
/// ```
class ScreenTracker {
  ScreenTracker({required this.readUserId});

  /// Callback that returns the current user ID string (or null if unknown).
  final String? Function() readUserId;

  final ScreenInfoRepository _repository = ScreenInfoRepository.instance;

  String? _lastTrackedScreen;
  bool _isInGameScreen = false;
  GoRouter? _router;

  /// Attaches this tracker to the given [GoRouter] instance.
  ///
  /// Listens to the router delegate so every GoRouter navigation event
  /// (push, pop, replace, redirect) triggers tracking.
  void attach(GoRouter router) {
    _router = router;
    router.routerDelegate.addListener(_onRouteChange);
    AppLogger.debug('ScreenTracker attached to GoRouter');
  }

  /// Detaches the listener. Call on dispose.
  void detach() {
    _router?.routerDelegate.removeListener(_onRouteChange);
    _router = null;
  }

  /// Simulates a navigation to [routeName] — for unit testing only.
  @visibleForTesting
  void simulateRouteChange(String routeName) {
    final screenName = formatScreenName(routeName);
    final isGameRoute = _kGameScreenRoutes.contains(routeName);

    if (isGameRoute) {
      if (!_isInGameScreen) {
        _isInGameScreen = true;
        _submit(screenName);
      }
    } else {
      if (_isInGameScreen) {
        if (_kNonGameRoutes.contains(routeName)) {
          _isInGameScreen = false;
          _submitIfNew(screenName);
        }
      } else {
        _submitIfNew(screenName);
      }
    }
  }

  void _onRouteChange() {
    final router = _router;
    if (router == null) return;

    // Extract the name of the current topmost route from the delegate's
    // configuration. GoRouter exposes the matched routes as a list; the last
    // entry is the currently visible page.
    final matches = router.routerDelegate.currentConfiguration.matches;
    if (matches.isEmpty) return;

    // Walk from the end of the match list to find the first GoRoute with a name.
    // RouteBase is the abstract supertype; GoRoute (which extends RouteBase)
    // is the concrete type that carries the `name` field.
    String? routeName;
    for (final match in matches.reversed) {
      final route = match.route;
      if (route is GoRoute) {
        final name = route.name;
        if (name != null && name.isNotEmpty) {
          routeName = name;
          break;
        }
      }
    }

    if (routeName == null) return;

    final screenName = formatScreenName(routeName);
    final isGameRoute = _kGameScreenRoutes.contains(routeName);

    if (isGameRoute) {
      if (!_isInGameScreen) {
        _isInGameScreen = true;
        _submit(screenName);
      }
    } else {
      if (_isInGameScreen) {
        if (_kNonGameRoutes.contains(routeName)) {
          _isInGameScreen = false;
          _submitIfNew(screenName);
        }
      } else {
        _submitIfNew(screenName);
      }
    }
  }

  void _submitIfNew(String screenName) {
    if (_lastTrackedScreen == screenName) return;
    _submit(screenName);
  }

  void _submit(String screenName) async {
    _lastTrackedScreen = screenName;

    final rawUserId = readUserId();
    int userId = 0;
    if (rawUserId != null && rawUserId.isNotEmpty) {
      if (rawUserId.startsWith('guest_')) {
        final numericPart = rawUserId.replaceFirst('guest_', '');
        userId = int.tryParse(numericPart) ?? 0;
      } else {
        userId = int.tryParse(rawUserId) ?? 0;
      }
    }

    if (userId <= 0) {
      final storedId = await SecureStorageService.instance.getDeviceUserId();
      userId = storedId ?? 0;
    }

    final entry = ScreenInfoModel(
      screenName: screenName,
      screenTime: DateTime.now().toUtc(),
    );

    AppLogger.debug('Screen tracked → "$screenName" (user_id: $userId)');

    _repository.trackScreen(userId: userId, entry: entry);
  }
}
