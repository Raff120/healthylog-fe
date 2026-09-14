// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Aggiornamento obbligatorio (MP-15, VR-17): `true` quando il server ha
/// dichiarato superata la versione installata.
///
/// Lo stato è ricordato sul dispositivo insieme al build respinto, così che
/// lo sbarramento si ripresenti alla riapertura anche senza connessione —
/// un aggiornamento obbligatorio che si aggira staccando la rete non lo è.
/// Installata la versione nuova, il build supera quello respinto e lo
/// sbarramento cade da sé, senza attendere il server.
///
/// `keepAlive`: letto con `ref.read` dall'intercettore HTTP e dal router.

@ProviderFor(ClientUpdateController)
final clientUpdateControllerProvider = ClientUpdateControllerProvider._();

/// Aggiornamento obbligatorio (MP-15, VR-17): `true` quando il server ha
/// dichiarato superata la versione installata.
///
/// Lo stato è ricordato sul dispositivo insieme al build respinto, così che
/// lo sbarramento si ripresenti alla riapertura anche senza connessione —
/// un aggiornamento obbligatorio che si aggira staccando la rete non lo è.
/// Installata la versione nuova, il build supera quello respinto e lo
/// sbarramento cade da sé, senza attendere il server.
///
/// `keepAlive`: letto con `ref.read` dall'intercettore HTTP e dal router.
final class ClientUpdateControllerProvider
    extends $AsyncNotifierProvider<ClientUpdateController, bool> {
  /// Aggiornamento obbligatorio (MP-15, VR-17): `true` quando il server ha
  /// dichiarato superata la versione installata.
  ///
  /// Lo stato è ricordato sul dispositivo insieme al build respinto, così che
  /// lo sbarramento si ripresenti alla riapertura anche senza connessione —
  /// un aggiornamento obbligatorio che si aggira staccando la rete non lo è.
  /// Installata la versione nuova, il build supera quello respinto e lo
  /// sbarramento cade da sé, senza attendere il server.
  ///
  /// `keepAlive`: letto con `ref.read` dall'intercettore HTTP e dal router.
  ClientUpdateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientUpdateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientUpdateControllerHash();

  @$internal
  @override
  ClientUpdateController create() => ClientUpdateController();
}

String _$clientUpdateControllerHash() =>
    r'18bf2d7598acdf8e755b98d1b630d31a290ff2e1';

/// Aggiornamento obbligatorio (MP-15, VR-17): `true` quando il server ha
/// dichiarato superata la versione installata.
///
/// Lo stato è ricordato sul dispositivo insieme al build respinto, così che
/// lo sbarramento si ripresenti alla riapertura anche senza connessione —
/// un aggiornamento obbligatorio che si aggira staccando la rete non lo è.
/// Installata la versione nuova, il build supera quello respinto e lo
/// sbarramento cade da sé, senza attendere il server.
///
/// `keepAlive`: letto con `ref.read` dall'intercettore HTTP e dal router.

abstract class _$ClientUpdateController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
