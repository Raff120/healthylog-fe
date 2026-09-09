import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/widgets/week_selector.dart';

import '../../../support/l10n_test_support.dart';

/// LO-11: il primo giorno della settimana è sempre il lunedì, non
/// configurabile — la vista settimanale (6.2, VS-2) e le inversioni
/// (IN-8) ne dipendono.
void main() {
  group('startOfWeek', () {
    test('un lunedì è l\'inizio della propria settimana', () {
      final monday = DateTime(2026, 9, 7);
      expect(startOfWeek(monday), DateTime(2026, 9, 7));
    });

    test('una domenica appartiene alla settimana del lunedì precedente', () {
      final sunday = DateTime(2026, 9, 13);
      expect(startOfWeek(sunday), DateTime(2026, 9, 7));
    });

    test('un giorno feriale qualunque torna al lunedì della propria settimana', () {
      final wednesday = DateTime(2026, 9, 9);
      expect(startOfWeek(wednesday), DateTime(2026, 9, 7));
    });

    test('attraversa correttamente un confine di mese', () {
      // Martedì 1 settembre 2026: la settimana inizia lunedì 31 agosto.
      final tuesday = DateTime(2026, 9, 1);
      expect(startOfWeek(tuesday), DateTime(2026, 8, 31));
    });

    test('attraversa correttamente un confine d\'anno', () {
      // Venerdì 1 gennaio 2027: la settimana inizia lunedì 28 dicembre 2026.
      final friday = DateTime(2027, 1, 1);
      expect(startOfWeek(friday), DateTime(2026, 12, 28));
    });

    test('ignora la componente oraria', () {
      final withTime = DateTime(2026, 9, 9, 23, 45);
      expect(startOfWeek(withTime), DateTime(2026, 9, 7));
    });
  });

  group('weekRangeLabel', () {
    // VS-2, LO-9: la composizione degli estremi, nel formato della lingua
    // selezionata — qui l'italiano.
    testWidgets('settimana interamente nello stesso mese', (tester) async {
      expect(await _label(tester, DateTime(2026, 9, 7)), '7 – 13 settembre 2026');
    });

    testWidgets('settimana a cavallo di due mesi dello stesso anno', (tester) async {
      expect(await _label(tester, DateTime(2026, 8, 31)), '31 ago – 6 set 2026');
    });

    testWidgets('settimana a cavallo di due anni', (tester) async {
      expect(await _label(tester, DateTime(2026, 12, 28)), '28 dic 2026 – 3 gen 2027');
    });
  });
}

Future<String> _label(WidgetTester tester, DateTime weekStart) async {
  late String label;
  await tester.pumpWidget(
    MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      home: Builder(
        builder: (context) {
          label = weekRangeLabel(context, weekStart);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return label;
}
