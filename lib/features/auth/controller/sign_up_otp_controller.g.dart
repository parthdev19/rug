// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_otp_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignUpOtpController)
final signUpOtpControllerProvider = SignUpOtpControllerProvider._();

final class SignUpOtpControllerProvider
    extends $NotifierProvider<SignUpOtpController, SignUpOtpState> {
  SignUpOtpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpOtpControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpOtpControllerHash();

  @$internal
  @override
  SignUpOtpController create() => SignUpOtpController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUpOtpState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUpOtpState>(value),
    );
  }
}

String _$signUpOtpControllerHash() =>
    r'f9136863895e6fbec68cbf913c1f8a0589bd3557';

abstract class _$SignUpOtpController extends $Notifier<SignUpOtpState> {
  SignUpOtpState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SignUpOtpState, SignUpOtpState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SignUpOtpState, SignUpOtpState>,
              SignUpOtpState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
