import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/api/connectivity_interceptor.dart';
import 'package:healthylog/core/api/connectivity_status.dart';

class _NetworkErrorAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException.connectionError(requestOptions: options, reason: 'no network');
  }
}

class _JsonAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _ServerErrorAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"code":"VALIDATION_FAILED"}',
      400,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// Stato di connettività dell'applicazione (OF-6, OF-20, OF-21, F14):
/// aggiornato in base all'esito reale delle richieste HTTP, non a un
/// rilevamento dedicato (TS-9).
void main() {
  test('online di base, offline dopo un errore di rete, online dopo una risposta', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final wired = Provider<Dio>((ref) {
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.interceptors.addAll([ConnectivityInterceptor(ref), ApiErrorInterceptor()]);
      return dio;
    });
    final dio = container.read(wired);
    expect(container.read(connectivityStatusProvider), isTrue);

    dio.httpClientAdapter = _NetworkErrorAdapter();
    await expectLater(dio.get('/x'), throwsA(anything));
    expect(container.read(connectivityStatusProvider), isFalse);

    dio.httpClientAdapter = _JsonAdapter();
    await dio.get('/x');
    expect(container.read(connectivityStatusProvider), isTrue);
  });

  test('un errore applicativo con risposta reale del server conta come online', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final wired = Provider<Dio>((ref) {
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.interceptors.addAll([ConnectivityInterceptor(ref), ApiErrorInterceptor()]);
      return dio;
    });
    final dio = container.read(wired);

    // Offline prima, per verificare che una risposta applicativa lo
    // corregga davvero (non solo che resti true di default).
    container.read(connectivityStatusProvider.notifier).markOffline();
    dio.httpClientAdapter = _ServerErrorAdapter();
    await expectLater(dio.get('/x'), throwsA(anything));

    expect(container.read(connectivityStatusProvider), isTrue);
  });
}
