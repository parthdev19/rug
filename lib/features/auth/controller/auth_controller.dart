import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rug/features/auth/domain/repositories/auth_repository.dart';
import 'package:rug/shared/providers/common_providers.dart';
import 'package:rug/services/logging/app_logger.dart';

part 'auth_controller.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl();
}

@riverpod
GoogleSignIn googleSignIn(Ref ref) {
  return GoogleSignIn(
    serverClientId:
        '831908426755-5vihm1rqj544oaenr98j1hi67jsrr6db.apps.googleusercontent.com',
  );
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final googleSignInInstance = ref.read(googleSignInProvider);

      // Force sign-out before signing in to allow account selection
      await googleSignInInstance.signOut().catchError((_) => null);

      final account = await googleSignInInstance.signIn();
      if (account == null) {
        // User cancelled the flow
        state = const AsyncData(null);
        return false;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw Exception(
          'Google login succeeded, but no ID token was retrieved.',
        );
      }

      final repository = ref.read(authRepositoryProvider);
      final user = await repository.socialSignIn(
        email: account.email,
        googleAuthToken: idToken,
        username: _fallbackUsername(account.email),
      );

      if (user != null) {
        ref.read(currentUserProvider.notifier).setUser(user);
        ref.read(currentUserIdProvider.notifier).setUserId(user.id);
        ref.read(isAuthenticatedProvider.notifier).setAuthenticated(true);
        state = const AsyncData(null);
        return true;
      }

      throw Exception('Authentication response was invalid.');
    } on PlatformException catch (e, st) {
      AppLogger.error('Google Sign In failed', error: e, stackTrace: st);
      final error =
          e.code == 'sign_in_failed' && e.message?.contains(': 10:') == true
          ? Exception(
              'Google Sign-In is not configured for this Android app. '
              'Add the app package and signing certificate in Firebase, then download a new google-services.json.',
            )
          : Exception(e.message ?? 'Google Sign-In failed. Please try again.');
      state = AsyncError(error, st);
      return false;
    } catch (e, st) {
      AppLogger.error('Google Sign In failed', error: e, stackTrace: st);
      state = AsyncError(e, st);
      return false;
    }
  }

  String _fallbackUsername(String email) {
    final localPart = email.split('@').first;
    return localPart.isEmpty ? 'player' : localPart;
  }
}
