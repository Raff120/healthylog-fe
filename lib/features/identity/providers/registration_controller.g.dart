// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Invio del modulo di registrazione (AC-1, AC-2). L'esito favorevole
/// conduce alla verifica dell'indirizzo (5.3 interfaccia.md), senza
/// accesso automatico: la registrazione non restituisce token.

@ProviderFor(RegistrationController)
final registrationControllerProvider = RegistrationControllerProvider._();

/// Invio del modulo di registrazione (AC-1, AC-2). L'esito favorevole
/// conduce alla verifica dell'indirizzo (5.3 interfaccia.md), senza
/// accesso automatico: la registrazione non restituisce token.
final class RegistrationControllerProvider
    extends
        $NotifierProvider<RegistrationController, AsyncValue<RegisterResult>?> {
  /// Invio del modulo di registrazione (AC-1, AC-2). L'esito favorevole
  /// conduce alla verifica dell'indirizzo (5.3 interfaccia.md), senza
  /// accesso automatico: la registrazione non restituisce token.
  RegistrationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registrationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registrationControllerHash();

  @$internal
  @override
  RegistrationController create() => RegistrationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RegisterResult>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RegisterResult>?>(value),
    );
  }
}

String _$registrationControllerHash() =>
    r'2171ad61746c633414a72d13ac149ae90c44ee10';

/// Invio del modulo di registrazione (AC-1, AC-2). L'esito favorevole
/// conduce alla verifica dell'indirizzo (5.3 interfaccia.md), senza
/// accesso automatico: la registrazione non restituisce token.

abstract class _$RegistrationController
    extends $Notifier<AsyncValue<RegisterResult>?> {
  AsyncValue<RegisterResult>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<RegisterResult>?, AsyncValue<RegisterResult>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RegisterResult>?,
                AsyncValue<RegisterResult>?
              >,
              AsyncValue<RegisterResult>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
