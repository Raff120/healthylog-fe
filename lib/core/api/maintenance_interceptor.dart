import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../maintenance/maintenance_controller.dart';

/// MM-7: riconosce `MAINTENANCE` su qualsiasi chiamata, pubblica o
/// autenticata, e porta il client nello stato bloccante. L'errore prosegue
/// comunque lungo la coda, perché chi ha avviato la richiesta non resti in
/// attesa.
///
/// Il codice giunge da nginx e non dal backend, che durante la manutenzione è
/// fermo (MM-3): è il proxy a rispondere `503` a tutto `/api/`.
///
/// Legge la risposta **grezza**, come [ClientUpdateInterceptor]: DEVE perciò
/// precedere `ApiErrorInterceptor`, che la traduce e completa con `reject`
/// (vedi il commento su `apiClient` in `api_client.dart`).
class MaintenanceInterceptor extends Interceptor {
  MaintenanceInterceptor(this._ref);

  static const code = 'MAINTENANCE';

  final Ref _ref;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (err.response?.statusCode == 503 && data is Map && data['code'] == code) {
      _ref.read(maintenanceControllerProvider.notifier).markActive();
    }
    handler.next(err);
  }
}
