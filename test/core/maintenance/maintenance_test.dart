import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/maintenance_screen.dart';
import 'package:healthylog/app/router.dart';
import 'package:healthylog/app/update_required_screen.dart';
import 'package:healthylog/core/api/api_client.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/api/client_build.dart';
import 'package:healthylog/core/api/client_update_interceptor.dart';
import 'package:healthylog/core/api/maintenance_interceptor.dart';
import 'package:healthylog/core/maintenance/maintenance_controller.dart';
import 'package:healthylog/core/maintenance/service_status_client.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/core/storage/local_database_wipe_service.dart';
import 'package:healthylog/core/storage/preferences_store.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/core/update/client_update_controller.dart';
import 'package:healthylog/core/update/store_link.dart';
import 'package:healthylog/core/widgets/app_secondary_button.dart';
import 'package:healthylog/features/identity/presentation/login_screen.dart';
import 'package:healthylog/main.dart';

import '../../support/preferences_store_stub.dart';

const _maintenanceBody = '{"code":"MAINTENANCE"}';

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

/// Risposta modificabile nel corso della prova: la manutenzione comincia e
/// finisce, e la medesima chiamata deve rispondere in due modi.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.body);

  int statusCode;
  String body;
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

/// Coda degli intercettori del client pubblico: la manutenzione precede la
/// traduzione degli errori, come in `api_client.dart`.
Dio _dioWith(Ref ref, _StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.addAll([
    ClientUpdateInterceptor(ref),
    MaintenanceInterceptor(ref),
    ApiErrorInterceptor(),
  ]);
  return dio;
}

