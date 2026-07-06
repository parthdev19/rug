// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GuestController)
final guestControllerProvider = GuestControllerProvider._();

final class GuestControllerProvider
    extends $NotifierProvider<GuestController, AsyncValue<void>> {
  GuestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guestControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guestControllerHash();

  @$internal
  @override
  GuestController create() => GuestController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$guestControllerHash() => r'dcbf02b071427d74bd3084e49d41bd26d7b1863c';

abstract class _$GuestController extends $Notifier<AsyncValue<void>> {
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
