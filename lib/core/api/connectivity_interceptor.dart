import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connectivity_status.dart';

/// Aggiorna [ConnectivityStatus] (OF-6) a ogni richiesta: online a ogni
/// risposta ricevuta, offline quando l'errore non reca alcun corpo
/// strutturato dal server — la stessa condizione con cui
/// [ApiErrorInterceptor] classifica `NETWORK_ERROR`, qui applicata
/// prima che quello la traduca. DEVE perciò precedere
/// `ApiErrorInterceptor` nella coda degli intercettori (`reject` salta
/// il resto della coda per gli errori, vedi il commento su
/// [TokenRefreshInterceptor] in `api_client.dart`).
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._ref);

  final Ref _ref;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _ref.read(connectivityStatusProvider.notifier).markOnline();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    final hasStructuredError = data is Map && data['code'] is String;
    if (hasStructuredError) {
      _ref.read(connectivityStatusProvider.notifier).markOnline();
    } else {
      _ref.read(connectivityStatusProvider.notifier).markOffline();
    }
    handler.next(err);
  }
}
