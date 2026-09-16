import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maintenance_controller.g.dart';

/// Manutenzione del servizio (MN-1, MM-7): `true` quando il servizio l'ha
/// dichiarata rispondendo `MAINTENANCE` a una chiamata qualsiasi.
///
/// Diversamente da [ClientUpdateController] lo stato **non** è ricordato sul
/// dispositivo (MM-7, MN-6): un aggiornamento obbligatorio si aggirerebbe
/// staccando la rete, e va perciò ricordato; una manutenzione cessa invece da
/// sé, e lo sbarramento vale finché è il servizio a dichiararla. Riaprendo
/// l'applicazione senza che il servizio la dichiari, non si ripresenta.
///
/// Per la stessa ragione non c'è nulla da leggere all'avvio: lo stato è un
/// booleano sincrono, non un `Future`.
///
/// `keepAlive`: aggiornato dall'intercettore HTTP con `ref.read`, come
/// [ConnectivityStatus], indipendentemente da quale schermata sia in primo
/// piano; e letto dal router.
@Riverpod(keepAlive: true)
class MaintenanceController extends _$MaintenanceController {
  @override
  bool build() => false;

  /// MM-7: invocato alla ricezione di `MAINTENANCE`. Lo sbarramento vale
  /// subito, e lo presenta il router.
  void markActive() {
    if (!state) state = true;
  }
}
