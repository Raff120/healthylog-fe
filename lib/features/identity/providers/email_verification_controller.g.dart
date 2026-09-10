// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_verification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Conferma dell'indirizzo per codice (AU-11) e reinvio del codice
/// (AU-15). Il conto alla rovescia prima della riattivazione del reinvio
/// (AU-22, 5.3 interfaccia.md) è gestito dalla schermata; qui ci sono
/// solo le chiamate e il loro esito.
///
/// Un solo controllore per le due azioni, che appartengono alla medesima
/// schermata e non possono essere in corso insieme: il suo stato è la
/// sua attesa, e distinguerne due obbligherebbe la schermata a comporli.

@ProviderFor(EmailVerificationController)
final emailVerificationControllerProvider =
    EmailVerificationControllerProvider._();

/// Conferma dell'indirizzo per codice (AU-11) e reinvio del codice
/// (AU-15). Il conto alla rovescia prima della riattivazione del reinvio
/// (AU-22, 5.3 interfaccia.md) è gestito dalla schermata; qui ci sono
/// solo le chiamate e il loro esito.
///
/// Un solo controllore per le due azioni, che appartengono alla medesima
/// schermata e non possono essere in corso insieme: il suo stato è la
/// sua attesa, e distinguerne due obbligherebbe la schermata a comporli.
final class EmailVerificationControllerProvider
    extends $NotifierProvider<EmailVerificationController, AsyncValue<void>?> {
  /// Conferma dell'indirizzo per codice (AU-11) e reinvio del codice
  /// (AU-15). Il conto alla rovescia prima della riattivazione del reinvio
  /// (AU-22, 5.3 interfaccia.md) è gestito dalla schermata; qui ci sono
  /// solo le chiamate e il loro esito.
  ///
  /// Un solo controllore per le due azioni, che appartengono alla medesima
  /// schermata e non possono essere in corso insieme: il suo stato è la
  /// sua attesa, e distinguerne due obbligherebbe la schermata a comporli.
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
    r'f6c11344575d51d6479c8d8d31a200208821a343';

/// Conferma dell'indirizzo per codice (AU-11) e reinvio del codice
/// (AU-15). Il conto alla rovescia prima della riattivazione del reinvio
/// (AU-22, 5.3 interfaccia.md) è gestito dalla schermata; qui ci sono
/// solo le chiamate e il loro esito.
///
/// Un solo controllore per le due azioni, che appartengono alla medesima
/// schermata e non possono essere in corso insieme: il suo stato è la
/// sua attesa, e distinguerne due obbligherebbe la schermata a comporli.

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
