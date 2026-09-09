// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_verify_link_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Apertura del collegamento di verifica (AU-11, AU-14): esito immediato,
/// senza alcuna azione dell'Utente (5.3 interfaccia.md).

@ProviderFor(EmailVerifyLinkController)
final emailVerifyLinkControllerProvider = EmailVerifyLinkControllerProvider._();

/// Apertura del collegamento di verifica (AU-11, AU-14): esito immediato,
/// senza alcuna azione dell'Utente (5.3 interfaccia.md).
final class EmailVerifyLinkControllerProvider
    extends $NotifierProvider<EmailVerifyLinkController, AsyncValue<void>?> {
  /// Apertura del collegamento di verifica (AU-11, AU-14): esito immediato,
  /// senza alcuna azione dell'Utente (5.3 interfaccia.md).
  EmailVerifyLinkControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emailVerifyLinkControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emailVerifyLinkControllerHash();

  @$internal
  @override
  EmailVerifyLinkController create() => EmailVerifyLinkController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$emailVerifyLinkControllerHash() =>
    r'9e98990372c0bc221474af32cc25af0e26c5f44a';

/// Apertura del collegamento di verifica (AU-11, AU-14): esito immediato,
/// senza alcuna azione dell'Utente (5.3 interfaccia.md).

abstract class _$EmailVerifyLinkController
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
