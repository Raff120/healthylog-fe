import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/auth/session.dart';
import 'package:healthylog/core/auth/session_controller.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/core/storage/local_database_wipe_service.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/features/identity/data/auth_models.dart';
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

/// F14: a differenza di [_stubIdentityApi], reca `ApiErrorInterceptor`
/// — necessario perché `SessionController._refreshWith` riconosca
/// `NETWORK_ERROR` (senza interpretazione, un errore di rete grezzo
/// non è distinguibile da un rifiuto genuino).
IdentityApi _networkErrorIdentityApi() {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _NetworkErrorAdapter()
    ..interceptors.add(ApiErrorInterceptor());
  return IdentityApi(dio);
}

/// Conta le chiamate a `refresh` e ne rinvia il completamento finché il
/// chiamante del test non lo sblocca esplicitamente (`release`), per
/// osservare la deduplicazione (TK-14) senza dipendere dai tempi della
/// pipeline HTTP.
class _GatedIdentityApi extends IdentityApi {
  _GatedIdentityApi() : super(Dio());

  int refreshCalls = 0;
  final _gate = Completer<void>();

  @override
  Future<TokenPair> refresh(String refreshToken) async {
    refreshCalls++;
    await _gate.future;
    return TokenPair(accessToken: 'access-$refreshCalls', refreshToken: 'refresh-$refreshCalls');
  }

  void release() => _gate.complete();
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
          // PL-17, F14: la rimozione della base dati locale userebbe
          // path_provider/flutter_secure_storage, assenti nella VM di
          // test (sospensione indefinita, non un errore catturabile).
          appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
          deleteDatabaseFileProvider.overrideWithValue(() async {}),
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
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(store),
          // PL-17, F14: la rimozione della base dati locale userebbe
          // path_provider/flutter_secure_storage, assenti nella VM di
          // test (sospensione indefinita, non un errore catturabile).
          appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
          deleteDatabaseFileProvider.overrideWithValue(() async {}),
        ],
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

    test('refreshSession restituisce null in assenza di sessione', () async {
      final container = ProviderContainer(
        overrides: [secureKeyValueStoreProvider.overrideWithValue(_InMemorySecureKeyValueStore())],
      );
      addTearDown(container.dispose);
      await container.read(sessionControllerProvider.future);

      final session = await container.read(sessionControllerProvider.notifier).refreshSession();

      expect(session, isNull);
    });

    test('refreshSession: chiamate concorrenti condividono lo stesso rinnovo (TK-14)', () async {
      final identityApi = _GatedIdentityApi();
      final container = ProviderContainer(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(_InMemorySecureKeyValueStore()),
          identityApiProvider.overrideWithValue(identityApi),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sessionControllerProvider.future);
      await container
          .read(sessionControllerProvider.notifier)
          .set(const AuthSession(accessToken: 'scaduto', refreshToken: 'refresh-iniziale'));

      final notifier = container.read(sessionControllerProvider.notifier);
      final first = notifier.refreshSession();
      final second = notifier.refreshSession();

      // Le due chiamate, invocate senza alcun await frapposto, DEVONO
      // condividere il medesimo Future: è questa identità — non un
      // controllo temporizzato sulla pipeline HTTP — a garantire TK-14
      // indipendentemente da come dio interleccia le richieste reali.
      expect(identical(first, second), isTrue);

      identityApi.release();
      final results = await Future.wait([first, second]);

      expect(results[0]?.accessToken, 'access-1');
      expect(results[1]?.accessToken, 'access-1');
      expect(identityApi.refreshCalls, 1);
    });

    test('un accesso esplicito non è sovrascritto da un ripristino ancora in corso', () async {
      // Riproduce lo scenario che ha originato questo test: un token di
      // rinnovo conservato (da una sessione precedente) fa sì che
      // `build` sia ancora in attesa di `/auth/refresh` quando
      // l'Utente completa un accesso con un account diverso.
      final store = _InMemorySecureKeyValueStore()..values['refresh_token'] = 'token-di-una-sessione-precedente';
      final identityApi = _GatedIdentityApi();
      final container = ProviderContainer(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(store),
          identityApiProvider.overrideWithValue(identityApi),
        ],
      );
      addTearDown(container.dispose);

      // `build` è avviato (legge il token, poi si blocca in `refresh`,
      // trattenuto da `identityApi`) ma non ancora risolto.
      final buildFuture = container.read(sessionControllerProvider.future);

      // L'Utente completa un accesso con un account diverso mentre il
      // ripristino è ancora in corso.
      await container
          .read(sessionControllerProvider.notifier)
          .set(const AuthSession(accessToken: 'nuovo-accesso', refreshToken: 'nuovo-rinnovo'));

      // Il ripristino, tardivo, risolve ora.
      identityApi.release();
      await buildFuture;

      final state = container.read(sessionControllerProvider).value;
      expect(state?.accessToken, 'nuovo-accesso');
      expect(store.values['refresh_token'], 'nuovo-rinnovo');
    });

    test('refreshSession: un errore di rete non ripulisce token né base dati, e si propaga (F14)', () async {
      var wipeCalls = 0;
      // Nessun token conservato all'avvio: altrimenti `build` tenterebbe
      // subito il ripristino attraverso lo stesso identityApi di rete
      // assente, che questo test riserva a `refreshSession`.
      final store = _InMemorySecureKeyValueStore();
      final container = ProviderContainer(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(store),
          identityApiProvider.overrideWithValue(_networkErrorIdentityApi()),
          appDatabaseProvider.overrideWith((ref) => AppDatabase(NativeDatabase.memory())),
          deleteDatabaseFileProvider.overrideWithValue(() async => wipeCalls++),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sessionControllerProvider.future);
      await container
          .read(sessionControllerProvider.notifier)
          .set(const AuthSession(accessToken: 'scaduto', refreshToken: 'refresh-1'));

      Object? caught;
      try {
        await container.read(sessionControllerProvider.notifier).refreshSession();
      } catch (error) {
        caught = error;
      }

      expect(caught, isNotNull, reason: 'un errore di rete deve propagarsi, non risolvere a null in silenzio');
      expect(store.values.containsKey('refresh_token'), isTrue, reason: 'PL-19 non si applica a un errore di rete');
      expect(wipeCalls, 0, reason: 'PL-17 non si applica a un errore di rete');
    });
  });
}
