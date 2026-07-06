// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dio HTTP client provider.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// Dio HTTP client provider.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Dio HTTP client provider.
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'fb5e1293a1d2f2aca782a019e4e71351db0ad1ab';

/// Network connectivity info provider.

@ProviderFor(networkInfo)
final networkInfoProvider = NetworkInfoProvider._();

/// Network connectivity info provider.

final class NetworkInfoProvider
    extends $FunctionalProvider<NetworkInfo, NetworkInfo, NetworkInfo>
    with $Provider<NetworkInfo> {
  /// Network connectivity info provider.
  NetworkInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkInfoHash();

  @$internal
  @override
  $ProviderElement<NetworkInfo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetworkInfo create(Ref ref) {
    return networkInfo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkInfo>(value),
    );
  }
}

String _$networkInfoHash() => r'626ac694310f6b7f46dc907a6e3b32214653b5bd';

/// Local storage (Hive) provider.

@ProviderFor(localStorage)
final localStorageProvider = LocalStorageProvider._();

/// Local storage (Hive) provider.

final class LocalStorageProvider
    extends
        $FunctionalProvider<
          LocalStorageService,
          LocalStorageService,
          LocalStorageService
        >
    with $Provider<LocalStorageService> {
  /// Local storage (Hive) provider.
  LocalStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localStorageHash();

  @$internal
  @override
  $ProviderElement<LocalStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalStorageService create(Ref ref) {
    return localStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalStorageService>(value),
    );
  }
}

String _$localStorageHash() => r'4bdbb128dbd6743f9ef6e8d4ccd3d4eb03c9497f';

/// Secure storage (tokens) provider.

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

/// Secure storage (tokens) provider.

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          SecureStorageService,
          SecureStorageService,
          SecureStorageService
        >
    with $Provider<SecureStorageService> {
  /// Secure storage (tokens) provider.
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<SecureStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureStorageService create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureStorageService>(value),
    );
  }
}

String _$secureStorageHash() => r'88f30a52f7fe7f4c3766b5d557bd7109a777a77f';

/// Whether the user is currently authenticated.

@ProviderFor(IsAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Whether the user is currently authenticated.
final class IsAuthenticatedProvider
    extends $NotifierProvider<IsAuthenticated, bool> {
  /// Whether the user is currently authenticated.
  IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  IsAuthenticated create() => IsAuthenticated();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'815af235eafa8efa5a6fd3970f780a687696744d';

/// Whether the user is currently authenticated.

abstract class _$IsAuthenticated extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Current user ID (null when not logged in).

@ProviderFor(CurrentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

/// Current user ID (null when not logged in).
final class CurrentUserIdProvider
    extends $NotifierProvider<CurrentUserId, String?> {
  /// Current user ID (null when not logged in).
  CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  CurrentUserId create() => CurrentUserId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUserIdHash() => r'e3df4467335c4cf98201e89fad70855c46e1b972';

/// Current user ID (null when not logged in).

abstract class _$CurrentUserId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Current logged in user model (null when not logged in).

@ProviderFor(CurrentUser)
final currentUserProvider = CurrentUserProvider._();

/// Current logged in user model (null when not logged in).
final class CurrentUserProvider
    extends $NotifierProvider<CurrentUser, UserModel?> {
  /// Current logged in user model (null when not logged in).
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  CurrentUser create() => CurrentUser();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserModel?>(value),
    );
  }
}

String _$currentUserHash() => r'a5823c796e2ee4e483a4bb780a73b9d37421318d';

/// Current logged in user model (null when not logged in).

abstract class _$CurrentUser extends $Notifier<UserModel?> {
  UserModel? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UserModel?, UserModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserModel?, UserModel?>,
              UserModel?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Helper provider to check if the current user is a guest.

@ProviderFor(isGuest)
final isGuestProvider = IsGuestProvider._();

/// Helper provider to check if the current user is a guest.

final class IsGuestProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Helper provider to check if the current user is a guest.
  IsGuestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isGuestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isGuestHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isGuest(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isGuestHash() => r'b4c1049c1f0ac015ad9d4be317a29d352671bcf4';

/// Network connectivity status.

@ProviderFor(isOnline)
final isOnlineProvider = IsOnlineProvider._();

/// Network connectivity status.

final class IsOnlineProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Network connectivity status.
  IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isOnline(ref);
  }
}

String _$isOnlineHash() => r'01782feeb925b1e41ae37e836fd2b397452c4468';
