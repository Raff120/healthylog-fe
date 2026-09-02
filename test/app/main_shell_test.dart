import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_api.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';
import 'package:healthylog/features/identity/data/identity_api.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/identity_providers.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';
import 'package:healthylog/main.dart';

/// Barra di navigazione principale (3.1, 3.2, 2.6 interfaccia.md), aggiunta
/// retroattivamente a F06 (vedi decisioni.md): quattro voci per l'Utente,
/// Attività e Statistiche visibili ma disabilitate finché le rispettive
/// feature (F23+, F25+) non esistono — non nascoste, un'esclusione per
/// ruolo è l'unico caso ammesso da 2.6. Verificato tramite l'app reale,
/// sul modello di `router_test.dart`.
class _InMemorySecureKeyValueStore extends SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _StatusCodeAdapter implements HttpClientAdapter {
  _StatusCodeAdapter(this.statusCode, this.body);

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

/// VG-19: risponde in base alla data richiesta, per verificare che il
/// ritorno a oggi interroghi davvero la giornata corrente.
class _RecordingDateAdapter implements HttpClientAdapter {
  _RecordingDateAdapter(this._responseFor);

  final String Function(String date) _responseFor;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final date = options.queryParameters['date'] as String;
    return ResponseBody.fromString(
      _responseFor(date),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

String _profileJson(String role) =>
    '{'
    '"id":"user-1","email":"utente@esempio.test","username":"utente",'
    '"firstName":"Nome","lastName":"Cognome","birthDate":"2000-01-01",'
    '"birthPlace":"Roma","sex":"MALE","role":"$role","height":null'
    '}';

Future<ProviderContainer> _pumpAuthenticatedApp(
  WidgetTester tester, {
  required String role,
}) async {
  // `compact` (< 600, app_breakpoints.dart): la barra inferiore mostra
  // sempre l'etichetta (3.2 interfaccia.md) — a differenza della barra
  // laterale compatta, verificabile con i soli `find.text`.
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final store = _InMemorySecureKeyValueStore()
    ..values['refresh_token'] = 'token-valido';
  final identityDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _StatusCodeAdapter(
      200,
      '{"accessToken":"a","refreshToken":"r"}',
    );
  final profileDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _StatusCodeAdapter(200, _profileJson(role));
  // PA-9: nessun piano, così la schermata di 7.1 non serve a questo
  // banco di prova — solo che il tocco su "Piani" vi conduca davvero.
  final dietPlanDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _StatusCodeAdapter(200, '[]')
    ..interceptors.add(ApiErrorInterceptor());
  // PA-10: /home (F12) legge subito la giornata corrente — priva di
  // copertura in questo banco di prova, non pertinente qui.
  final planDayDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _StatusCodeAdapter(
      200,
      '{'
      '"date":"2026-01-01","coverage":"NONE","planId":null,"planName":null,'
      '"planStartDate":null,"planEndDate":null,"slots":[]'
      '}',
    );

  final container = ProviderContainer(
    overrides: [
      secureKeyValueStoreProvider.overrideWithValue(store),
      identityApiProvider.overrideWithValue(IdentityApi(identityDio)),
      profileApiProvider.overrideWithValue(ProfileApi(profileDio)),
      dietPlanApiProvider.overrideWithValue(DietPlanApi(dietPlanDio)),
      planDayApiProvider.overrideWithValue(PlanDayApi(planDayDio)),
      // F14: la base dati reale userebbe path_provider/flutter_secure_storage,
      // assenti nella VM di test (sospensione indefinita, non un errore).
      appDatabaseProvider.overrideWithValue(
        AppDatabase(NativeDatabase.memory()),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const HealthyLogApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets(
    'mostra le quattro voci dell\'Utente, due disabilitate (3.1, 2.6)',
    (tester) async {
      await _pumpAuthenticatedApp(tester, role: 'USER');

      // "Piano" compare due volte da F12: l'etichetta della barra e il
      // titolo della vista giornaliera che vi si apre.
      expect(find.text('Piano'), findsNWidgets(2));
      expect(find.text('Attività'), findsOneWidget);
      expect(find.text('Statistiche'), findsOneWidget);
      expect(find.text('Profilo'), findsOneWidget);
    },
  );

  testWidgets('una voce disabilitata non naviga e spiega perché (2.6)', (
    tester,
  ) async {
    await _pumpAuthenticatedApp(tester, role: 'USER');

    await tester.tap(find.text('Statistiche'));
    await tester.pump();

    expect(find.text('Statistiche: non ancora disponibile.'), findsOneWidget);
    // La destinazione resta quella di partenza (Piano, F12): il tocco su
    // una voce disabilitata non naviga. Nessun piano mai creato in
    // questo banco di prova (dietPlanDio restituisce `[]`): l'invito a
    // crearne uno, non il neutro "fuori piano" (PA-10, 4.4).
    expect(find.text('Inizia da qui'), findsOneWidget);
  });

  testWidgets('il tocco su Profilo naviga e conserva la barra', (tester) async {
    await _pumpAuthenticatedApp(tester, role: 'USER');

    await tester.tap(find.text('Profilo'));
    await tester.pumpAndSettle();

    expect(find.text('Disconnetti'), findsOneWidget);
    // La barra resta: le stesse quattro voci sono ancora presenti.
    expect(find.text('Piano'), findsOneWidget);
    expect(find.text('Profilo'), findsOneWidget);
  });

  testWidgets(
    'il tocco su Piani apre la gestione del piano in corso (F10, 7.1)',
    (tester) async {
      await _pumpAuthenticatedApp(tester, role: 'USER');

      await tester.tap(find.text('Profilo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Piani'));
      await tester.pumpAndSettle();

      expect(find.text('Inizia da qui'), findsOneWidget);
    },
  );

  testWidgets(
    'il doppio tocco su Piano riporta alla giornata corrente (VG-19, 6.2)',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final requestedDates = <String>[];
      final today = dateOnly(DateTime.now());
      final tomorrow = today.add(const Duration(days: 1));

      final store = _InMemorySecureKeyValueStore()
        ..values['refresh_token'] = 'token-valido';
      final identityDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
        ..httpClientAdapter = _StatusCodeAdapter(
          200,
          '{"accessToken":"a","refreshToken":"r"}',
        );
      final profileDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
        ..httpClientAdapter = _StatusCodeAdapter(200, _profileJson('USER'));
      final dietPlanDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
        ..httpClientAdapter = _StatusCodeAdapter(200, '[]')
        ..interceptors.add(ApiErrorInterceptor());
      final planDayDio = Dio(BaseOptions(baseUrl: 'http://example.test'));
      planDayDio.httpClientAdapter = _RecordingDateAdapter((date) {
        requestedDates.add(date);
        return '{'
            '"date":"$date","coverage":"NONE","planId":null,"planName":null,'
            '"planStartDate":null,"planEndDate":null,"slots":[]'
            '}';
      });

      final container = ProviderContainer(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(store),
          identityApiProvider.overrideWithValue(IdentityApi(identityDio)),
          profileApiProvider.overrideWithValue(ProfileApi(profileDio)),
          dietPlanApiProvider.overrideWithValue(DietPlanApi(dietPlanDio)),
          planDayApiProvider.overrideWithValue(PlanDayApi(planDayDio)),
          appDatabaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const HealthyLogApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(requestedDates, [isoDate(today)]);

      await tester.fling(
        find.byKey(const Key('dailyViewContentSwipe')),
        const Offset(-300, 0),
        800,
      );
      await tester.pumpAndSettle();

      expect(requestedDates, [isoDate(today), isoDate(tomorrow)]);

      // 6.2: il doppio tocco è il secondo tocco sulla voce già selezionata.
      await tester.tap(find.byKey(const Key('navItem-Piano')));
      await tester.pumpAndSettle();

      expect(requestedDates, [
        isoDate(today),
        isoDate(tomorrow),
        isoDate(today),
      ]);
    },
  );

  testWidgets('mostra le tre voci del Nutrizionista (3.1)', (tester) async {
    await _pumpAuthenticatedApp(tester, role: 'NUTRITIONIST');

    expect(find.text('Pazienti'), findsOneWidget);
    expect(find.text('Template'), findsOneWidget);
    expect(find.text('Profilo'), findsOneWidget);
    expect(find.text('Attività'), findsNothing);
  });
}
