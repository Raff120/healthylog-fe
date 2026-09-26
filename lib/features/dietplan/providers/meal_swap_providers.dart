import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/meal_swap_api.dart';
import '../data/meal_swap_log.dart';
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

/// Dove riportare chi ha avviato l'inversione dalla vista giornaliera
/// (6.5 interfaccia.md): la giornata di partenza e, se vi si trovava, la
/// modalità affiancata (VG-12), che l'avvio disattiva per condurre alla
/// settimanale.
class SwapReturn {
  const SwapReturn({required this.date, this.sideBySide = false});

  final DateTime date;
  final bool sideBySide;
}

/// Il punto di ritorno della selezione in corso, `null` se avviata dalla
/// settimanale. Registrato all'avvio della selezione, ripristinato al suo
/// termine — scambio compiuto, rifiutato o abbandonato (6.5). Conservato
/// anche senza osservatori: nessuna schermata lo presenta, e altrimenti
/// Riverpod lo scarterebbe fra l'avvio e il termine.
@Riverpod(keepAlive: true)
class SwapReturnPoint extends _$SwapReturnPoint {
  @override
  SwapReturn? build() => null;

  void _record(SwapReturn? point) => state = point;

  void _restore() {
    final point = state;
    if (point == null) return;
    state = null;
    ref.read(selectedDayProvider.notifier).select(point.date);
    if (point.sideBySide) ref.read(sideBySideModeProvider.notifier).enable();
    ref.read(selectedPlanViewProvider.notifier).select(PlanViewMode.day);
  }
}

/// Se non `null`, la vista settimanale è in modalità di selezione (6.5
/// interfaccia.md).
@riverpod
class MealSwapSelection extends _$MealSwapSelection {
  @override
  MealSwapOrigin? build() => null;

  /// [returnTo] se l'avvio viene dalla vista giornaliera: al termine della
  /// selezione vi si torna (6.5).
  void start(MealSwapOrigin origin, {SwapReturn? returnTo}) {
    ref.read(daySwapSelectionProvider.notifier)._discard();
    ref.read(swapReturnPointProvider.notifier)._record(returnTo);
    state = origin;
  }

  /// Termine della selezione, per qualunque via (6.5): riporta alla
  /// giornaliera se di lì era partita.
  void cancel() {
    state = null;
    ref.read(swapReturnPointProvider.notifier)._restore();
  }

  /// L'avvio della selezione delle giornate prende il posto di questa:
  /// non è un termine, e non riporta ad alcuna vista.
  void _discard() => state = null;
}

/// Esecuzione dello scambio (AP-11). Nessuno stato da esporre oltre
/// all'esito: la giornata aggiornata si ottiene invalidando la cache di
/// [planDayRangeProvider], sullo stesso criterio di
/// [PlanDaySlotStatusController].
@riverpod
class MealSwapController extends _$MealSwapController {
  @override
  AsyncValue<void>? build() => null;

  /// CU-2: [userId] facoltativo, per l'inversione disposta dal Cuoco sul
  /// piano di un membro del proprio Gruppo — determina quale cache
  /// rinnovare, dato che l'autorizzazione stessa è già risolta lato
  /// server tramite `origin.planId`.
  Future<void> swap(
    MealSwapOrigin origin,
    DateTime destinationDate,
    String destinationSlotId, {
    String? userId,
  }) async {
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
    ref.invalidate(planDayRangeProvider(weekStart, weekStart.add(const Duration(days: 6)), userId: userId));
    ref.invalidate(planDayProvider(origin.date, userId: userId));
    ref.invalidate(planDayProvider(destinationDate, userId: userId));
    ref.invalidate(groupPlanDayProvider(origin.date));
    ref.invalidate(groupPlanDayProvider(destinationDate));
  }
}

/// La giornata scelta come origine dell'inversione di giornate intere
/// (IN-28): il piano, la data e lo stato di ciascuno dei suoi slot, quanto
/// serve alla valutazione locale (MS-24).
class DaySwapOrigin {
  const DaySwapOrigin({required this.planId, required this.date, required this.statuses});

  factory DaySwapOrigin.of(PlanDay day) => DaySwapOrigin(
        planId: day.planId!,
        date: day.date,
        statuses: [for (final slot in day.slots) slot.status],
      );

