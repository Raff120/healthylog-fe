import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/maintenance_interceptor.dart';
import '../auth/session_controller.dart';
import 'service_status_client.dart';

part 'maintenance_controller.g.dart';

/// MM-9, 10 tecnica: ogni quanto si verifica da sé se la manutenzione sia
/// terminata.
const _verificationInterval = Duration(seconds: 30);

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
  Timer? _timer;
  bool _verifying = false;

  @override
  bool build() {
    ref.onDispose(_stopVerifying);
    return false;
  }

  /// MM-7: invocato alla ricezione di `MAINTENANCE`. Lo sbarramento vale
  /// subito, e lo presenta il router.
  void markActive() {
    if (state) return;
    state = true;
    // MM-9: da qui la fine della manutenzione va riconosciuta da sé, senza
    // che l'Utente faccia nulla (MN-5). La verifica sta qui e non nella
    // schermata: l'intervallo non dipende da quale schermata sia in primo
    // piano, e il pulsante «Riprova» chiede la medesima verifica.
    _timer ??= Timer.periodic(_verificationInterval, (_) => check());
  }

  /// MM-9: interroga l'endpoint di stato attraverso il proxy e lascia lo
  /// sbarramento alla prima risposta che non sia più una manutenzione.
  ///
  /// Un errore di trasporto — nessuna risposta affatto — non è una fine:
  /// vale la regola ordinaria dell'assenza di connessione (MN-6), e lo
  /// sbarramento resta finché il servizio non dice altro.
  Future<void> check() async {
    if (!state || _verifying) return;
    _verifying = true;
    try {
      await ref.read(serviceStatusClientProvider).get<dynamic>('/status');
      _resume();
    } on DioException catch (error) {
      final data = error.response?.data;
      final stillInMaintenance = error.response?.statusCode == 503 &&
          data is Map &&
          data['code'] == MaintenanceInterceptor.code;
      if (error.response != null && !stillInMaintenance) _resume();
    } finally {
      _verifying = false;
    }
  }

  void _resume() {
    _stopVerifying();
    state = false;
    // MN-4: se la manutenzione è comparsa all'avvio, il ripristino della
    // sessione (TK-8) si è concluso in errore e nessuno lo ritenterebbe: chi
    // torna si ritroverebbe alla schermata di accesso, con i token ancora
    // sul dispositivo. Invalidarlo lo fa ricominciare. Una sessione integra
    // non si tocca: la rileggerebbe senza ragione.
    if (ref.read(sessionControllerProvider).hasError) {
      ref.invalidate(sessionControllerProvider);
    }
  }

  void _stopVerifying() {
    _timer?.cancel();
    _timer = null;
  }
}
