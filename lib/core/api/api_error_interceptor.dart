import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Traduce le risposte di errore del backend (4.3 specifica-tecnica.md) in
/// [ApiException], così che il resto del client ragioni sul solo codice
/// (ER-3) e non sui dettagli di trasporto HTTP.
class ApiErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final data = response?.data;
    final code = (data is Map && data['code'] is String)
        ? data['code'] as String
        : 'NETWORK_ERROR';

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiException(
          statusCode: response?.statusCode ?? -1,
          code: code,
        ),
      ),
    );
  }
}
