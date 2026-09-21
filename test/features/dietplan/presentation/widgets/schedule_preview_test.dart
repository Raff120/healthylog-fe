import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/features/dietplan/data/diet_plan.dart';
import 'package:healthylog/features/dietplan/data/weekday.dart';
import 'package:healthylog/features/dietplan/presentation/widgets/day_preview.dart';

import '../../../../support/l10n_test_support.dart';

/// TP-1, 7.4 interfaccia.md: l'anteprima dello schema raggruppa i giorni
/// per settimana solo quando ve n'è più d'una.
void main() {
  Future<void> pump(WidgetTester tester, List<DietPlanWeekDay> days) => tester.pumpWidget(MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        theme: AppTheme.light,
        home: Scaffold(body: SingleChildScrollView(child: SchedulePreview(days: days))),
      ));

  List<DietPlanWeekDay> week(int week) => [
        for (final dayOfWeek in Weekday.values) DietPlanWeekDay(week: week, dayOfWeek: dayOfWeek, slots: const []),
      ];

  testWidgets('con una settimana sola non compare alcuna intestazione di settimana', (tester) async {
    await pump(tester, week(1));

    expect(find.textContaining('SETTIMANA'), findsNothing);
    expect(find.text('Lunedì'), findsOneWidget);
  });

  testWidgets('con più settimane ciascuna ha la propria intestazione, e i giorni la seguono', (tester) async {
    await pump(tester, [...week(1), ...week(2)]);

    expect(find.text('SETTIMANA 1'), findsOneWidget);
    expect(find.text('SETTIMANA 2'), findsOneWidget);
    expect(find.text('Lunedì'), findsNWidgets(2));
    expect(tester.getTopLeft(find.text('SETTIMANA 2')).dy,
        greaterThan(tester.getTopLeft(find.text('Domenica').first).dy));
  });
}
