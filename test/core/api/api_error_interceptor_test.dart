import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/api/api_exception.dart';

/// Adapter fittizio che restituisce sempre la risposta preparata dal test,
/// così da esercitare l'interceptor attraverso la catena reale di dio
/// invece di richiamarne direttamente il metodo protetto.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, String? code) : _rawBody = code == null ? '' : '{"code":"$code"}';

  _StubAdapter.withBody(this.statusCode, Map<String, dynamic> body) : _rawBody = jsonEncode(body);

  final int statusCode;
  final String _rawBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      _rawBody,
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

    test('conserva il corpo grezzo oltre al solo codice (ER-1)', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = _StubAdapter.withBody(409, {
        'code': 'PLAN_PERIOD_OVERLAP',
        'conflictingPlanId': 'plan-1',
        'conflictingPlanName': 'Piano estate',
      });
      dio.interceptors.add(ApiErrorInterceptor());

      await expectLater(
        dio.post<void>('/diet-plans'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ApiException>().having(
              (e) => (e.body as Map)['conflictingPlanName'],
              'body.conflictingPlanName',
              'Piano estate',
            ),
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
