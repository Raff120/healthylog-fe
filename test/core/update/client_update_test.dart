import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/router.dart';
import 'package:healthylog/app/update_required_screen.dart';
import 'package:healthylog/core/api/api_client.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/api/client_build.dart';
import 'package:healthylog/core/api/client_update_interceptor.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/core/storage/preferences_store.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/core/update/client_update_controller.dart';
import 'package:healthylog/core/update/store_link.dart';
import 'package:healthylog/core/widgets/app_primary_button.dart';
import 'package:healthylog/features/identity/presentation/login_screen.dart';
import 'package:healthylog/main.dart';

import '../../support/preferences_store_stub.dart';

class _InMemorySecureKeyValueStore extends SecureKeyValueStore {
  _InMemorySecureKeyValueStore([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

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
  int calls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(body, statusCode, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

const _updateRequiredBody = '{"code":"CLIENT_UPDATE_REQUIRED"}';

/// Coda degli intercettori del client pubblico: l'aggiornamento precede la
/// traduzione degli errori, come in `api_client.dart`.
Dio _dioWith(Ref ref, _StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.addAll([ClientUpdateInterceptor(ref), ApiErrorInterceptor()]);
  return dio;
}

/// CC-42, MP-15, MP-16, VR-17.
void main() {
  group('ClientUpdateInterceptor', () {
    Future<ProviderContainer> requestWith(int statusCode, String body, InMemoryPreferencesStore store) async {
      final adapter = _StubAdapter(statusCode, body);
      final dioProvider = Provider<Dio>((ref) => _dioWith(ref, adapter));
      final container = ProviderContainer(overrides: [
        preferencesStoreProvider.overrideWithValue(store),
        clientBuildProvider.overrideWithValue(12),
      ]);
      addTearDown(container.dispose);
      await container.read(clientUpdateControllerProvider.future);

      await expectLater(container.read(dioProvider).get<void>('/me'), throwsA(isA<DioException>()));
      await Future<void>.delayed(Duration.zero);
      return container;
    }

    test('dispone lo sbarramento e ricorda il build respinto', () async {
      final store = InMemoryPreferencesStore();
      final container = await requestWith(426, _updateRequiredBody, store);

      expect(container.read(clientUpdateControllerProvider).value, isTrue);
      expect(store.values[ClientUpdateController.storageKey], '12');
    });

    test('ignora ogni altro esito negativo', () async {
      final store = InMemoryPreferencesStore();
      final conflict = await requestWith(409, _updateRequiredBody, store);
      expect(conflict.read(clientUpdateControllerProvider).value, isFalse);

      final otherCode = await requestWith(426, '{"code":"SOMETHING_ELSE"}', store);
      expect(otherCode.read(clientUpdateControllerProvider).value, isFalse);
      expect(store.values, isEmpty);
    });
  });

  group('HealthyLogApp', () {
    ProviderContainer containerFor({
      required _InMemorySecureKeyValueStore secureStore,
      required InMemoryPreferencesStore preferences,
      required int build,
      required _StubAdapter identityAdapter,
    }) {
      final container = ProviderContainer(
        // Il ripristino della sessione fallisce di proposito: il nuovo
        // tentativo che Riverpod pianificherebbe resterebbe in sospeso oltre
        // la fine del test.
        retry: (retryCount, error) => null,
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(secureStore),
          preferencesStoreProvider.overrideWithValue(preferences),
          clientBuildProvider.overrideWithValue(build),
          storeLinkProvider.overrideWith((ref) async => Uri.parse('https://example.test/app')),
          // Il client pubblico, e non l'API d'identità: in produzione gli
          // intercettori vivono nel client, che resta in vita (keepAlive) e ne
          // mantiene valido il ref fino all'arrivo della risposta.
          publicApiClientProvider.overrideWith((ref) => _dioWith(ref, identityAdapter)),
          appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    testWidgets('il rinnovo respinto conduce all\'aggiornamento e conserva la sessione', (tester) async {
      final secureStore = _InMemorySecureKeyValueStore({'refresh_token': 'token-valido'});
      final preferences = InMemoryPreferencesStore();
      final container = containerFor(
        secureStore: secureStore,
        preferences: preferences,
        build: 12,
        identityAdapter: _StubAdapter(426, _updateRequiredBody),
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HealthyLogApp()));
      await tester.pumpAndSettle();

      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
      expect(find.byType(AppPrimaryButton), findsOneWidget);
      // MP-16: la versione superata non è una revoca.
      expect(secureStore.values['refresh_token'], 'token-valido');
      expect(preferences.values[ClientUpdateController.storageKey], '12');

      // 5.5 interfaccia.md: nessuna uscita, né per navigazione né col ritorno.
      container.read(goRouterProvider).go('/login');
      await tester.pumpAndSettle();
      expect(find.byType(UpdateRequiredScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
    });

    testWidgets('alla riapertura senza rete lo sbarramento si ripresenta', (tester) async {
      final identityAdapter = _StubAdapter(200, '{}');
      final container = containerFor(
        secureStore: _InMemorySecureKeyValueStore(),
        preferences: InMemoryPreferencesStore({ClientUpdateController.storageKey: '12'}),
        build: 12,
        identityAdapter: identityAdapter,
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HealthyLogApp()));
      await tester.pumpAndSettle();

      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
      expect(identityAdapter.calls, 0);
    });

    testWidgets('installata la versione nuova lo sbarramento cade', (tester) async {
      final container = containerFor(
        secureStore: _InMemorySecureKeyValueStore(),
        preferences: InMemoryPreferencesStore({ClientUpdateController.storageKey: '12'}),
        build: 13,
        identityAdapter: _StubAdapter(200, '{}'),
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HealthyLogApp()));
      await tester.pumpAndSettle();

      expect(find.byType(UpdateRequiredScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
