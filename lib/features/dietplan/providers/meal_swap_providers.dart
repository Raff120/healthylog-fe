import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/meal_swap_api.dart';
import '../data/plan_day.dart';
import '../data/plan_day_coverage.dart';
import '../data/plan_status.dart';
import '../data/slot_status.dart';
import '../data/slot_type.dart';
import '../domain/meal_swap_validator.dart';
import '../domain/plan_day_date.dart';
import 'plan_day_providers.dart';

part 'meal_swap_providers.g.dart';

@riverpod
MealSwapApi mealSwapApi(Ref ref) => MealSwapApi(ref.watch(apiClientProvider));

/// Lo slot scelto come origine dell'inversione (VS-9): il piano a cui
/// appartiene (necessario a comporre `POST .../swaps`) insieme a quanto
/// serve alla valutazione locale di ammissibilità (MS-2).
class MealSwapOrigin {
  const MealSwapOrigin({
    required this.planId,
    required this.date,
    required this.slotId,
    required this.type,
    required this.status,
  });

  final String planId;
  final DateTime date;
  final String slotId;
  final SlotType type;
  final SlotStatus status;

  MealSwapCandidate get _candidate =>
      MealSwapCandidate(date: date, type: type, status: status);
}

/// MS-8, condizioni 1/3/4, applicate a un solo slot: sono simmetriche fra
/// origine e destinazione, quindi uno slot che già le viola non origina
/// alcuna inversione ammessa, quale che sia la destinazione scelta —
/// evita di avviare una selezione (6.5 interfaccia.md) che non potrebbe
/// mai concludersi.
bool isMealSwapOriginEligible(PlanDay day, PlanDaySlot slot) {
  if (day.coverage != PlanDayCoverage.active) return false;
  if (slot.status == SlotStatus.consumed) return false;
  if (day.date.isBefore(dateOnly(DateTime.now()))) return false;
  return true;
}

/// IN-20, MS-19: esito dell'evidenziazione di uno slot durante la
/// selezione (6.5 interfaccia.md), determinato localmente (MS-18).
enum MealSwapHighlight { origin, compatible, incompatible }

MealSwapHighlight mealSwapHighlightFor(
  MealSwapOrigin origin,
  PlanDay day,
  PlanDaySlot slot,
) {
  if (day.date == origin.date && slot.slotId == origin.slotId) {
    return MealSwapHighlight.origin;
  }
  return mealSwapRejectionReason(origin, day, slot) == null
      ? MealSwapHighlight.compatible
      : MealSwapHighlight.incompatible;
}

/// IN-21: la ragione del rifiuto (ER-15), per la barra a chi insiste su
/// uno slot non compatibile (6.5 interfaccia.md). `null` se ammissibile.
String? mealSwapRejectionReason(MealSwapOrigin origin, PlanDay day, PlanDaySlot slot) {
  // IN-15: il medesimo piano soltanto — un confine di piano nella
  // settimana mostrata non deve mai apparire compatibile. Nessun codice
  // di ER-15 descrive esattamente questo caso lato client (il server non
  // lo incontra mai, essendo l'endpoint già scoperto per un solo piano):
  // riusato PLAN_NOT_ACTIVE, la ragione più vicina fra quelle già tradotte.
  if (day.planId != origin.planId) return 'PLAN_NOT_ACTIVE';
  return validateMealSwap(
    planStatus: PlanStatus.active,
    first: origin._candidate,
    second: MealSwapCandidate(date: day.date, type: slot.type, status: slot.status),
    today: dateOnly(DateTime.now()),
  );
}

/// Se non `null`, la vista settimanale è in modalità di selezione (6.5
/// interfaccia.md).
@riverpod
class MealSwapSelection extends _$MealSwapSelection {
  @override
  MealSwapOrigin? build() => null;

  void start(MealSwapOrigin origin) => state = origin;
  void cancel() => state = null;
}

/// Esecuzione dello scambio (AP-11). Nessuno stato da esporre oltre
/// all'esito: la giornata aggiornata si ottiene invalidando la cache di
/// [planDayRangeProvider], sullo stesso criterio di
/// [PlanDaySlotStatusController].
@riverpod
class MealSwapController extends _$MealSwapController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> swap(MealSwapOrigin origin, DateTime destinationDate, String destinationSlotId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(mealSwapApiProvider).swap(
          planId: origin.planId,
          firstDate: origin.date,
          firstSlotId: origin.slotId,
          secondDate: destinationDate,
          secondSlotId: destinationSlotId,
        ));
    ref.read(mealSwapSelectionProvider.notifier).cancel();
    final weekStart = startOfWeek(origin.date);
    ref.invalidate(planDayRangeProvider(weekStart, weekStart.add(const Duration(days: 6))));
    ref.invalidate(planDayProvider(origin.date));
    ref.invalidate(planDayProvider(destinationDate));
  }
}
