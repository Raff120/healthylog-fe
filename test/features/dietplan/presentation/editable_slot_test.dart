import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/data/weekday.dart';
import 'package:healthylog/features/dietplan/presentation/editable_slot.dart';

/// CD-15, GG-7: il segnale di incompletezza del giorno (l'unica
/// segnalazione ammessa, 7.3 interfaccia.md) verificato in isolamento,
/// senza montare alcuna schermata — la logica non dipende dal widget
/// tree.
void main() {
  group('EditableDay.hasIncompleteSlot', () {
    test('un giorno privo di slot non è incompleto (GG-7)', () {
      final day = EditableDay(dayOfWeek: Weekday.monday, slots: []);

      expect(day.hasIncompleteSlot, isFalse);
    });

    test('un giorno con tutti gli slot compilati non è incompleto', () {
      final day = EditableDay(dayOfWeek: Weekday.monday, slots: [
        EditableSlot(type: SlotType.breakfast, content: 'Yogurt', adherenceWeight: 1),
        EditableSlot(type: SlotType.lunch, content: 'Pasta', adherenceWeight: 1),
      ]);

      expect(day.hasIncompleteSlot, isFalse);
    });

    test('un solo slot privo di contenuto rende il giorno incompleto (CD-15)', () {
      final day = EditableDay(dayOfWeek: Weekday.monday, slots: [
        EditableSlot(type: SlotType.breakfast, content: 'Yogurt', adherenceWeight: 1),
        EditableSlot(type: SlotType.lunch, adherenceWeight: 1),
      ]);

      expect(day.hasIncompleteSlot, isTrue);
    });

    test('un contenuto di soli spazi conta come assente', () {
      final day = EditableDay(dayOfWeek: Weekday.monday, slots: [
        EditableSlot(type: SlotType.breakfast, content: '   ', adherenceWeight: 1),
      ]);

      expect(day.hasIncompleteSlot, isTrue);
    });
  });

  group('EditableDay.hasType', () {
    test('riconosce un tipo già presente nel giorno (GG-5)', () {
      final day = EditableDay(dayOfWeek: Weekday.monday, slots: [
        EditableSlot(type: SlotType.breakfast, adherenceWeight: 1),
      ]);

      expect(day.hasType(SlotType.breakfast), isTrue);
      expect(day.hasType(SlotType.dinner), isFalse);
    });
  });

  group('EditableSlot.toRequest', () {
    test('omette la denominazione per i tipi diversi da spuntino', () {
      final slot = EditableSlot(type: SlotType.breakfast, label: 'Colazione speciale', adherenceWeight: 1);

      expect(slot.toRequest().label, isNull);
    });

    test('conserva la denominazione per uno spuntino', () {
      final slot = EditableSlot(type: SlotType.snack, label: 'Spuntino serale', adherenceWeight: 0.5);

      expect(slot.toRequest().label, 'Spuntino serale');
    });

    test('i campi di testo vuoti diventano assenti nella richiesta (non stringa vuota)', () {
      final slot = EditableSlot(type: SlotType.lunch, content: '  ', adherenceWeight: 1);

      final request = slot.toRequest();

      expect(request.content, isNull);
    });
  });
}
