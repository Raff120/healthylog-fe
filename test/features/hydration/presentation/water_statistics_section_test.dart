import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_colors.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/features/hydration/presentation/widgets/water_statistics_section.dart';
import 'package:healthylog/features/hydration/providers/hydration_providers.dart';
import 'package:healthylog/features/statistics/data/statistics_models.dart';
import 'package:healthylog/features/statistics/providers/statistics_providers.dart';

import '../../../support/hydration_api_stub.dart';
import '../../../support/l10n_test_support.dart';

/// L'idratazione in coda al segmento *Aderenza* (11.1 interfaccia.md):
/// due cose sole — quanta acqua in ciascuna giornata e se l'obiettivo sia
/// stato raggiunto (AQ-25) — la distinzione di sola evidenza fra le barre
/// (AQ-23), e l'elenco da cui si rettifica (AQ-28).

Future<void> _pump(
  WidgetTester tester, {
  required List<Map<String, dynamic>> days,
  int? goalMl,
  String? userId,
}) async {
  tester.view.physicalSize = const Size(500, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hydrationApiProvider.overrideWithValue(stubHydrationApi(days: days, goalMl: goalMl)),
      ],
      child: MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: WaterStatisticsSection(
              query: StatisticsQuery(period: StatisticsPeriod.month, userId: userId),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<Color?> _barColours(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(find.byType(DecoratedBox))
    .map((box) => (box.decoration as BoxDecoration).color)
    .toList();

void main() {
  testWidgets('presenta le giornate e nessun valore aggregato (AQ-25)', (tester) async {
    await _pump(tester, days: [
      {'date': '2026-03-02', 'totalMl': 1800},
      {'date': '2026-03-03', 'totalMl': 2200},
    ], goalMl: 2000);

    expect(find.text('ACQUA'), findsOneWidget);
    // Nessuna media, nessun totale di periodo, nessuna proiezione.
    expect(find.textContaining('al giorno'), findsNothing);
    expect(find.textContaining('media'), findsNothing);
  });

  testWidgets('distingue per sola evidenza la giornata che raggiunge l\'obiettivo (AQ-23)',
      (tester) async {
    await _pump(tester, days: [
      {'date': '2026-03-02', 'totalMl': 1800},
      {'date': '2026-03-03', 'totalMl': 2200},
    ], goalMl: 2000);

    final colours = _barColours(tester);
    // Pieno dove l'obiettivo è raggiunto, attenuato dove non lo è: la
    // medesima tinta, mai un verde e mai un rosso.
    expect(colours, contains(AppColors.light.accent));
    expect(colours, contains(AppColors.light.accentMuted));
    expect(colours, isNot(contains(AppColors.light.confirm)));
    expect(colours, isNot(contains(AppColors.light.error)));
  });

  testWidgets('senza obiettivo nessuna giornata è in evidenza (AQ-11, AQ-26)', (tester) async {
    await _pump(tester, days: [
      {'date': '2026-03-02', 'totalMl': 1800},
      {'date': '2026-03-03', 'totalMl': 2200},
    ]);

    final colours = _barColours(tester);
    expect(colours, contains(AppColors.light.accentMuted));
    expect(colours, isNot(contains(AppColors.light.accent)));
  });

  testWidgets('l\'elenco delle aggiunte si apre e ne consente la rimozione (AQ-8, AQ-28)',
      (tester) async {
    await _pump(tester, days: [
      {
        'date': '2026-03-02',
        'totalMl': 650,
        'entries': [
          {'entryId': 'e1', 'amountMl': 150},
          {'entryId': 'e2', 'amountMl': 500},
        ],
      },
    ], goalMl: 2000);

    await tester.tap(find.byKey(const Key('waterEntriesButton')));
    await tester.pumpAndSettle();

    expect(find.text('Aggiunte del periodo'), findsOneWidget);
    expect(find.text('150 ml'), findsOneWidget);
    expect(find.text('500 ml'), findsOneWidget);
    // AQ-10: l'ora dell'aggiunta non compare.
    expect(find.textContaining(':'), findsNothing);
    expect(find.byTooltip('Rimuovi questa aggiunta'), findsNWidgets(2));
  });

  /// AQ-8, 4.5: la rimozione di un'aggiunta chiede conferma semplice —
  /// non si torna indietro dal tocco (segnalato dall'utente).
  testWidgets('la rimozione di un\'aggiunta chiede conferma (4.5)', (tester) async {
    await _pump(tester, days: [
      {
        'date': '2026-03-02',
        'totalMl': 650,
        'entries': [
          {'entryId': 'e1', 'amountMl': 150},
          {'entryId': 'e2', 'amountMl': 500},
        ],
      },
    ], goalMl: 2000);

    await tester.tap(find.byKey(const Key('waterEntriesButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Rimuovi questa aggiunta').first);
    await tester.pumpAndSettle();

    expect(find.text('Rimuovere 150 ml?'), findsOneWidget);

    // Chi rinuncia non ha rimosso nulla: l'aggiunta è ancora in elenco.
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(find.text('150 ml'), findsOneWidget);
  });

  testWidgets('il Nutrizionista non dispone dell\'elenco (AQ-28bis)', (tester) async {
    await _pump(
      tester,
      days: [
        {'date': '2026-03-02', 'totalMl': 1800},
      ],
      goalMl: 2000,
      userId: 'patient-1',
    );

    expect(find.byKey(const Key('waterEntriesButton')), findsNothing);
  });
}
