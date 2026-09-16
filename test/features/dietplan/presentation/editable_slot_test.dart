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
        EditableSlot(type: SlotType.breakfast, items: [EditableItem(name: 'Yogurt')], adherenceWeight: 1),
        EditableSlot(type: SlotType.lunch, items: [EditableItem(name: 'Pasta')], adherenceWeight: 1),
      ]);

      expect(day.hasIncompleteSlot, isFalse);
    });

    test('un solo slot privo di elementi rende il giorno incompleto (CD-15)', () {
      final day = EditableDay(dayOfWeek: Weekday.monday, slots: [
        EditableSlot(type: SlotType.breakfast, items: [EditableItem(name: 'Yogurt')], adherenceWeight: 1),
        EditableSlot(type: SlotType.lunch, adherenceWeight: 1),
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
      final slot = EditableSlot(type: SlotType.lunch, note: '  ', adherenceWeight: 1);

      final request = slot.toRequest();

      expect(request.note, isNull);
      expect(request.items, isEmpty);
    });

    /// CD-8, GG-21: gli elementi passano nell'ordine in cui sono redatti, e la
    /// ricetta porta il proprio testo mentre l'alimento porta la quantità.
    test('gli elementi transitano nella richiesta con quantità, alternative e ordine', () {
      final slot = EditableSlot(
        type: SlotType.breakfast,
        adherenceWeight: 1,
        items: [
          EditableItem(
            name: 'Tisana',
            quantity: 250,
            unitCode: 'MILLILITER',
            alternatives: [EditableAlternative(name: 'Latte di soia', quantity: 200, unitCode: 'MILLILITER')],
          ),
          EditableItem(kindCode: 'RECIPE', name: 'Porridge', recipeText: "Cuocere l'avena"),
        ],
      );

      final items = slot.toRequest().items;

      expect(items.map((item) => item.name), ['Tisana', 'Porridge']);
      expect(items.first.quantity, 250);
      expect(items.first.unitCode, 'MILLILITER');
      expect(items.first.alternatives.single.name, 'Latte di soia');
      // GG-12: la ricetta non ha quantità, l'alimento non ha testo di ricetta.
      expect(items.last.quantity, isNull);
      expect(items.last.recipeText, "Cuocere l'avena");
      expect(items.first.recipeText, isNull);
    });
  });
}
