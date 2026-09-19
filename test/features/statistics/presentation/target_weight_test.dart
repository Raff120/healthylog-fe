import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/api_error_interceptor.dart';
import 'package:healthylog/features/identity/data/profile_api.dart';
import 'package:healthylog/features/identity/providers/profile_providers.dart';
import 'package:healthylog/features/measurement/providers/measurement_providers.dart';
import 'package:healthylog/features/statistics/data/statistics_models.dart';
import 'package:healthylog/features/statistics/presentation/body_statistics_view.dart';

import '../../../support/l10n_test_support.dart';
import '../../../support/measurement_api_stub.dart';

/// Il peso obiettivo si imposta dal segmento *Corpo* di *Statistiche*
/// (PR-8, PR-10, AN-6, 11.3 interfaccia.md).
///
/// Stava fra i dati personali, dove non lo si trovava: segnalato
/// dall'utente, vedi decisioni.md.

MeasurementStatistics _statistics({
  double? targetWeightKg,
  List<Map<String, dynamic>> series = const [],
}) =>
    MeasurementStatistics.fromJson({
      'period': 'MONTH',
      'from': '2026-03-01',
      'to': '2026-03-31',
      'planId': null,
      'planName': null,
      'targetWeightKg': targetWeightKg,
      'series': series,
    });

Future<_ProfileAdapter> _pump(
  WidgetTester tester, {
  double? targetWeightKg,
  List<Map<String, dynamic>> series = const [],
}) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final adapter = _ProfileAdapter(targetWeightKg: targetWeightKg);
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ApiErrorInterceptor());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileApiProvider.overrideWithValue(ProfileApi(dio)),
        measurementApiProvider.overrideWithValue(stubMeasurementApi()),
      ],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: Scaffold(
          body: BodyStatisticsView(
            statistics: _statistics(targetWeightKg: targetWeightKg, series: series),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return adapter;
}

const _weightSeries = [
  {
    'measure': 'WEIGHT',
    'points': [
      {'date': '2026-03-02', 'value': 80.0, 'source': 'USER'},
      {'date': '2026-03-06', 'value': 78.5, 'source': 'USER'},
    ],
    'change': -1.5,
  },
];

void main() {
  testWidgets('presenta il peso obiettivo vigente accanto al grafico del peso (AN-6)',
      (tester) async {
    await _pump(tester, targetWeightKg: 72, series: _weightSeries);

    expect(find.text('Peso obiettivo 72 kg'), findsOneWidget);
    expect(find.text('Modifica'), findsOneWidget);
  });

  /// 4.4, RA-18: l'assenza è una constatazione, non una mancanza da
  /// rimediare — e AN-9 esclude ogni distanza residua.
  testWidgets('in sua assenza constata e non sollecita (4.4, AN-9)', (tester) async {
    await _pump(tester, series: _weightSeries);

    expect(find.text('Nessun peso obiettivo'), findsOneWidget);
    expect(find.text('Imposta'), findsOneWidget);
    expect(find.textContaining('mancano'), findsNothing);
    expect(find.textContaining('Dovresti'), findsNothing);
  });

  /// È allora che un traguardo si dà: senza misurazioni il comando
  /// resterebbe altrimenti irraggiungibile.
  testWidgets('resta raggiungibile anche senza alcuna misurazione', (tester) async {
    await _pump(tester);

    expect(find.text('Nessuna misurazione nel periodo'), findsOneWidget);
    expect(find.byKey(const Key('targetWeightButton')), findsOneWidget);
  });

  testWidgets('il foglio scrive il valore sul profilo (PR-8)', (tester) async {
    final adapter = await _pump(tester, series: _weightSeries);

    await tester.tap(find.byKey(const Key('targetWeightButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('targetWeightField')), '70,5');
    await tester.pump();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(adapter.updates.single['targetWeightKg'], 70.5);
    // Gli altri campi del profilo sono riferiti immutati: `PATCH /me`
    // porta il profilo per intero, e l'indirizzo che non muta non
    // innesca la verifica di AC-5.
    expect(adapter.updates.single['email'], 'utente@example.it');
    expect(adapter.updates.single['height'], 178);
  });

  /// PR-10: il valore si rimuove, e la rimozione è un'azione esplicita.
  testWidgets('il foglio rimuove il peso obiettivo (PR-10)', (tester) async {
    final adapter = await _pump(tester, targetWeightKg: 72, series: _weightSeries);

    await tester.tap(find.byKey(const Key('targetWeightButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('targetWeightRemove')));
    await tester.pumpAndSettle();

    expect(adapter.updates.single['targetWeightKg'], isNull);
  });

  /// La rimozione non è offerta dove non c'è nulla da rimuovere.
  testWidgets('senza obiettivo il foglio non offre la rimozione', (tester) async {
    await _pump(tester, series: _weightSeries);

    await tester.tap(find.byKey(const Key('targetWeightButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('targetWeightRemove')), findsNothing);
  });
}

class _ProfileAdapter implements HttpClientAdapter {
  _ProfileAdapter({this.targetWeightKg});

  double? targetWeightKg;
  final updates = <Map<String, dynamic>>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'PATCH' && options.path == '/me') {
      final body = Map<String, dynamic>.from(options.data as Map);
      updates.add(body);
      targetWeightKg = (body['targetWeightKg'] as num?)?.toDouble();
    }
    return ResponseBody.fromString(
      jsonEncode({
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
        'targetWeightKg': targetWeightKg,
        'timezone': 'Europe/Rome',
        'locale': 'IT',
        'unitSystem': 'METRIC',
        'privacyAcceptanceRequired': false,
        'deletionRequestedAt': null,
        'deletionEffectiveAt': null,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
