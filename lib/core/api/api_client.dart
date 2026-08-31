import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';
import 'api_error_interceptor.dart';

part 'api_client.g.dart';

/// Client HTTP di base (4.2, 4.3 specifica-tecnica.md): JSON con codifica
/// UTF-8, percorsi privi di prefisso (AP-3), errori tradotti in
/// [ApiException]. Non allega ancora alcuna intestazione di autorizzazione:
/// la sessione è predisposta in F06.
@riverpod
Dio apiClient(Ref ref) {
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
