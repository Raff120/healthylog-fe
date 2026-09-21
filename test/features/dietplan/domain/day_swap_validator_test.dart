import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/dietplan/data/plan_status.dart';
import 'package:healthylog/features/dietplan/data/slot_status.dart';
import 'package:healthylog/features/dietplan/domain/meal_swap_validator.dart';

/// IN-28..IN-31, MS-24: replica di DaySwapValidatorTest sul backend
/// (MS-23) — stessi casi, stessi dati, stessi esiti attesi.
void main() {
  // Lunedì 7 settembre 2026, "oggi" dei casi: identico al backend.
  final monday = DateTime(2026, 9, 7);
  final tuesday = monday.add(const Duration(days: 1));
  final wednesday = monday.add(const Duration(days: 2));
  final sunday = monday.add(const Duration(days: 6));
  final nextMonday = monday.add(const Duration(days: 7));
  const toConsume = SlotStatus.toConsume;

  DaySwapCandidate day(DateTime date, [List<SlotStatus> statuses = const []]) =>
      DaySwapCandidate(date: date, statuses: statuses);

  String? validate(PlanStatus status, DaySwapCandidate first, DaySwapCandidate second, DateTime today) =>
      validateDaySwap(planStatus: status, first: first, second: second, today: today);

  group('ammissibilità (IN-28..IN-31)', () {
    test('ammette due giornate della stessa settimana tutte da consumare', () {
      expect(validate(PlanStatus.active, day(monday, [toConsume, toConsume]), day(wednesday, [toConsume]), monday),
          isNull);
    });

    test('ammette composizioni diverse', () {
      expect(
          validate(PlanStatus.active, day(tuesday, [toConsume, toConsume, toConsume, toConsume]),
              day(sunday, [toConsume]), monday),
          isNull);
    });

    test('ammette una giornata priva di slot', () {
      expect(validate(PlanStatus.active, day(monday), day(sunday, [toConsume]), monday), isNull);
    });

    test('rifiuta un piano non attivo', () {
      expect(validate(PlanStatus.suspended, day(monday), day(wednesday), monday), 'PLAN_NOT_ACTIVE');
    });

    test('rifiuta una giornata trascorsa', () {
      expect(validate(PlanStatus.active, day(monday), day(wednesday), tuesday), 'SWAP_PAST_DAY');
    });

    test('rifiuta la medesima giornata', () {
      expect(validate(PlanStatus.active, day(wednesday), day(wednesday), monday), 'SWAP_SAME_DAY');
    });

    test('rifiuta uno slot consumato', () {
      expect(
          validate(PlanStatus.active, day(monday, [toConsume]), day(wednesday, [toConsume, SlotStatus.consumed]),
              monday),
          'SLOT_ALREADY_CONSUMED');
    });

    test('rifiuta uno slot saltato (IN-30)', () {
      expect(validate(PlanStatus.active, day(monday, [SlotStatus.skipped]), day(wednesday, [toConsume]), monday),
          'SLOT_ALREADY_SKIPPED');
    });

    test('rifiuta settimane diverse', () {
      expect(validate(PlanStatus.active, day(sunday), day(nextMonday), monday), 'SWAP_DIFFERENT_WEEKS');
    });
  });

  group('ordine di valutazione (MS-24)', () {
    test('il piano non attivo precede la giornata trascorsa', () {
      expect(validate(PlanStatus.completed, day(monday), day(wednesday), tuesday), 'PLAN_NOT_ACTIVE');
    });

    test('la giornata trascorsa precede la medesima giornata', () {
      expect(validate(PlanStatus.active, day(monday), day(monday), tuesday), 'SWAP_PAST_DAY');
    });

    test('la medesima giornata precede lo slot consumato', () {
      expect(validate(PlanStatus.active, day(monday, [SlotStatus.consumed]), day(monday, [SlotStatus.consumed]), monday),
          'SWAP_SAME_DAY');
    });

    test('il consumato precede il saltato', () {
      expect(
          validate(PlanStatus.active, day(monday, [SlotStatus.skipped]), day(wednesday, [SlotStatus.consumed]), monday),
          'SLOT_ALREADY_CONSUMED');
    });

    test('il saltato precede le settimane diverse', () {
      expect(validate(PlanStatus.active, day(sunday, [SlotStatus.skipped]), day(nextMonday), monday),
          'SLOT_ALREADY_SKIPPED');
    });
  });
}
