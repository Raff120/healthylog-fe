import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';
import '../auth/session_controller.dart';
import 'api_error_interceptor.dart';
import 'token_refresh_interceptor.dart';

part 'api_client.g.dart';

Dio _buildDio() {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    ),
  );
}

/// Client HTTP privo dell'intestazione di autorizzazione (4.2, 4.3
/// specifica-tecnica.md): per gli endpoint pubblici della feature
/// identity (registrazione, accesso, rinnovo...). Distinto da
/// [apiClient] per non introdurre una dipendenza circolare — il
/// ripristino della sessione (TK-8) chiama `/auth/refresh` prima ancora
/// che un token di accesso esista.
@riverpod
Dio publicApiClient(Ref ref) {
  final dio = _buildDio();
  dio.interceptors.add(ApiErrorInterceptor());
  return dio;
}

/// Client HTTP che allega il token di accesso corrente quando presente
/// (TK-6) e rinnova trasparentemente alla scadenza (TK-13, TK-14). Per
/// gli endpoint che richiedono autenticazione.
///
/// L'ordine degli intercettori è significativo: sia le richieste sia gli
/// errori attraversano la coda nell'ordine di aggiunta (dio incatena gli
/// `onError` con `Future.catchError` in quello stesso ordine).
/// [TokenRefreshInterceptor] DEVE quindi precedere [ApiErrorInterceptor]
/// per intercettare la risposta grezza prima che questo la traduca e la
/// completi con `reject` — che, per impostazione predefinita, salta il
/// resto della coda (vedi il commento su [TokenRefreshInterceptor]).
@riverpod
Dio apiClient(Ref ref) {
  final dio = _buildDio();
  dio.interceptors.addAll([
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final accessToken = ref.read(sessionControllerProvider).value?.accessToken;
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ),
    TokenRefreshInterceptor(ref, dio),
    ApiErrorInterceptor(),
  ]);
  return dio;
}
