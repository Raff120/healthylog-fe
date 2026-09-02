import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';
import 'package:healthylog/features/dietplan/presentation/widgets/week_selector.dart';

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
    test('settimana interamente nello stesso mese', () {
      expect(weekRangeLabel(DateTime(2026, 9, 7)), '7 – 13 settembre 2026');
    });

    test('settimana a cavallo di due mesi dello stesso anno', () {
      expect(weekRangeLabel(DateTime(2026, 8, 31)), '31 agosto – 6 settembre 2026');
    });

    test('settimana a cavallo di due anni', () {
      expect(weekRangeLabel(DateTime(2026, 12, 28)), '28 dicembre 2026 – 3 gennaio 2027');
    });
  });
}
