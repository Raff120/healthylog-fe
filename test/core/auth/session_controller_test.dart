import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/auth/session.dart';
import 'package:healthylog/core/auth/session_controller.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/features/identity/data/identity_api.dart';
import 'package:healthylog/features/identity/providers/identity_providers.dart';

/// Ripristino della sessione all'avvio (TK-8): un token di rinnovo
/// assente o non più valido equivale a nessuna sessione, mai a un
/// errore mostrato; un token valido è ruotato e sostituito nell'archivio
/// (TK-11), coerentemente con la rotazione applicata dal backend a ogni
/// rinnovo.
class _InMemorySecureKeyValueStore extends SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

IdentityApi _stubIdentityApi(int statusCode, String body) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = _StubAdapter(statusCode, body);
  return IdentityApi(dio);
}

void main() {
  group('SessionController', () {
    test('nessun token conservato: la sessione resta assente', () async {
      final container = ProviderContainer(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(_InMemorySecureKeyValueStore()),
        ],
      );
      addTearDown(container.dispose);

      final session = await container.read(sessionControllerProvider.future);

      expect(session, isNull);
    });

    test('token valido: la sessione è ripristinata e il token ruotato è persistito', () async {
      final store = _InMemorySecureKeyValueStore()..values['refresh_token'] = 'token-vecchio';
      final container = ProviderContainer(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(store),
          identityApiProvider.overrideWithValue(
            _stubIdentityApi(200, '{"accessToken":"nuovo-accesso","refreshToken":"nuovo-rinnovo"}'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final session = await container.read(sessionControllerProvider.future);

      expect(session?.accessToken, 'nuovo-accesso');
      expect(session?.refreshToken, 'nuovo-rinnovo');
      expect(store.values['refresh_token'], 'nuovo-rinnovo');
    });

    test('token non più valido: l\'archivio è ripulito e la sessione resta assente', () async {
      final store = _InMemorySecureKeyValueStore()..values['refresh_token'] = 'token-revocato';
      final container = ProviderContainer(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(store),
          identityApiProvider.overrideWithValue(
            _stubIdentityApi(401, '{"code":"REFRESH_TOKEN_INVALID"}'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final session = await container.read(sessionControllerProvider.future);

      expect(session, isNull);
      expect(store.values.containsKey('refresh_token'), isFalse);
    });

    test('set persiste il token di rinnovo e clear lo rimuove', () async {
      final store = _InMemorySecureKeyValueStore();
      final container = ProviderContainer(
        overrides: [secureKeyValueStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .set(const AuthSession(accessToken: 'a', refreshToken: 'r'));
      expect(store.values['refresh_token'], 'r');
      expect(container.read(sessionControllerProvider).value?.accessToken, 'a');

      await container.read(sessionControllerProvider.notifier).clear();
      expect(store.values.containsKey('refresh_token'), isFalse);
      expect(container.read(sessionControllerProvider).value, isNull);
    });
  });
}
