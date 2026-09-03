/// Motore delle inversioni (6.4 funzionale, 7.1 tecnica): replica di
/// `MealSwapValidator` sul backend (MS-1, MS-3, FE-7). Stesse regole,
/// stesso ordine di valutazione (MS-8, MS-9): ogni modifica DEVE toccare
/// entrambe le attuazioni nel medesimo intervento (MS-22).
library;

import '../data/plan_status.dart';
import '../data/slot_status.dart';
import '../data/slot_type.dart';
import 'plan_day_date.dart';

/// Uno slot coinvolto nello scambio, con quanto serve alla valutazione
/// (MS-2). `date` deve essere normalizzata ([dateOnly]).
class MealSwapCandidate {
  const MealSwapCandidate({
    required this.date,
    required this.type,
    required this.status,
  });

  final DateTime date;
  final SlotType type;
  final SlotStatus status;
}

/// MS-8: valuta le condizioni nell'ordine indicato, arrestandosi al primo
/// rifiuto (MS-9). Restituisce il codice di rifiuto (ER-15), `null` se
/// l'inversione è ammessa. `today` deve essere normalizzata ([dateOnly]).
///
/// Non verifica che i due slot appartengano al medesimo piano e Utente
/// (condizione 2 di MS-8, `RESOURCE_NOT_FOUND`): sul client la coppia
/// selezionabile appartiene già, per costruzione, alla settimana
/// scaricata di un solo piano (MS-20) — come sul backend è compito del
/// chiamante, non del validatore (MS-1).
String? validateMealSwap({
  required PlanStatus planStatus,
  required MealSwapCandidate first,
  required MealSwapCandidate second,
  required DateTime today,
}) {
  if (planStatus != PlanStatus.active) {
    return 'PLAN_NOT_ACTIVE';
  }
  if (first.date.isBefore(today) || second.date.isBefore(today)) {
    return 'SWAP_PAST_DAY';
  }
  if (first.status == SlotStatus.consumed || second.status == SlotStatus.consumed) {
    return 'SLOT_ALREADY_CONSUMED';
  }
  if (!_typesCompatible(first.type, second.type)) {
    return 'SWAP_TYPE_NOT_ALLOWED';
  }
  if (_requiresSameDay(first.type, second.type)) {
    if (first.date != second.date) {
      return 'SWAP_DIFFERENT_DAYS';
    }
  } else if (startOfWeek(first.date) != startOfWeek(second.date)) {
    return 'SWAP_DIFFERENT_WEEKS';
  }
  return null;
}

/// MS-10: pranzo e cena sono compatibili tra loro e ciascuno con il
/// proprio omologo; la colazione unicamente con la colazione; lo
/// spuntino unicamente con lo spuntino (IN-4, IN-5, IN-6).
bool _typesCompatible(SlotType first, SlotType second) {
  if (first == second) return true;
  return (first == SlotType.lunch && second == SlotType.dinner) ||
      (first == SlotType.dinner && second == SlotType.lunch);
}

/// MS-11: pranzo/cena e spuntino/spuntino richiedono la medesima
/// giornata; i tipi omologhi restanti richiedono la medesima settimana.
/// Raggiunta solo dopo [_typesCompatible], quindi la sola coppia di tipi
/// diversi possibile qui è pranzo/cena.
bool _requiresSameDay(SlotType first, SlotType second) {
  return first != second || first == SlotType.snack;
}
