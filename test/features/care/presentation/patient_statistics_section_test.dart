import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/features/care/presentation/widgets/patient_statistics_section.dart';
import 'package:healthylog/features/statistics/providers/statistics_providers.dart';

import '../../../support/l10n_test_support.dart';
import '../../../support/statistics_api_stub.dart';

/// 9.2 interfaccia.md, VA-7: le statistiche del Paziente nel dettaglio del
/// Nutrizionista, circoscritte ai periodi coperti dai propri piani
/// (ST-16bis, CS-6).

Future<void> _pumpSection(
  WidgetTester tester, {
  Map<String, dynamic>? adherence,
  Map<String, dynamic>? workouts,
  Map<String, dynamic>? measurements,
}) async {
  tester.view.physicalSize = const Size(500, 1200);
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
      ],
      child: MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: PatientStatisticsSection(patientId: 'p-1')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  /// CS-13, 9.2: fuori dal periodo di titolarità i dati non sono
  /// restituiti e non si distinguono dall'assenza di dati. La nota non ne
  /// spiega la ragione, che attiene a piani che il Nutrizionista non deve
  /// conoscere.
  testWidgets('fuori dai periodi di titolarità constata senza spiegare (ST-16bis, CS-13)',
      (tester) async {
    await _pumpSection(tester);

    expect(find.text('Dati non disponibili per questo periodo'), findsWidgets);
    // Nulla rivela l'esistenza di piani altrui.
    expect(find.textContaining('altro nutrizionista'), findsNothing);
    expect(find.textContaining('non redatto'), findsNothing);
  });

  testWidgets('presenta aderenza, allenamenti e andamento delle misure (VA-7)', (tester) async {
    await _pumpSection(
      tester,
      adherence: {
        ...emptyAdherenceJson(),
        'period': 'MONTH',
        'value': 81.0,
        'bySlotType': [
          {'key': 'LUNCH', 'value': 75.0},
        ],
      },
      workouts: {
        ...emptyWorkoutStatisticsJson(),
        'period': 'MONTH',
        'total': 6,
        'goal': 8,
        'goalDone': 6,
        'goalWeeks': 2,
      },
      measurements: {
        ...emptyMeasurementStatisticsJson(),
        'period': 'MONTH',
        'series': [
          {
            'measure': 'WEIGHT',
            'unit': 'kg',
            'points': [
              {'date': '2026-03-02', 'value': 80.0, 'source': 'USER'},
              {'date': '2026-03-20', 'value': 78.0, 'source': 'NUTRITIONIST'},
            ],
            'change': -2.0,
          },
        ],
      },
    );

    expect(find.text('81'), findsOneWidget);
    expect(find.text('Pranzo'), findsOneWidget);
    expect(find.text('6 allenamenti svolti'), findsOneWidget);
    // OS-7: l'obiettivo settimanale del Paziente, in sola consultazione.
    expect(find.text('6 su 8 previsti dall’obiettivo settimanale'), findsOneWidget);
    // AN-10, AN-11: variazione col proprio segno, senza qualificazioni.
    expect(find.text('Peso: −2.0 kg'), findsOneWidget);
    expect(find.textContaining('migliorament'), findsNothing);
  });
}
