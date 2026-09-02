// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stato di connettività (OF-6, OF-20, OF-21): ottimistico finché non
/// si osserva il contrario. Aggiornato da [ConnectivityInterceptor] a
/// ogni richiesta HTTP, riuscita o fallita per assenza di rete — non
/// un pacchetto dedicato di rilevamento della connettività (TS-9), che
/// nella v1 (sola consultazione offline) non aggiungerebbe nulla a
/// quanto le richieste stesse già rivelano.
///
/// `keepAlive`: aggiornato dagli intercettori HTTP (`ref.read`, non
/// `ref.watch`) indipendentemente da quale schermata sia in primo
/// piano. Senza, l'eliminazione automatica tra una richiesta e l'altra
/// — quando nessun widget osserva ancora lo stato, come subito dopo
/// l'avvio — ne perderebbe il valore appena impostato.

@ProviderFor(ConnectivityStatus)
final connectivityStatusProvider = ConnectivityStatusProvider._();

/// Stato di connettività (OF-6, OF-20, OF-21): ottimistico finché non
/// si osserva il contrario. Aggiornato da [ConnectivityInterceptor] a
/// ogni richiesta HTTP, riuscita o fallita per assenza di rete — non
/// un pacchetto dedicato di rilevamento della connettività (TS-9), che
/// nella v1 (sola consultazione offline) non aggiungerebbe nulla a
/// quanto le richieste stesse già rivelano.
///
/// `keepAlive`: aggiornato dagli intercettori HTTP (`ref.read`, non
/// `ref.watch`) indipendentemente da quale schermata sia in primo
/// piano. Senza, l'eliminazione automatica tra una richiesta e l'altra
/// — quando nessun widget osserva ancora lo stato, come subito dopo
/// l'avvio — ne perderebbe il valore appena impostato.
final class ConnectivityStatusProvider
    extends $NotifierProvider<ConnectivityStatus, bool> {
  /// Stato di connettività (OF-6, OF-20, OF-21): ottimistico finché non
  /// si osserva il contrario. Aggiornato da [ConnectivityInterceptor] a
  /// ogni richiesta HTTP, riuscita o fallita per assenza di rete — non
  /// un pacchetto dedicato di rilevamento della connettività (TS-9), che
  /// nella v1 (sola consultazione offline) non aggiungerebbe nulla a
  /// quanto le richieste stesse già rivelano.
  ///
  /// `keepAlive`: aggiornato dagli intercettori HTTP (`ref.read`, non
  /// `ref.watch`) indipendentemente da quale schermata sia in primo
  /// piano. Senza, l'eliminazione automatica tra una richiesta e l'altra
  /// — quando nessun widget osserva ancora lo stato, come subito dopo
  /// l'avvio — ne perderebbe il valore appena impostato.
  ConnectivityStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStatusHash();

  @$internal
  @override
  ConnectivityStatus create() => ConnectivityStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$connectivityStatusHash() =>
    r'5c8285f9212b43358f2bd7598c7c49b1fedf980a';

/// Stato di connettività (OF-6, OF-20, OF-21): ottimistico finché non
/// si osserva il contrario. Aggiornato da [ConnectivityInterceptor] a
/// ogni richiesta HTTP, riuscita o fallita per assenza di rete — non
/// un pacchetto dedicato di rilevamento della connettività (TS-9), che
/// nella v1 (sola consultazione offline) non aggiungerebbe nulla a
/// quanto le richieste stesse già rivelano.
///
/// `keepAlive`: aggiornato dagli intercettori HTTP (`ref.read`, non
/// `ref.watch`) indipendentemente da quale schermata sia in primo
/// piano. Senza, l'eliminazione automatica tra una richiesta e l'altra
/// — quando nessun widget osserva ancora lo stato, come subito dopo
/// l'avvio — ne perderebbe il valore appena impostato.

abstract class _$ConnectivityStatus extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
