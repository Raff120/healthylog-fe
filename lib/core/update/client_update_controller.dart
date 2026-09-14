import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/client_build.dart';
import '../storage/preferences_store.dart';

part 'client_update_controller.g.dart';

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
@Riverpod(keepAlive: true)
class ClientUpdateController extends _$ClientUpdateController {
  static const storageKey = 'client_update_required_for_build';

  @override
  Future<bool> build() async {
    try {
      final stored = int.tryParse(await ref.read(preferencesStoreProvider).read(storageKey) ?? '');
      if (stored == null) return false;
      final current = ref.read(clientBuildProvider);
      return current != null && current <= stored;
    } catch (_) {
      // Preferenze non leggibili (piattaforma priva del canale): nessuno
      // sbarramento ricordato. Il server lo ripresenterà alla prima richiesta.
      return false;
    }
  }

  /// VR-17: invocato alla ricezione di `CLIENT_UPDATE_REQUIRED`. Lo
  /// sbarramento vale subito; il build respinto è ricordato se leggibile.
  Future<void> markRequired() async {
    // Attende la lettura iniziale: se ancora in corso, il suo esito
    // sovrascriverebbe lo sbarramento appena disposto.
    try {
      await future;
    } catch (_) {
      // Lettura iniziale non riuscita: lo sbarramento vale comunque.
    }
    state = const AsyncValue.data(true);
    try {
      final current = ref.read(clientBuildProvider);
      if (current != null) {
        await ref.read(preferencesStoreProvider).write(storageKey, '$current');
      }
    } catch (_) {
      // Lo sbarramento resta per la sessione in corso anche se non è
      // ricordato: alla riapertura il server lo ripresenterà.
    }
  }
}
