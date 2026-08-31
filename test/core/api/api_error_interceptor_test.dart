import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/api/api_exception.dart';

/// Adapter fittizio che restituisce sempre la risposta preparata dal test,
/// così da esercitare l'interceptor attraverso la catena reale di dio
/// invece di richiamarne direttamente il metodo protetto.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.data);

  final int statusCode;
  final Object? data;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = data == null ? '' : '{"code":"$data"}';
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  group('ApiErrorInterceptor', () {
    Dio buildDio(int statusCode, String? code) {
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = _StubAdapter(statusCode, code);
      dio.interceptors.add(ApiErrorInterceptor());
      return dio;
    }

    test('traduce un corpo {code} nel codice corrispondente (ER-1)', () async {
      final dio = buildDio(409, 'SLOT_ALREADY_CONSUMED');

      await expectLater(
        dio.get<void>('/diet-plans/1/swaps'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 409)
                .having((e) => e.code, 'code', 'SLOT_ALREADY_CONSUMED'),
          ),
        ),
      );
    });

    test('un corpo privo di codice diventa NETWORK_ERROR', () async {
      final dio = buildDio(500, null);

      await expectLater(
        dio.get<void>('/diet-plans'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 500)
                .having((e) => e.code, 'code', 'NETWORK_ERROR'),
          ),
        ),
      );
    });
  });
}
