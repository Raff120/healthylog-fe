import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/api/token_refresh_interceptor.dart';
import 'package:healthylog/core/auth/session.dart';
import 'package:healthylog/core/auth/session_controller.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/features/identity/data/auth_models.dart';
import 'package:healthylog/features/identity/data/identity_api.dart';
import 'package:healthylog/features/identity/providers/identity_providers.dart';

/// TK-13: la richiesta che incontra `TOKEN_EXPIRED` è ripetuta dopo un
/// rinnovo trasparente. La deduplicazione delle richieste concorrenti
/// (TK-14) è materia di `SessionController.refreshSession`, verificata
/// direttamente in `session_controller_test.dart` — più precisa di una
/// prova a questo livello, dove il numero di passaggi asincroni della
/// pipeline di dio la renderebbe instabile.
class _InMemorySecureKeyValueStore extends SecureKeyValueStore {
  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}
}

/// Restituisce `TOKEN_EXPIRED` finché la richiesta non reca il segno del
/// tentativo già ripetuto dall'intercettore (impostato da
/// [TokenRefreshInterceptor] su `options.extra`), poi un esito `200`.
class _ExpiringThenSucceedingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final retried = options.extra['tokenRefreshRetried'] == true;
    if (!retried) {
      return ResponseBody.fromString(
        '{"code":"TOKEN_EXPIRED"}',
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _StubIdentityApi extends IdentityApi {
  _StubIdentityApi() : super(Dio());

  int refreshCalls = 0;

  @override
  Future<TokenPair> refresh(String refreshToken) async {
    refreshCalls++;
    return TokenPair(accessToken: 'access-$refreshCalls', refreshToken: 'refresh-$refreshCalls');
  }
}

final _wiredDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _ExpiringThenSucceedingAdapter();
  dio.interceptors.addAll([
    TokenRefreshInterceptor(ref, dio),
    ApiErrorInterceptor(),
  ]);
  return dio;
});

void main() {
  test('TokenRefreshInterceptor ripete la richiesta dopo il rinnovo', () async {
    final identityApi = _StubIdentityApi();
    final container = ProviderContainer(
      overrides: [
        secureKeyValueStoreProvider.overrideWithValue(_InMemorySecureKeyValueStore()),
        identityApiProvider.overrideWithValue(identityApi),
      ],
    );
    addTearDown(container.dispose);

    // Nessun token conservato: il ripristino all'avvio risolve a
    // sessione assente senza chiamare `refresh` (non contaminando il
    // conteggio delle chiamate verificato sotto).
    await container.read(sessionControllerProvider.future);
    await container
        .read(sessionControllerProvider.notifier)
        .set(const AuthSession(accessToken: 'scaduto', refreshToken: 'refresh-iniziale'));

    final dio = container.read(_wiredDioProvider);
    final response = await dio.get<Map<String, dynamic>>('/me');

    expect(response.statusCode, 200);
    expect(response.data?['ok'], true);
    expect(identityApi.refreshCalls, 1);
    expect(container.read(sessionControllerProvider).value?.accessToken, 'access-1');
  });
}
