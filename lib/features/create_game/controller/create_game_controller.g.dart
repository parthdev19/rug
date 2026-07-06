// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_game_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateGameController)
final createGameControllerProvider = CreateGameControllerProvider._();

final class CreateGameControllerProvider
    extends $NotifierProvider<CreateGameController, CreateGameState> {
  CreateGameControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createGameControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createGameControllerHash();

  @$internal
  @override
  CreateGameController create() => CreateGameController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateGameState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateGameState>(value),
    );
  }
}

String _$createGameControllerHash() =>
    r'610d4b025da2d4c2ae1a60afafa12102c1882e4e';

abstract class _$CreateGameController extends $Notifier<CreateGameState> {
  CreateGameState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreateGameState, CreateGameState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateGameState, CreateGameState>,
              CreateGameState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
