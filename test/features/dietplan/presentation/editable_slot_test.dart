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

  /// CD-8bis: la copia del contenuto di uno slot in un altro, verificata
  /// sul solo modello di redazione.
  group('EditableSlot.replaceContentWith', () {
    EditableSlot source({SlotType type = SlotType.snack, String label = 'Metà mattina'}) => EditableSlot(
          slotId: 'source',
          type: type,
          label: label,
          note: 'Senza zucchero',
          adherenceWeight: 0.3,
          items: [
            EditableItem(
              itemId: 'item-1',
              name: 'Yogurt greco',
              quantity: 150,
              unitCode: 'GRAM',
              alternatives: [EditableAlternative(name: 'Kefir', quantity: 200, unitCode: 'MILLILITER')],
            ),
            EditableItem(itemId: 'item-2', kindCode: 'RECIPE', name: 'Porridge', recipeText: "Cuocere l'avena"),
          ],
        );

    test('sostituisce elementi, alternative, ricette, nota e peso, senza identificativi degli elementi', () {
      final target = EditableSlot(
        slotId: 'target',
        type: SlotType.snack,
        label: 'Merenda',
        note: 'Vecchia nota',
        adherenceWeight: 0.5,
        items: [EditableItem(itemId: 'old', name: 'Mela')],
      );

      target.replaceContentWith(source());

      final request = target.toRequest();
      expect(request.slotId, 'target');
      expect(request.type, SlotType.snack);
      expect(request.label, 'Metà mattina');
      expect(request.note, 'Senza zucchero');
      expect(request.adherenceWeight, 0.3);
      expect(request.items.map((item) => item.name), ['Yogurt greco', 'Porridge']);
      expect(request.items.every((item) => item.itemId == null), isTrue);
      expect(request.items.first.quantity, 150);
      expect(request.items.first.unitCode, 'GRAM');
      expect(request.items.first.alternatives.single.name, 'Kefir');
      expect(request.items.last.recipeText, "Cuocere l'avena");
    });

    test('copia anche quanto non è ancora salvato, e la copia resta indipendente', () {
      final origin = source();
      origin.items.first.nameController.text = 'Yogurt bianco';
      final target = EditableSlot(type: SlotType.lunch, adherenceWeight: 1);

      target.replaceContentWith(origin);
      origin.items.first.nameController.text = 'Skyr';
      origin.noteController.text = 'Altra nota';

      expect(target.items.first.nameController.text, 'Yogurt bianco');
      expect(target.noteController.text, 'Senza zucchero');
    });

    test("l'etichetta si copia solo fra spuntini (GG-10)", () {
      final snack = EditableSlot(type: SlotType.snack, label: 'Merenda', adherenceWeight: 0.5);
      snack.replaceContentWith(source(type: SlotType.breakfast, label: ''));
      expect(snack.labelController.text, 'Merenda');

      final lunch = EditableSlot(type: SlotType.lunch, adherenceWeight: 1);
      lunch.replaceContentWith(source());
      expect(lunch.toRequest().label, isNull);
      expect(lunch.type, SlotType.lunch);
    });

    test('nella modifica della singola giornata il peso non si copia (MD-8)', () {
      final target = EditableSlot(type: SlotType.snack, adherenceWeight: 0.5);

      target.replaceContentWith(source(), includeAdherenceWeight: false);

      expect(target.adherenceWeight, 0.5);
      expect(target.items, hasLength(2));
    });
  });
}
