// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_username_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SetUsernameController)
final setUsernameControllerProvider = SetUsernameControllerProvider._();

final class SetUsernameControllerProvider
    extends $NotifierProvider<SetUsernameController, AsyncValue<void>> {
  SetUsernameControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setUsernameControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setUsernameControllerHash();

  @$internal
  @override
  SetUsernameController create() => SetUsernameController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$setUsernameControllerHash() =>
    r'16b2c08eff048d9de6286d9b303703973725028a';

abstract class _$SetUsernameController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
