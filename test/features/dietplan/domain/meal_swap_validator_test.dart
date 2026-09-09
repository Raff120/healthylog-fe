import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/dietplan/data/plan_status.dart';
import 'package:healthylog/features/dietplan/data/slot_status.dart';
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/domain/meal_swap_validator.dart';

/// 6.4 funzionale, 7.1 tecnica: replica di MealSwapValidatorTest sul
/// backend (MS-23, CC-6) — stessi casi, stessi dati, stessi esiti attesi.
void main() {
  // Lunedì 7 settembre 2026: identico riferimento del lato backend.
  final monday = DateTime(2026, 9, 7);
  final tuesday = monday.add(const Duration(days: 1));
  final wednesday = monday.add(const Duration(days: 2));
  final sunday = monday.add(const Duration(days: 6));
  final nextMonday = monday.add(const Duration(days: 7));

  MealSwapCandidate candidate(DateTime date, SlotType type, {SlotStatus status = SlotStatus.toConsume}) =>
      MealSwapCandidate(date: date, type: type, status: status);

  String? validate(MealSwapCandidate first, MealSwapCandidate second, {DateTime? today, PlanStatus? planStatus}) =>
      validateMealSwap(
        planStatus: planStatus ?? PlanStatus.active,
        first: first,
        second: second,
        today: today ?? monday,
      );

  group('matrice di ammissibilità (IN-4)', () {
    test('ammette pranzo contro cena nello stesso giorno', () {
      expect(validate(candidate(monday, SlotType.lunch), candidate(monday, SlotType.dinner)), isNull);
    });

    test('ammette pranzo contro pranzo in giorni diversi della stessa settimana', () {
      expect(validate(candidate(monday, SlotType.lunch), candidate(wednesday, SlotType.lunch)), isNull);
    });

    test('ammette cena contro cena in giorni diversi della stessa settimana', () {
      expect(validate(candidate(monday, SlotType.dinner), candidate(wednesday, SlotType.dinner)), isNull);
    });

    test('ammette colazione contro colazione in giorni diversi della stessa settimana', () {
      expect(validate(candidate(monday, SlotType.breakfast), candidate(wednesday, SlotType.breakfast)), isNull);
    });

    test('ammette spuntino contro spuntino nello stesso giorno', () {
      expect(validate(candidate(monday, SlotType.snack), candidate(monday, SlotType.snack)), isNull);
    });

    test('rifiuta pranzo contro cena in giorni diversi', () {
      expect(
        validate(candidate(monday, SlotType.lunch), candidate(tuesday, SlotType.dinner)),
        'SWAP_DIFFERENT_DAYS',
      );
    });

    test('rifiuta colazione contro pranzo', () {
      expect(
        validate(candidate(monday, SlotType.breakfast), candidate(monday, SlotType.lunch)),
        'SWAP_TYPE_NOT_ALLOWED',
      );
    });

    test('rifiuta colazione contro cena', () {
      expect(
        validate(candidate(monday, SlotType.breakfast), candidate(monday, SlotType.dinner)),
        'SWAP_TYPE_NOT_ALLOWED',
      );
    });

    test('rifiuta colazione contro spuntino', () {
      expect(
        validate(candidate(monday, SlotType.breakfast), candidate(monday, SlotType.snack)),
        'SWAP_TYPE_NOT_ALLOWED',
      );
    });

    test('rifiuta spuntino contro pranzo', () {
      expect(
        validate(candidate(monday, SlotType.snack), candidate(monday, SlotType.lunch)),
        'SWAP_TYPE_NOT_ALLOWED',
      );
    });

    test('rifiuta spuntino contro cena', () {
      expect(
        validate(candidate(monday, SlotType.snack), candidate(monday, SlotType.dinner)),
        'SWAP_TYPE_NOT_ALLOWED',
      );
    });

    test('rifiuta spuntino contro spuntino in giorni diversi', () {
      expect(
        validate(candidate(monday, SlotType.snack), candidate(tuesday, SlotType.snack)),
        'SWAP_DIFFERENT_DAYS',
      );
    });

    test('rifiuta tra domenica e il lunedì successivo (IN-9, LO-11)', () {
      expect(
        validate(candidate(sunday, SlotType.lunch), candidate(nextMonday, SlotType.lunch)),
        'SWAP_DIFFERENT_WEEKS',
      );
    });
  });

  group('ordine di valutazione (MS-8, MS-9)', () {
    test('una giornata trascorsa prevale sui tipi incompatibili', () {
      final ieri = monday.subtract(const Duration(days: 1));
      expect(
        validate(candidate(ieri, SlotType.breakfast), candidate(monday, SlotType.lunch), today: monday),
        'SWAP_PAST_DAY',
      );
    });

    test('il piano non attivo prevale su ogni altra condizione', () {
      expect(
        validate(
          candidate(monday.subtract(const Duration(days: 1)), SlotType.breakfast, status: SlotStatus.consumed),
          candidate(nextMonday, SlotType.lunch, status: SlotStatus.consumed),
          planStatus: PlanStatus.suspended,
        ),
        'PLAN_NOT_ACTIVE',
      );
    });

    test('uno slot già consumato prevale sui tipi incompatibili', () {
      expect(
        validate(
          candidate(monday, SlotType.breakfast, status: SlotStatus.consumed),
          candidate(monday, SlotType.lunch),
        ),
        'SLOT_ALREADY_CONSUMED',
      );
    });
  });

  group('invertibilità secondo lo stato (IN-11..14)', () {
    test('ammette l\'inversione tra due slot saltati', () {
      expect(
        validate(
          candidate(monday, SlotType.lunch, status: SlotStatus.skipped),
          candidate(wednesday, SlotType.lunch, status: SlotStatus.skipped),
        ),
        isNull,
      );
    });
  });
}
