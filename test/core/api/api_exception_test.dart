import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/api/api_exception.dart';

/// dio non lancia mai [ApiException] direttamente (vedi il commento su
/// [ApiExceptionExtraction]): un controllo diretto `error is
/// ApiException` sull'oggetto catturato da `AsyncValue.guard` è sempre
/// falso. Le schermate DEVONO passare da `error.asApiException`.
void main() {
  group('ApiExceptionExtraction', () {
    test('estrae ApiException da un DioException (caso reale)', () {
      const inner = ApiException(statusCode: 401, code: 'INVALID_CREDENTIALS');
      final wrapped = DioException(requestOptions: RequestOptions(path: '/auth/login'), error: inner);

      expect(wrapped.asApiException, same(inner));
    });

    test('restituisce null per un errore che non porta alcuna ApiException', () {
      final wrapped = DioException(requestOptions: RequestOptions(path: '/auth/login'));

      expect(wrapped.asApiException, isNull);
    });

    test('restituisce null per un errore estraneo a dio', () {
      expect(Exception('boom').asApiException, isNull);
    });
  });
}