  final String planId;
  final DateTime date;
  final List<SlotStatus> statuses;
}

/// MS-24, condizioni 1, 3 e 5-6 applicate alla sola giornata di origine:
/// simmetriche fra origine e destinazione, una giornata che già le viola non
/// origina alcuna inversione ammessa — la selezione non si avvia.
bool isDaySwapOriginEligible(PlanDay day) {
  if (day.coverage != PlanDayCoverage.active || day.planId == null) return false;
  if (day.date.isBefore(dateOnly(DateTime.now()))) return false;
  return day.slots.every((slot) => slot.status == SlotStatus.toConsume);
}

/// IN-21: la ragione del rifiuto per la giornata [day] come destinazione,
/// `null` se ammessa (IN-20, MS-24).
String? daySwapRejectionReason(DaySwapOrigin origin, PlanDay day) {
  // IN-15, come per gli slot: un confine di piano nella settimana non deve
  // apparire compatibile, e non ha un codice proprio.
  if (day.planId != origin.planId || day.coverage != PlanDayCoverage.active) return 'PLAN_NOT_ACTIVE';
  return validateDaySwap(
    planStatus: PlanStatus.active,
    first: DaySwapCandidate(date: origin.date, statuses: origin.statuses),
    second: DaySwapCandidate(date: day.date, statuses: [for (final slot in day.slots) slot.status]),
    today: dateOnly(DateTime.now()),
  );
}

/// L'esito dell'evidenziazione di una giornata durante la selezione (6.5
/// interfaccia.md), con i medesimi valori degli slot.
MealSwapHighlight daySwapHighlightFor(DaySwapOrigin origin, PlanDay day) {
  if (day.date == origin.date) return MealSwapHighlight.origin;
  return daySwapRejectionReason(origin, day) == null ? MealSwapHighlight.compatible : MealSwapHighlight.incompatible;
}

/// Se non `null`, la vista settimanale è in modalità di selezione delle
/// giornate (6.5 interfaccia.md, IN-28). Esclusiva con quella degli slot:
/// l'avvio dell'una annulla l'altra.
@riverpod
class DaySwapSelection extends _$DaySwapSelection {
  @override
  DaySwapOrigin? build() => null;

  /// [returnTo] come per gli slot ([MealSwapSelection.start]).
  void start(DaySwapOrigin origin, {SwapReturn? returnTo}) {
    ref.read(mealSwapSelectionProvider.notifier)._discard();
    ref.read(swapReturnPointProvider.notifier)._record(returnTo);
    state = origin;
  }

  void cancel() {
    state = null;
    ref.read(swapReturnPointProvider.notifier)._restore();
  }

  void _discard() => state = null;
}

/// Esecuzione dell'inversione di giornate (IN-28), sul modello di
/// [MealSwapController]: nessuno stato oltre all'esito, e le giornate si
/// rileggono invalidando le cache.
@riverpod
class DaySwapController extends _$DaySwapController {
  @override
  AsyncValue<void>? build() => null;

  /// CU-2: [userId] per l'inversione disposta dal Cuoco sul piano di un
  /// membro, a determinare quale cache rinnovare.
  Future<void> swap(DaySwapOrigin origin, DateTime destinationDate, {String? userId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(mealSwapApiProvider).swapDays(
          planId: origin.planId,
          firstDate: origin.date,
          secondDate: destinationDate,
        ));
    ref.read(daySwapSelectionProvider.notifier).cancel();
    final weekStart = startOfWeek(origin.date);
    ref.invalidate(planDayRangeProvider(weekStart, weekStart.add(const Duration(days: 6)), userId: userId));
    ref.invalidate(planDayProvider(origin.date, userId: userId));
    ref.invalidate(planDayProvider(destinationDate, userId: userId));
    ref.invalidate(groupPlanDayProvider(origin.date));
    ref.invalidate(groupPlanDayProvider(destinationDate));
  }
}

/// IN-24, ST-5: lo storico delle inversioni di un piano, che il dettaglio
/// del piano concluso presenta in coda (7.5 interfaccia.md).
@riverpod
Future<List<MealSwapLog>> mealSwapHistory(Ref ref, String planId) =>
    ref.watch(mealSwapApiProvider).history(planId);
