import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/dietplan/data/diet_plan.dart';
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/data/weekday.dart';
import 'package:healthylog/features/dietplan/presentation/editable_slot.dart';
import 'package:healthylog/features/dietplan/presentation/editable_weeks.dart';

/// PA-2bis, OG-1bis, 7.3 interfaccia.md: le settimane dello schema in
/// redazione, verificate senza montare alcuna schermata.
void main() {
  List<EditableDay> week(int week, {String? slotId, String name = 'Yogurt'}) => [
        for (final dayOfWeek in Weekday.values)
          EditableDay(week: week, dayOfWeek: dayOfWeek, slots: [
            EditableSlot(
              slotId: slotId == null ? null : '$slotId-${dayOfWeek.name}',
              type: SlotType.breakfast,
              label: '',
              note: 'Nota',
              items: [EditableItem(itemId: 'item-$week-${dayOfWeek.name}', name: name)],
              adherenceWeight: 0.7,
            ),
          ]),
      ];

  test('il numero di settimane è quello dei giorni, e ne limita aggiunta e rimozione', () {
    final one = week(1);
    expect(one.weekCount, 1);
    expect(one.canAddWeek, isTrue);
    expect(one.canRemoveWeek, isFalse);

    final four = [...week(1), ...week(2), ...week(3), ...week(4)];
    expect(four.weekCount, 4);
    expect(four.canAddWeek, isFalse);
    expect(four.canRemoveWeek, isTrue);
  });

  test('la settimana aggiunta copia il contenuto, anche non salvato, senza identificativi', () {
    final days = [...week(1, slotId: 's1'), ...week(2, slotId: 's2', name: 'Farro')];

    final added = days.appendCopyOfWeek(2);

    expect(added, 3);
    final copied = days.daysOfWeek(3);
    expect(copied, hasLength(7));
    expect(copied.map((day) => day.dayOfWeek), Weekday.values);
    final slot = copied.first.slots.single;
    expect(slot.slotId, isNull);
    expect(slot.noteController.text, 'Nota');
    expect(slot.adherenceWeight, 0.7);
    expect(slot.items.single.itemId, isNull);
    expect(slot.items.single.nameController.text, 'Farro');
    // La copia è indipendente: scrivere nell'una non tocca l'altra.
    slot.items.single.nameController.text = 'Orzo';
    expect(days.daysOfWeek(2).first.slots.single.items.single.nameController.text, 'Farro');
  });

  test('la rimozione fa scalare le settimane successive, che restano contigue', () {
    final days = [...week(1, slotId: 's1'), ...week(2, slotId: 's2'), ...week(3, slotId: 's3')];

    days.removeWeek(2);

    expect(days.weekCount, 2);
    expect(days, hasLength(14));
    expect(days.daysOfWeek(2).first.slots.single.slotId, 's3-monday');
    expect(days.daysOfWeek(1).first.slots.single.slotId, 's1-monday');
  });

  test('la settimana incompleta è riconosciuta come i giorni (CD-15)', () {
    final days = [...week(1), ...week(2)];
    days.daysOfWeek(2)[3].slots.add(EditableSlot(type: SlotType.lunch, adherenceWeight: 1));

    expect(days.weekHasIncompleteSlot(1), isFalse);
    expect(days.weekHasIncompleteSlot(2), isTrue);
  });

  group('lettura e scrittura della settimana (OG-1bis)', () {
    test('il giorno privo di settimana, com\'era prima dei piani su più settimane, è della prima', () {
      final day = DietPlanWeekDay.fromJson({'dayOfWeek': 'MONDAY', 'slots': []});

      expect(day.week, 1);
      expect(weekCountOf([day]), 1);
    });

    test('la settimana letta si conserva fino alla richiesta, che la reca sempre', () {
      final day = DietPlanWeekDay.fromJson({'week': 3, 'dayOfWeek': 'FRIDAY', 'slots': []});

      expect(day.week, 3);
      expect(EditableDay.fromWeekDay(day).toRequest().toJson()['week'], 3);
      expect(EditableDay(dayOfWeek: Weekday.monday, slots: []).toRequest().toJson()['week'], 1);
    });
  });
}
