import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/api/api_client.dart';
import 'package:healthylog/core/api/client_build.dart';
import 'package:healthylog/core/api/client_headers_interceptor.dart';

/// Adapter che registra le intestazioni della richiesta ricevuta.
class _RecordingAdapter implements HttpClientAdapter {
  Map<String, dynamic>? headers;
  Uri? uri;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    headers = options.headers;
    uri = options.uri;
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

/// VR-13: ogni richiesta dichiara piattaforma e build; una dichiarazione
/// non disponibile è omessa (VR-16). VR-1, VR-12: il prefisso di versione è
/// anteposto dal client.
void main() {
  Future<Map<String, dynamic>?> sendWith({required int? build, required String? platform}) async {
    final adapter = _RecordingAdapter();
    final dioProvider = Provider<Dio>((ref) {
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ClientHeadersInterceptor(ref, platform: () => platform));
      return dio;
    });
    final container = ProviderContainer(
      overrides: [clientBuildProvider.overrideWithValue(build)],
    );
    addTearDown(container.dispose);

    await container.read(dioProvider).get<void>('/me');
    return adapter.headers;
  }

  test('dichiara piattaforma e build a ogni richiesta (VR-13)', () async {
    final headers = await sendWith(build: 42, platform: 'ios');

    expect(headers?[ClientHeadersInterceptor.platformHeader], 'ios');
    expect(headers?[ClientHeadersInterceptor.buildHeader], '42');
  });

  test('omette il build non leggibile anziché inventarlo (VR-16, VR-19)', () async {
    final headers = await sendWith(build: null, platform: 'android');

    expect(headers?[ClientHeadersInterceptor.platformHeader], 'android');
    expect(headers?.containsKey(ClientHeadersInterceptor.buildHeader), isFalse);
  });

  test('omette la piattaforma estranea a VR-13', () async {
    final headers = await sendWith(build: 7, platform: null);

    expect(headers?.containsKey(ClientHeadersInterceptor.platformHeader), isFalse);
    expect(headers?[ClientHeadersInterceptor.buildHeader], '7');
  });

  test('antepone il prefisso di versione del contratto (VR-1, VR-12)', () {
    final container = ProviderContainer(
      overrides: [clientBuildProvider.overrideWithValue(null)],
    );
    addTearDown(container.dispose);

    expect(container.read(publicApiClientProvider).options.baseUrl, endsWith('/v$apiVersion'));
    expect(container.read(apiClientProvider).options.baseUrl, endsWith('/v$apiVersion'));
  });
}