/// CC-43, CC-44: MN-2, MN-4, MN-5, MN-6, MM-7, MM-8, MM-9, MM-10.
void main() {
  final disposed = <ProviderContainer>{};

  /// I contenitori si eliminano dentro la prova e non soltanto al termine:
  /// finché la manutenzione dura, la verifica periodica (MM-9) è un timer
  /// pendente, e `testWidgets` non ammette di concludere lasciandone.
  void dispose(ProviderContainer container) {
    if (disposed.add(container)) container.dispose();
  }

  group('MaintenanceInterceptor', () {
    Future<ProviderContainer> requestWith(
      int statusCode,
      String body, {
      InMemoryPreferencesStore? preferences,
    }) async {
      final adapter = _StubAdapter(statusCode, body);
      final dioProvider = Provider<Dio>((ref) => _dioWith(ref, adapter));
      final container = ProviderContainer(overrides: [
        clientBuildProvider.overrideWithValue(12),
        preferencesStoreProvider.overrideWithValue(preferences ?? InMemoryPreferencesStore()),
      ]);
      addTearDown(() => dispose(container));

      await expectLater(container.read(dioProvider).get<void>('/me'), throwsA(isA<DioException>()));
      await Future<void>.delayed(Duration.zero);
      return container;
    }

    test('MM-7: dispone lo sbarramento a qualsiasi chiamata', () async {
      final container = await requestWith(503, _maintenanceBody);

      expect(container.read(maintenanceControllerProvider), isTrue);
    });

    test('MM-7: lo sbarramento non è ricordato sul dispositivo', () async {
      final preferences = InMemoryPreferencesStore();
      final container = await requestWith(503, _maintenanceBody, preferences: preferences);

      expect(container.read(maintenanceControllerProvider), isTrue);
      // Diversamente dall'aggiornamento obbligatorio, che ricorda il build
      // respinto: la manutenzione vale finché il servizio la dichiara.
      expect(preferences.values, isEmpty);
    });

    test('ignora ogni altro esito negativo', () async {
      final altroCodice = await requestWith(503, '{"code":"SOMETHING_ELSE"}');
      expect(altroCodice.read(maintenanceControllerProvider), isFalse);

      final altroStato = await requestWith(409, _maintenanceBody);
      expect(altroStato.read(maintenanceControllerProvider), isFalse);
    });
  });

  group('HealthyLogApp', () {
    ProviderContainer containerFor({
      required _StubAdapter identityAdapter,
      required HttpClientAdapter statusAdapter,
      _InMemorySecureKeyValueStore? secureStore,
      InMemoryPreferencesStore? preferences,
      void Function()? onDatabaseWipe,
    }) {
      final container = ProviderContainer(
        // Il ripristino della sessione fallisce di proposito: il nuovo
        // tentativo che Riverpod pianificherebbe resterebbe in sospeso oltre
        // la fine della prova.
        retry: (retryCount, error) => null,
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(secureStore ?? _InMemorySecureKeyValueStore()),
          preferencesStoreProvider.overrideWithValue(preferences ?? InMemoryPreferencesStore()),
          clientBuildProvider.overrideWithValue(12),
          storeLinkProvider.overrideWith((ref) async => Uri.parse('https://example.test/app')),
          publicApiClientProvider.overrideWith((ref) => _dioWith(ref, identityAdapter)),
          serviceStatusClientProvider.overrideWith((ref) {
            final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
            dio.httpClientAdapter = statusAdapter;
            return dio;
          }),
          appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
          deleteDatabaseFileProvider.overrideWithValue(() async => onDatabaseWipe?.call()),
        ],
      );
      addTearDown(() => dispose(container));
      return container;
    }

    testWidgets('CC-43: il rinnovo in manutenzione sbarra e conserva sessione e dati locali', (tester) async {
      final secureStore = _InMemorySecureKeyValueStore({'refresh_token': 'token-valido'});
      var wiped = false;
      final container = containerFor(
        secureStore: secureStore,
        identityAdapter: _StubAdapter(503, _maintenanceBody),
        statusAdapter: _StubAdapter(503, _maintenanceBody),
        onDatabaseWipe: () => wiped = true,
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HealthyLogApp()));
      await tester.pumpAndSettle();

      expect(find.byType(MaintenanceScreen), findsOneWidget);
      // MM-8, MN-4: la manutenzione non è una revoca, nemmeno incontrata al
      // rinnovo del token.
      expect(secureStore.values['refresh_token'], 'token-valido');
      expect(wiped, isFalse);

      // 5.6 interfaccia.md: nessuna uscita, né per navigazione né col ritorno.
      container.read(goRouterProvider).go('/login');
      await tester.pumpAndSettle();
      expect(find.byType(MaintenanceScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MaintenanceScreen), findsOneWidget);

      dispose(container);
    });

    testWidgets('CC-44: la schermata cade alla prima verifica non più in manutenzione', (tester) async {
      final statusAdapter = _StubAdapter(503, _maintenanceBody);
      final container = containerFor(
        identityAdapter: _StubAdapter(200, '{}'),
        statusAdapter: statusAdapter,
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HealthyLogApp()));
      await tester.pumpAndSettle();
      container.read(maintenanceControllerProvider.notifier).markActive();
      await tester.pumpAndSettle();
      expect(find.byType(MaintenanceScreen), findsOneWidget);

      // MM-9: finché il servizio la dichiara, la verifica periodica non
      // porta via nulla.
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(statusAdapter.calls, 1);
      expect(find.byType(MaintenanceScreen), findsOneWidget);

      // MN-5: terminata, la si riconosce senza che l'Utente faccia nulla.
      statusAdapter
        ..statusCode = 200
        ..body = '{"status":"UP"}';
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();

      expect(find.byType(MaintenanceScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('MN-5: il pulsante chiede subito la medesima verifica', (tester) async {
      final statusAdapter = _StubAdapter(200, '{"status":"UP"}');
      final container = containerFor(
        identityAdapter: _StubAdapter(200, '{}'),
        statusAdapter: statusAdapter,
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HealthyLogApp()));
      await tester.pumpAndSettle();
      container.read(maintenanceControllerProvider.notifier).markActive();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppSecondaryButton));
      await tester.pumpAndSettle();

      expect(statusAdapter.calls, 1);
      expect(find.byType(MaintenanceScreen), findsNothing);
    });

    testWidgets('MN-6: un errore di trasporto non è una fine', (tester) async {
      final container = containerFor(
        identityAdapter: _StubAdapter(200, '{}'),
        statusAdapter: _UnreachableAdapter(),
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HealthyLogApp()));
      await tester.pumpAndSettle();
      container.read(maintenanceControllerProvider.notifier).markActive();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();

      expect(find.byType(MaintenanceScreen), findsOneWidget);

      dispose(container);
    });

    testWidgets('MN-6: alla riapertura non si ripresenta se il servizio non la dichiara', (tester) async {
      final statusAdapter = _StubAdapter(200, '{"status":"UP"}');
      final container = containerFor(
        identityAdapter: _StubAdapter(200, '{}'),
        statusAdapter: statusAdapter,
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HealthyLogApp()));
      await tester.pumpAndSettle();

      expect(find.byType(MaintenanceScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      // Nessuno interroga lo stato: non c'è sbarramento da cui uscire.
      expect(statusAdapter.calls, 0);
    });

    testWidgets('MM-10: la schermata di aggiornamento prevale', (tester) async {
      final container = containerFor(
        preferences: InMemoryPreferencesStore({ClientUpdateController.storageKey: '12'}),
        identityAdapter: _StubAdapter(503, _maintenanceBody),
        statusAdapter: _StubAdapter(503, _maintenanceBody),
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HealthyLogApp()));
      await tester.pumpAndSettle();
      container.read(maintenanceControllerProvider.notifier).markActive();
      await tester.pumpAndSettle();

      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
      expect(find.byType(MaintenanceScreen), findsNothing);

      dispose(container);
    });
  });
}

/// Servizio irraggiungibile: nessuna risposta affatto, non un rifiuto.
class _UnreachableAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'rete assente',
    );
  }
}
