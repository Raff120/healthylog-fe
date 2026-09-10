import '../support/notification_api_stub.dart';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_spacing.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_api.dart';
import 'package:healthylog/features/dietplan/data/diet_plan_template_api.dart';
import 'package:healthylog/features/dietplan/data/plan_day_api.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_providers.dart';
import 'package:healthylog/features/dietplan/providers/diet_plan_template_providers.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';
import 'package:healthylog/features/care/providers/care_providers.dart';
import 'package:healthylog/features/group/data/cooking_group_api.dart';
import 'package:healthylog/features/group/providers/cooking_group_providers.dart';
import 'package:healthylog/features/identity/data/identity_api.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/identity_providers.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';
import 'package:healthylog/core/storage/preferences_store.dart';
import 'package:healthylog/features/notification/providers/notification_providers.dart';
import 'package:healthylog/features/statistics/providers/statistics_providers.dart';
import 'package:healthylog/features/workout/providers/workout_providers.dart';
import 'package:healthylog/main.dart';

import '../support/care_api_stub.dart';
import '../support/preferences_store_stub.dart';
import '../support/statistics_api_stub.dart';
import '../support/workout_api_stub.dart';

/// Barra di navigazione principale (3.1, 3.2 interfaccia.md), aggiunta
/// retroattivamente a F06 (vedi decisioni.md): quattro voci per l'Utente,
/// tre per il Nutrizionista. Dalla Fase 7 nessuna voce dell'Utente è più
/// disabilitata — *Attività* (F23) e *Statistiche* (F25) hanno entrambe
/// una schermata propria. Verificato tramite l'app reale, sul modello di
/// `router_test.dart`.
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
  // `compact` (< 600, app_breakpoints.dart): la barra inferiore mostra
  // sempre l'etichetta (3.2 interfaccia.md) — a differenza della barra
  // laterale compatta, verificabile con i soli `find.text`.
  Size size = const Size(400, 800),
  TargetPlatform? platform,
}) async {
  tester.view.physicalSize = size;
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
  // VG-8: nessun Gruppo di appartenenza, così MemberSelector (F20) non
  // presenta nulla nell'intestazione di *Piano* — senza questa risposta
  // interrogherebbe un client HTTP reale, non presente in questo banco
  // di prova.
  final cookingGroupDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = _StatusCodeAdapter(404, '{"code":"RESOURCE_NOT_FOUND"}')
    ..interceptors.add(ApiErrorInterceptor());

  final container = ProviderContainer(
    overrides: [
      secureKeyValueStoreProvider.overrideWithValue(store),
      identityApiProvider.overrideWithValue(IdentityApi(identityDio)),
      profileApiProvider.overrideWithValue(ProfileApi(profileDio)),
      dietPlanApiProvider.overrideWithValue(DietPlanApi(dietPlanDio)),
      // CT-2: nessun template, per la destinazione *Template* del Nutrizionista.
      dietPlanTemplateApiProvider.overrideWithValue(DietPlanTemplateApi(dietPlanDio)),
      planDayApiProvider.overrideWithValue(PlanDayApi(planDayDio)),
      cookingGroupApiProvider.overrideWithValue(CookingGroupApi(cookingGroupDio)),
      // F21/F22: nessun collegamento professionale (RG-5), nessun Paziente.
      careApiProvider.overrideWithValue(stubCareApi()),
      // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
      // di ogni destinazione principale (3.1).
      notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
      statisticsApiProvider.overrideWithValue(stubStatisticsApi()),
      // 11.1: il periodo selezionato è conservato tra le sessioni; nella
      // VM di test l'archivio locale è in memoria.
      preferencesStoreProvider.overrideWithValue(InMemoryPreferencesStore()),
      // F14: la base dati reale userebbe path_provider/flutter_secure_storage,
      // assenti nella VM di test (sospensione indefinita, non un errore).
      appDatabaseProvider.overrideWithValue(
        AppDatabase(NativeDatabase.memory()),
      ),
    ],
  );
  addTearDown(container.dispose);

  // MP-7: la piattaforma è imposta per la prova, non per adattarvi la
  // disposizione — che dipende dalla sola larghezza della finestra. Va
  // riportata a null prima della fine del corpo della prova, che il
  // banco verifica.
  debugDefaultTargetPlatformOverride = platform;

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
  // MP-7, FE-11: l'adattamento è determinato dalle dimensioni della
  // finestra e non dalla piattaforma. La prova ripete la stessa larghezza
  // su piattaforme diverse e ne attende la medesima disposizione.
  group('adattamento per larghezza, non per piattaforma (MP-7, 3.3)', () {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.android, TargetPlatform.macOS]) {
      testWidgets('$platform: finestra stretta adotta la barra inferiore', (tester) async {
        await _pumpAuthenticatedApp(tester,
            role: 'USER', size: const Size(400, 800), platform: platform);

        final piano = tester.getCenter(find.text('Piano'));
        debugDefaultTargetPlatformOverride = null;
        // La barra inferiore sta in fondo, per l'intera larghezza.
        expect(piano.dy, greaterThan(700));
      });

      testWidgets('$platform: finestra ampia adotta la barra laterale', (tester) async {
        await _pumpAuthenticatedApp(tester,
            role: 'USER', size: const Size(1000, 800), platform: platform);

        final piano = tester.getCenter(find.text('Piano'));
        debugDefaultTargetPlatformOverride = null;
        // La barra laterale sta a sinistra, entro i 240 punti di 3.2.
        expect(piano.dx, lessThan(240));
        expect(piano.dy, lessThan(400));
      });
    }
  });

  // MP-2: nessuna destinazione è riservata a una piattaforma o preclusa su
  // un'altra — l'insieme dipende dal solo ruolo (3.1).
  group('parità delle destinazioni fra piattaforme (MP-2)', () {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.android, TargetPlatform.windows]) {
      testWidgets('$platform presenta le stesse quattro voci', (tester) async {
        await _pumpAuthenticatedApp(tester,
            role: 'USER', size: const Size(400, 800), platform: platform);
        final found = [
          for (final label in ['Piano', 'Attività', 'Statistiche', 'Profilo'])
            if (find.text(label).evaluate().isNotEmpty) label,
        ];
        debugDefaultTargetPlatformOverride = null;
        expect(found, ['Piano', 'Attività', 'Statistiche', 'Profilo']);
      });
    }
  });

  // MP-9: la barra copre con la propria superficie la zona riservata al
  // bordo inferiore dello schermo — l'indicatore di Home sull'iPhone.
  // Segnalato dall'utente sulla PWA installata: sotto la barra restava una
  // fascia di colore diverso, e lo stacco si vedeva. La rientranza sta
  // dentro la superficie della barra, non fuori.
  testWidgets('la barra inferiore copre la zona riservata del dispositivo', (
    tester,
  ) async {
    const safeAreaBottom = 34.0;
    tester.view.padding = const FakeViewPadding(bottom: safeAreaBottom);
    tester.view.viewPadding = const FakeViewPadding(bottom: safeAreaBottom);

    await _pumpAuthenticatedApp(tester, role: 'USER', size: const Size(400, 800));

    final barra = tester.getRect(find.byKey(const ValueKey('bottomNavBar')));
    // Nessuna fascia fra la barra e il bordo dello schermo.
    expect(barra.bottom, 800);
    // La barra è più alta della zona riservata che si è presa.
    expect(barra.height, AppSpacing.heightBottomNav + safeAreaBottom);
    // Le voci restano sopra la zona riservata, non sotto l'indicatore.
    expect(
      tester.getRect(find.text('Piano')).bottom,
      lessThanOrEqualTo(800 - safeAreaBottom),
    );
  });

  testWidgets(
    'mostra le quattro voci dell\'Utente (3.1)',
    (tester) async {
      await _pumpAuthenticatedApp(tester, role: 'USER');

      // F16: il titolo della vista giornaliera ("Piano") è sostituito dal
      // segmented control Giorno/Settimana (6.1 interfaccia.md) —
      // "Piano" compare quindi una sola volta, come etichetta della barra.
      expect(find.text('Piano'), findsOneWidget);
      expect(find.text('Giorno'), findsOneWidget);
      expect(find.text('Settimana'), findsOneWidget);
      expect(find.text('Attività'), findsOneWidget);
      expect(find.text('Statistiche'), findsOneWidget);
      expect(find.text('Profilo'), findsOneWidget);
    },
  );

  testWidgets('il tocco su Statistiche naviga e conserva la barra (F25)', (
    tester,
  ) async {
    await _pumpAuthenticatedApp(tester, role: 'USER');

    await tester.tap(find.text('Statistiche'));
    await tester.pumpAndSettle();

    // 11.1: i tre segmenti dell'intestazione.
    expect(find.text('Aderenza'), findsOneWidget);
    expect(find.text('Corpo'), findsOneWidget);
    // AD-4: senza slot valutabili la constatazione, non uno zero.
    expect(find.text('Non ci sono ancora dati'), findsOneWidget);
    // La barra resta: la voce di partenza è ancora raggiungibile.
    expect(find.text('Profilo'), findsOneWidget);
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
      final cookingGroupDio = Dio(BaseOptions(baseUrl: 'http://example.test'))
        ..httpClientAdapter = _StatusCodeAdapter(404, '{"code":"RESOURCE_NOT_FOUND"}')
        ..interceptors.add(ApiErrorInterceptor());

      final container = ProviderContainer(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(store),
          identityApiProvider.overrideWithValue(IdentityApi(identityDio)),
          profileApiProvider.overrideWithValue(ProfileApi(profileDio)),
          dietPlanApiProvider.overrideWithValue(DietPlanApi(dietPlanDio)),
          planDayApiProvider.overrideWithValue(PlanDayApi(planDayDio)),
          cookingGroupApiProvider.overrideWithValue(CookingGroupApi(cookingGroupDio)),
          // F21/F22: nessun collegamento professionale (RG-5), nessun Paziente.
          careApiProvider.overrideWithValue(stubCareApi()),
          // NT-8, F28: l'indicatore delle notifiche è presente nell'intestazione
          // di ogni destinazione principale (3.1).
          notificationApiProvider.overrideWithValue(stubNotificationApi()),
        workoutApiProvider.overrideWithValue(stubWorkoutApi()),
      statisticsApiProvider.overrideWithValue(stubStatisticsApi()),
      // 11.1: il periodo selezionato è conservato tra le sessioni; nella
      // VM di test l'archivio locale è in memoria.
      preferencesStoreProvider.overrideWithValue(InMemoryPreferencesStore()),
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

    // La voce della barra e il titolo della destinazione iniziale (9.1, F22).
    expect(find.byKey(const Key('navItem-Pazienti')), findsOneWidget);
    expect(find.text('Nessun paziente collegato'), findsOneWidget);
    expect(find.text('Template'), findsOneWidget);
    expect(find.text('Profilo'), findsOneWidget);
    expect(find.text('Attività'), findsNothing);
  });

  /// 3.1, 3.2 interfaccia.md (F22): *Template* è una destinazione della
  /// barra del Nutrizionista — il tocco vi conduce conservando la barra,
  /// non a schermo pieno (segnalato dall'utente, vedi decisioni.md).
  testWidgets('il tocco su Template conserva la barra del Nutrizionista (3.2)', (tester) async {
    await _pumpAuthenticatedApp(tester, role: 'NUTRITIONIST');

    await tester.tap(find.byKey(const Key('navItem-Template')));
    await tester.pumpAndSettle();

    expect(find.text('Nessun template. Crealo con il pulsante in basso.'), findsOneWidget);
    expect(find.byKey(const Key('navItem-Pazienti')), findsOneWidget);
    expect(find.byKey(const Key('navItem-Profilo')), findsOneWidget);
  });
}
