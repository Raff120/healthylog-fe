import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';
import '../auth/session_controller.dart';
import 'api_error_interceptor.dart';

part 'api_client.g.dart';

Dio _buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.add(ApiErrorInterceptor());
  return dio;
}

/// Client HTTP privo dell'intestazione di autorizzazione (4.2, 4.3
/// specifica-tecnica.md): per gli endpoint pubblici della feature
/// identity (registrazione, accesso, rinnovo...). Distinto da
/// [apiClient] per non introdurre una dipendenza circolare — il
/// ripristino della sessione (TK-8) chiama `/auth/refresh` prima ancora
/// che un token di accesso esista.
@riverpod
Dio publicApiClient(Ref ref) => _buildDio();

/// Client HTTP che allega il token di accesso corrente quando presente
/// (TK-6), per gli endpoint che lo richiedono. Il rinnovo trasparente
/// alla scadenza (TK-13, TK-14) è compito di un task successivo di F06.
@riverpod
Dio apiClient(Ref ref) {
  final dio = _buildDio();
  dio.interceptors.insert(
    0,
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final accessToken = ref.read(sessionControllerProvider).value?.accessToken;
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ),
  );
  return dio;
}
