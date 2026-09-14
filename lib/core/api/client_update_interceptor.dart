import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../update/client_update_controller.dart';

/// VR-17: riconosce `CLIENT_UPDATE_REQUIRED` su qualsiasi chiamata, pubblica
/// o autenticata, e porta il client nello stato bloccante. L'errore prosegue
/// comunque lungo la coda, perché chi ha avviato la richiesta non resti in
/// attesa.
///
/// Legge la risposta **grezza**, come [TokenRefreshInterceptor]: DEVE perciò
/// precedere `ApiErrorInterceptor`, che la traduce e completa con `reject`
/// (vedi il commento su `apiClient` in `api_client.dart`).
class ClientUpdateInterceptor extends Interceptor {
  ClientUpdateInterceptor(this._ref);

  static const code = 'CLIENT_UPDATE_REQUIRED';

  final Ref _ref;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (err.response?.statusCode == 426 && data is Map && data['code'] == code) {
      _ref.read(clientUpdateControllerProvider.notifier).markRequired().ignore();
    }
    handler.next(err);
  }
}
