// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_verification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reinvio del collegamento di verifica (AU-15). Il conto alla rovescia
/// prima della riattivazione (AU-22, 5.3 interfaccia.md) è gestito dalla
/// schermata; qui c'è solo la chiamata e il suo esito.

@ProviderFor(EmailVerificationController)
final emailVerificationControllerProvider =
    EmailVerificationControllerProvider._();

/// Reinvio del collegamento di verifica (AU-15). Il conto alla rovescia
/// prima della riattivazione (AU-22, 5.3 interfaccia.md) è gestito dalla
/// schermata; qui c'è solo la chiamata e il suo esito.
final class EmailVerificationControllerProvider
    extends $NotifierProvider<EmailVerificationController, AsyncValue<void>?> {
  /// Reinvio del collegamento di verifica (AU-15). Il conto alla rovescia
  /// prima della riattivazione (AU-22, 5.3 interfaccia.md) è gestito dalla
  /// schermata; qui c'è solo la chiamata e il suo esito.
  EmailVerificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emailVerificationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emailVerificationControllerHash();

  @$internal
  @override
  EmailVerificationController create() => EmailVerificationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$emailVerificationControllerHash() =>
    r'672759139d432715078e0013f96e4242e7de1cb1';

/// Reinvio del collegamento di verifica (AU-15). Il conto alla rovescia
/// prima della riattivazione (AU-22, 5.3 interfaccia.md) è gestito dalla
/// schermata; qui c'è solo la chiamata e il suo esito.

abstract class _$EmailVerificationController
    extends $Notifier<AsyncValue<void>?> {
  AsyncValue<void>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>?, AsyncValue<void>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>?, AsyncValue<void>?>,
              AsyncValue<void>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
