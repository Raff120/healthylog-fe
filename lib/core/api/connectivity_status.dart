import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_status.g.dart';

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
@Riverpod(keepAlive: true)
class ConnectivityStatus extends _$ConnectivityStatus {
  @override
  bool build() => true;

  void markOnline() {
    if (!state) state = true;
  }

  void markOffline() {
    if (state) state = false;
  }
}
