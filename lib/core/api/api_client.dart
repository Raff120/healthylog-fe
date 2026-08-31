import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';
import '../auth/session_controller.dart';
import 'api_error_interceptor.dart';

part 'api_client.g.dart';

/// Client HTTP di base (4.2, 4.3 specifica-tecnica.md): JSON con codifica
/// UTF-8, percorsi privi di prefisso (AP-3), errori tradotti in
/// [ApiException]. Allega il token di accesso corrente quando presente
/// (TK-6); il rinnovo trasparente alla scadenza (TK-13, TK-14) è compito
/// di un task successivo di F06.
@riverpod
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final accessToken = ref.read(sessionControllerProvider)?.accessToken;
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ),
  );
  dio.interceptors.add(ApiErrorInterceptor());
  return dio;
}
