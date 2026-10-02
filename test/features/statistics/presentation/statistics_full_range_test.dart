import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/core/storage/preferences_store.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';
import 'package:healthylog/features/measurement/providers/measurement_providers.dart';
import 'package:healthylog/features/statistics/data/statistics_api.dart';
import 'package:healthylog/features/statistics/data/statistics_models.dart';
import 'package:healthylog/features/statistics/presentation/statistics_screen.dart';
import 'package:healthylog/features/statistics/presentation/widgets/weekly_bar_chart.dart';
import 'package:healthylog/features/statistics/providers/statistics_providers.dart';

import '../../../support/l10n_test_support.dart';
import '../../../support/measurement_api_stub.dart';
import '../../../support/preferences_store_stub.dart';
import '../../../support/statistics_api_stub.dart';

/// AD-8quater, 11.1 interfaccia.md: gli orizzonti *Tutto* e *Intervallo*
/// — le richieste che ne discendono, il navigatore senza frecce, la
/// scelta delle date e la persistenza fra le sessioni.

/// Registra le richieste di statistiche e serve il profilo, con il giorno
/// della registrazione (AH-21).
class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  Map<String, dynamic> lastQueryOf(String path) =>
      requests.lastWhere((request) => request.path == path).queryParameters;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return switch (options.path) {
      '/statistics/adherence' => _json(200, emptyAdherenceJson()),
      '/statistics/workouts' => _json(200, emptyWorkoutStatisticsJson()),
      '/statistics/measurements' => _json(200, emptyMeasurementStatisticsJson()),
      '/me' => _json(200, _profileJson),
      _ => _json(404, {'code': 'RESOURCE_NOT_FOUND'}),
    };
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

const _profileJson = {
  'id': 'user-1',
  'email': 'utente@example.it',
  'username': 'utente',
  'firstName': 'Mario',
  'lastName': 'Rossi',
  'birthDate': '1990-01-01',
  'birthPlace': 'Roma',
  'sex': 'MALE',
  'role': 'USER',
  'height': 178,
  'targetWeightKg': null,
  'timezone': 'Europe/Rome',
  'locale': 'IT',
  'unitSystem': 'METRIC',
  'privacyAcceptanceRequired': false,
  'deletionRequestedAt': null,
  'deletionEffectiveAt': null,
  'registeredOn': '2026-03-12',
};

Future<({_RecordingAdapter adapter, InMemoryPreferencesStore preferences})> _pump(
  WidgetTester tester, {
  Map<String, String>? stored,
  // Il selettore di date a schermo intero, nel carattere del banco di
  // prova a glifi quadrati, non sta in 400 punti: lo si apre più largo.
  Size size = const Size(400, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final adapter = _RecordingAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());
  final preferences = InMemoryPreferencesStore(stored);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        statisticsApiProvider.overrideWithValue(StatisticsApi(dio)),
        profileApiProvider.overrideWithValue(ProfileApi(dio)),
        measurementApiProvider.overrideWithValue(stubMeasurementApi()),
        preferencesStoreProvider.overrideWithValue(preferences),
      ],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: const StatisticsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (adapter: adapter, preferences: preferences);
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(StatisticsScreen)));

Future<void> _choose(WidgetTester tester, String horizon) async {
  await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
  await tester.pumpAndSettle();
  await tester.tap(find.text(horizon).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('il selettore offre i cinque orizzonti (AD-8, AD-8quater)', (tester) async {
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    await tester.pumpAndSettle();

    for (final horizon in ['Settimana', 'Mese', 'Piano', 'Tutto', 'Intervallo']) {
      expect(find.text(horizon), findsWidgets, reason: horizon);
    }
  });

  /// AH-21: *Tutto* decorre dalla registrazione; nulla da scorrere, e il
  /// navigatore lo dichiara senza frecce.
  testWidgets('su Tutto chiede ALL e dichiara la registrazione senza frecce', (tester) async {
    final pumped = await _pump(tester);

    await _choose(tester, 'Tutto');

    final query = pumped.adapter.lastQueryOf('/statistics/adherence');
    expect(query['period'], 'ALL');
    expect(query.containsKey('date'), isFalse);
    expect(query.containsKey('from'), isFalse);
    expect(find.text('Dal 12/03/2026'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    // 3.2: *Tutto* si conserva come gli altri orizzonti.
    expect(pumped.preferences.values['statistics_period'], 'ALL');
  });

  /// 11.1: annullata la scelta delle date, l'orizzonte resta com'era.
  testWidgets('Intervallo apre il selettore di date, e annullato lascia il mese', (tester) async {
    final pumped = await _pump(tester, size: const Size(1000, 1000));

    await _choose(tester, 'Intervallo');
    expect(find.byType(DateRangePickerDialog), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(DateRangePickerDialog), findsNothing);
    expect(find.text('Mese'), findsOneWidget);
    expect(pumped.adapter.requests.where((request) => request.queryParameters['period'] == 'CUSTOM'), isEmpty);
  });

  /// AH-21: scelte le date, le richieste ne portano gli estremi; il
  /// navigatore le dichiara e, al tocco, riapre il selettore.
  testWidgets('su Intervallo chiede CUSTOM con gli estremi scelti', (tester) async {
    final pumped = await _pump(tester, size: const Size(1000, 1000));

    final container = _container(tester);
    container.read(selectedStatisticsRangeProvider.notifier).select(DateTime(2026, 3, 1), DateTime(2026, 3, 15));
    await container.read(selectedStatisticsPeriodProvider.notifier).select(StatisticsPeriod.custom);
    await tester.pumpAndSettle();

    final query = pumped.adapter.lastQueryOf('/statistics/adherence');
    expect(query['period'], 'CUSTOM');
    expect(query['from'], '2026-03-01');
    expect(query['to'], '2026-03-15');
    expect(query.containsKey('date'), isFalse);
    expect(find.byIcon(Icons.chevron_left), findsNothing);

    await tester.tap(find.text('Dal 01/03/2026 al 15/03/2026'));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePickerDialog), findsOneWidget);
  });

  /// AD-8quater, AD-8ter: le date dell'intervallo non si conservano, e
  /// alla riapertura si torna al mese; *Tutto* invece resta.
  testWidgets('alla riapertura Intervallo torna al mese', (tester) async {
    await _pump(tester, stored: {'statistics_period': 'CUSTOM'});

    expect(find.text('Mese'), findsOneWidget);
    expect(find.text('Intervallo'), findsNothing);
  });

  testWidgets('alla riapertura Tutto resta', (tester) async {
    final pumped = await _pump(tester, stored: {'statistics_period': 'ALL'});

    expect(find.text('Tutto'), findsOneWidget);
    expect(pumped.adapter.lastQueryOf('/statistics/adherence')['period'], 'ALL');
  });

  /// 11.1: oltre la larghezza disponibile il grafico scorre, e si apre
  /// sulle barre più recenti — all'estremo destro.
  testWidgets('l\'andamento lungo si apre sulle barre più recenti', (tester) async {
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WeeklyBarChart(
            bars: [
              for (var week = 0; week < 60; week++)
                BarDatum(label: 'S$week', value: week.toDouble(), valueLabel: '$week'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('S59').hitTestable(), findsOneWidget);
    expect(find.text('S0').hitTestable(), findsNothing);
  });
}
