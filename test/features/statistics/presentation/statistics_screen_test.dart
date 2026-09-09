import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/storage/preferences_store.dart';
import 'package:healthylog/features/measurement/providers/measurement_providers.dart';
import 'package:healthylog/features/statistics/presentation/statistics_screen.dart';
import 'package:healthylog/features/statistics/providers/statistics_providers.dart';

import '../../../support/l10n_test_support.dart';
import '../../../support/measurement_api_stub.dart';
import '../../../support/preferences_store_stub.dart';
import '../../../support/statistics_api_stub.dart';

/// *Statistiche* (11 interfaccia.md): i tre segmenti, il selettore del
/// periodo comune, e il **tono** della sezione — AD-4, AD-15, AD-16,
/// SA-6, SA-8, AN-11.

Future<void> _pumpStatistics(
  WidgetTester tester, {
  Map<String, dynamic>? adherence,
  Map<String, dynamic>? workouts,
  Map<String, dynamic>? measurements,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        statisticsApiProvider.overrideWithValue(stubStatisticsApi(
          adherence: adherence,
          workouts: workouts,
          measurements: measurements,
        )),
        measurementApiProvider.overrideWithValue(stubMeasurementApi()),
        preferencesStoreProvider.overrideWithValue(InMemoryPreferencesStore()),
      ],
      child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      theme: AppTheme.light, home: const StatisticsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Map<String, dynamic> _adherence({
  double? value,
  int suspendedDays = 0,
  int uncoveredDays = 0,
  List<Map<String, dynamic>> bySlotType = const [],
  List<Map<String, dynamic>>? weekly,
  List<Map<String, dynamic>> periods = const [],
}) =>
    {
      ...emptyAdherenceJson(),
      'value': value,
      'suspendedDays': suspendedDays,
      'uncoveredDays': uncoveredDays,
      'bySlotType': bySlotType,
      if (weekly != null) 'weekly': weekly,
      'periods': periods,
    };

void main() {
  testWidgets('presenta i tre segmenti nell\'intestazione (11.1)', (tester) async {
    await _pumpStatistics(tester);

    expect(find.text('Aderenza'), findsOneWidget);
    expect(find.text('Allenamenti'), findsOneWidget);
    expect(find.text('Corpo'), findsOneWidget);
  });

  /// Il selettore del periodo non è una seconda barra di comandi ma la
  /// didascalia stessa del valore, che apre il menu degli orizzonti.
  testWidgets('la didascalia del valore apre il menu del periodo (AD-8, AD-10)', (tester) async {
    await _pumpStatistics(tester, adherence: _adherence(value: 75));

    // Fuori dal menu i tre orizzonti non occupano una riga propria.
    expect(find.text('Mese'), findsNothing);
    expect(find.text('Piano'), findsNothing);

    await tester.tap(find.text('Settimana dal 2 marzo al 8 marzo'));
    await tester.pumpAndSettle();

    // AD-8: settimana, mese e intero piano; AD-10: nessun intervallo
    // personalizzato.
    expect(find.text('Settimana'), findsOneWidget);
    expect(find.text('Mese'), findsOneWidget);
    expect(find.text('Piano'), findsOneWidget);
  });

  /// AD-14: una barra sola non è un andamento — sull'orizzonte
  /// *Settimana* la sezione non compare.
  testWidgets('non presenta l\'andamento settimanale su una sola settimana (AD-14)',
      (tester) async {
    await _pumpStatistics(tester, adherence: _adherence(value: 75));

    expect(find.text('Andamento settimanale'), findsNothing);
  });

  testWidgets('presenta l\'andamento su più settimane (AD-14)', (tester) async {
    await _pumpStatistics(
      tester,
      adherence: _adherence(value: 75, weekly: [
        {'weekStart': '2026-03-02', 'value': 60.0},
        {'weekStart': '2026-03-09', 'value': 90.0},
      ]),
    );

    expect(find.text('Andamento settimanale'), findsOneWidget);
  });

  testWidgets('in assenza di dati valutabili constata, non presenta zero (AD-4)', (tester) async {
    await _pumpStatistics(tester);

    expect(find.text('Non ci sono ancora dati'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('arrotonda il solo risultato percentuale all\'intero più prossimo (AD-1ter)',
      (tester) async {
    // Il server restituisce il valore non arrotondato: l'arrotondamento è
    // della presentazione, e delle sole percentuali.
    await _pumpStatistics(tester, adherence: _adherence(value: 66.66666666666667));

    expect(find.text('67'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
  });

  testWidgets('dichiara i giorni esclusi dal calcolo (AD-12, AH-16)', (tester) async {
    await _pumpStatistics(
      tester,
      adherence: _adherence(value: 80, suspendedDays: 12, uncoveredDays: 3),
    );

    expect(
      find.text('Il calcolo esclude 12 giorni di sospensione e 3 giorni senza piano.'),
      findsOneWidget,
    );
  });

  testWidgets('disaggrega per tipo di pasto e per giorno della settimana (AD-13)', (tester) async {
    await _pumpStatistics(
      tester,
      adherence: _adherence(value: 75, bySlotType: [
        {'key': 'BREAKFAST', 'value': 90.0},
        {'key': 'DINNER', 'value': 50.0},
      ]),
    );

    expect(find.text('Colazione'), findsOneWidget);
    expect(find.text('Cena'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    // LO-11: sette giorni, dal lunedì alla domenica, anche senza dati.
    expect(find.text('Lunedì'), findsOneWidget);
    expect(find.text('Domenica'), findsOneWidget);
  });

  testWidgets('sul piano con più periodi consente di alternare complessivo e periodo (ST-10)',
      (tester) async {
    await _pumpStatistics(
      tester,
      adherence: _adherence(value: 70, periods: [
        {'startDate': '2026-01-01', 'endDate': '2026-01-31', 'value': 60.0},
        {'startDate': '2026-06-01', 'endDate': '2026-06-30', 'value': 84.0},
      ]),
    );

    expect(find.text('Complessivo'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);

    await tester.tap(find.text('2° periodo'));
    await tester.pumpAndSettle();

    expect(find.text('84'), findsOneWidget);
  });

  testWidgets('senza obiettivo non presenta il confronto né segnala la mancanza (SA-6)',
      (tester) async {
    await _pumpStatistics(tester, workouts: {
      ...emptyWorkoutStatisticsJson(),
      'total': 3,
      'byActivityType': [
        {'activityType': 'Corsa', 'count': 3},
      ],
    });

    await tester.tap(find.text('Allenamenti').last);
    await tester.pumpAndSettle();

    expect(find.text('3'), findsWidgets);
    expect(find.text('Confronto con l’obiettivo'), findsNothing);
    expect(find.textContaining('obiettivo non impostato'), findsNothing);
  });

  testWidgets('presenta i due confronti come distinti (SA-5)', (tester) async {
    await _pumpStatistics(tester, workouts: {
      ...emptyWorkoutStatisticsJson(),
      'total': 3,
      'goal': 4,
      'goalDone': 3,
      'goalWeeks': 1,
      'planned': 5,
      'plannedDone': 4,
    });

    await tester.tap(find.text('Allenamenti').last);
    await tester.pumpAndSettle();

    expect(find.text('3 su 4 previsti'), findsOneWidget);
    expect(find.text('5 pianificati, 4 svolti'), findsOneWidget);
  });

  testWidgets('non aggrega le calorie in alcuna forma (CB-9, SA-8)', (tester) async {
    await _pumpStatistics(tester, workouts: {
      ...emptyWorkoutStatisticsJson(),
      'total': 2,
      'byActivityType': [
        {'activityType': 'Corsa', 'count': 2},
      ],
    });

    await tester.tap(find.text('Allenamenti').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('kcal'), findsNothing);
    expect(find.textContaining('calorie'), findsNothing);
  });

  testWidgets('presenta la variazione col proprio segno e senza qualificazioni (AN-10, AN-11)',
      (tester) async {
    await _pumpStatistics(tester, measurements: {
      ...emptyMeasurementStatisticsJson(),
      'targetWeightKg': 72.0,
      'series': [
        {
          'measure': 'WEIGHT',
          'unit': 'kg',
          'points': [
            {'date': '2026-03-02', 'value': 80.0, 'source': 'USER'},
            {'date': '2026-03-06', 'value': 78.5, 'source': 'NUTRITIONIST'},
          ],
          'change': -1.5,
        },
      ],
    });

    await tester.tap(find.text('Corpo'));
    await tester.pumpAndSettle();

    expect(find.text('−1.5'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    // AN-11: nessuna denominazione di progresso o regresso.
    expect(find.textContaining('migliorament'), findsNothing);
    expect(find.textContaining('peggiorament'), findsNothing);
  });

  testWidgets('propone le sole misure con registrazioni nel periodo (AN-2)', (tester) async {
    await _pumpStatistics(tester, measurements: {
      ...emptyMeasurementStatisticsJson(),
      'series': [
        {
          'measure': 'WAIST',
          'unit': 'cm',
          'points': [
            {'date': '2026-03-02', 'value': 92.0, 'source': 'USER'},
          ],
          'change': null,
        },
      ],
    });

    await tester.tap(find.text('Corpo'));
    await tester.pumpAndSettle();

    expect(find.text('Vita'), findsOneWidget);
    expect(find.text('Peso'), findsNothing);
  });

  testWidgets('senza misurazioni nel periodo constata, senza grafici vuoti (AN-2)', (tester) async {
    await _pumpStatistics(tester);

    await tester.tap(find.text('Corpo'));
    await tester.pumpAndSettle();

    expect(find.text('Nessuna misurazione nel periodo'), findsOneWidget);
  });
}
