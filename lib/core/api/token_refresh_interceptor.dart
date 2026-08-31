import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/session_controller.dart';

/// Rinnovo trasparente (TK-13): intercetta `TOKEN_EXPIRED`, rinnova e
/// ripete la richiesta originale. Le richieste concorrenti che
/// incontrano la scadenza attendono lo stesso rinnovo (TK-14): la
/// deduplicazione è responsabilità di [SessionController.refreshSession],
/// non di questo intercettore, che può essere istanziato più volte.
///
/// Legge il codice dalla risposta **grezza**, non da [ApiException]:
/// `ApiErrorInterceptor` completa con `handler.reject`, che per
/// impostazione predefinita salta il resto della coda di intercettori
/// (vedi `ErrorInterceptorHandler.reject` in dio). Questo intercettore
/// DEVE perciò essere aggiunto **dopo** `ApiErrorInterceptor`, così che
/// il suo `onError` sia eseguito prima nell'ordine inverso della coda.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor(this._ref, this._dio);

  final Ref _ref;
  final Dio _dio;

  static const _retriedFlag = 'tokenRefreshRetried';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final data = err.response?.data;
    final code = data is Map && data['code'] is String ? data['code'] as String : null;
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;

    if (err.response?.statusCode != 401 || code != 'TOKEN_EXPIRED' || alreadyRetried) {
      handler.next(err);
      return;
    }

    final session = await _ref.read(sessionControllerProvider.notifier).refreshSession();
    if (session == null) {
      handler.next(err);
      return;
    }

    try {
      final options = err.requestOptions;
      options.extra[_retriedFlag] = true;
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      handler.resolve(await _dio.fetch(options));
    } catch (_) {
      handler.next(err);
    }
  }
}
