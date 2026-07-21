import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/features/auth/controller/auth_controller.dart';
import 'package:rug/features/auth/data/datasources/auth_api.dart';
import 'package:rug/shared/providers/common_providers.dart';
import 'package:rug/services/storage/secure_storage_service.dart';
import 'package:rug/config/env/env_config.dart';
import 'package:rug/core/enums/app_enums.dart';
import 'package:rug/services/logging/app_logger.dart';

class MockAdapter implements HttpClientAdapter {
  late Map<String, dynamic> _responseJson;
  late int _statusCode;
  RequestOptions? lastRequestOptions;

  void setResponse(Map<String, dynamic> json, {int statusCode = 200}) {
    _responseJson = json;
    _statusCode = statusCode;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    return ResponseBody.fromString(
      jsonEncode(_responseJson),
      _statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeGoogleSignInAuthentication implements GoogleSignInAuthentication {
  @override
  final String? idToken;
  @override
  final String? accessToken;

  FakeGoogleSignInAuthentication({
    this.idToken = 'mock_id_token',
    this.accessToken = 'mock_access_token',
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoogleSignInAccount implements GoogleSignInAccount {
  @override
  final String email;
  final FakeGoogleSignInAuthentication _auth;

  FakeGoogleSignInAccount({
    this.email = 'test@gmail.com',
    FakeGoogleSignInAuthentication? auth,
  }) : _auth = auth ?? FakeGoogleSignInAuthentication();

  @override
  Future<GoogleSignInAuthentication> get authentication async => _auth;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoogleSignIn implements GoogleSignIn {
  final FakeGoogleSignInAccount? _account;
  bool signedIn = false;
  bool signedOut = false;

  FakeGoogleSignIn({FakeGoogleSignInAccount? account}) : _account = account;

  @override
  Future<GoogleSignInAccount?> signIn() async {
    signedIn = true;
    return _account;
  }

  @override
  Future<GoogleSignInAccount?> signOut() async {
    signedOut = true;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Google Sign-In API & Controller Tests', () {
    late MockAdapter mockAdapter;
    late SecureStorageService secureStorage;

    setUpAll(() {
      AppLogger.init(enableLogging: false);
      EnvConfig.init(AppFlavor.dev);
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      secureStorage = SecureStorageService.instance;
      await secureStorage.clearAll();

      mockAdapter = MockAdapter();
      AuthApi.instance.dio = Dio()..httpClientAdapter = mockAdapter;
    });

    test(
      'AuthApi socialSignIn returns data map on successful 200/201 response',
      () async {
        mockAdapter.setResponse({
          'success': true,
          'statuscode': 1,
          'message': 'Success',
          'data': {
            'id': 42,
            'token': 'mock_jwt_token',
            'username': 'test_user',
            'profile': 'https://profile.url',
          },
        });

        final result = await AuthApi.instance.socialSignIn(
          email: 'test@gmail.com',
          deviceId: 'device_123',
          googleAuthToken: 'google_token',
          username: 'test_user',
        );

        expect(result['id'], 42);
        expect(result['token'], 'mock_jwt_token');
        expect(result['username'], 'test_user');
        expect(result['profile'], 'https://profile.url');
        final request = mockAdapter.lastRequestOptions!;
        expect(request.path, ApiConstants.appSignUp);
        expect(request.data, isA<FormData>());
        expect(
          Map<String, String>.fromEntries((request.data as FormData).fields),
          {
            'device_id': 'device_123',
            'google_auth_token': 'google_token',
            'is_social_login': 'true',
            'lang': 'en',
            'email': 'test@gmail.com',
            'long': '0.0',
            'username': 'test_user',
          },
        );
      },
    );

    test(
      'AuthController signInWithGoogle updates state and saves session credentials',
      () async {
        mockAdapter.setResponse({
          'success': true,
          'statuscode': 1,
          'message': 'Success',
          'data': {
            'id': 99,
            'token': 'valid_session_token',
            'username': 'google_player',
            'profile': 'https://photo.url',
          },
        });

        final fakeAccount = FakeGoogleSignInAccount(email: 'player@gmail.com');
        final fakeGoogle = FakeGoogleSignIn(account: fakeAccount);

        final container = ProviderContainer(
          overrides: [googleSignInProvider.overrideWithValue(fakeGoogle)],
        );
        container.listen(authControllerProvider, (previous, next) {});

        expect(container.read(isAuthenticatedProvider), false);
        expect(container.read(currentUserProvider), null);

        final controller = container.read(authControllerProvider.notifier);
        final future = controller.signInWithGoogle();

        // Verify loading state is active immediately
        expect(container.read(authControllerProvider).isLoading, true);

        final success = await future;
        expect(success, true);
        expect(
          container.read(authControllerProvider),
          const AsyncData<void>(null),
        );
        expect(container.read(isAuthenticatedProvider), true);

        final user = container.read(currentUserProvider);
        expect(user, isNotNull);
        expect(user!.id, '99');
        expect(user.username, 'google_player');
        expect(user.email, 'player@gmail.com');
        expect(user.avatarUrl, 'https://photo.url');

        // Verify credentials saved to SecureStorage
        expect(await secureStorage.getAccessToken(), 'valid_session_token');
        expect(await secureStorage.getUserId(), '99');
        expect(await secureStorage.isLoggedIn(), true);

        container.dispose();
      },
    );

    test('AuthController handles user cancellation gracefully', () async {
      // Setup FakeGoogleSignIn with a null account (cancellation)
      final fakeGoogle = FakeGoogleSignIn(account: null);

      final container = ProviderContainer(
        overrides: [googleSignInProvider.overrideWithValue(fakeGoogle)],
      );
      container.listen(authControllerProvider, (previous, next) {});

      final controller = container.read(authControllerProvider.notifier);
      final success = await controller.signInWithGoogle();

      expect(success, false);
      expect(
        container.read(authControllerProvider),
        const AsyncData<void>(null),
      );
      expect(container.read(isAuthenticatedProvider), false);

      container.dispose();
    });
  });
}
