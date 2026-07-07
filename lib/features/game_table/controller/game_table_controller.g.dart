// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_table_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GameTableController)
final gameTableControllerProvider = GameTableControllerProvider._();

final class GameTableControllerProvider
    extends $NotifierProvider<GameTableController, GameTableState> {
  GameTableControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameTableControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameTableControllerHash();

  @$internal
  @override
  GameTableController create() => GameTableController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameTableState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameTableState>(value),
    );
  }
}

String _$gameTableControllerHash() =>
    r'f78e05002e9a48f006b89c122fee69bdcf3cbe84';

abstract class _$GameTableController extends $Notifier<GameTableState> {
  GameTableState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GameTableState, GameTableState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GameTableState, GameTableState>,
              GameTableState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
