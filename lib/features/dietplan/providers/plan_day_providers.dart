import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/plan_day.dart';
import '../data/plan_day_api.dart';
import '../data/slot_status.dart';
import '../domain/plan_day_date.dart';

part 'plan_day_providers.g.dart';

@riverpod
PlanDayApi planDayApi(Ref ref) => PlanDayApi(ref.watch(apiClientProvider));

/// Giornata selezionata nella vista giornaliera (VG-2: quella corrente
/// all'apertura). La sola navigazione libera (VG-16, VG-17) e il ritorno
/// a oggi (VG-19) sono task successivi, sullo stesso stato.
@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  DateTime build() => dateOnly(DateTime.now());

  void select(DateTime date) => state = dateOnly(date);
}

/// Contenuto della giornata richiesta (EP-3: mai materializzata dalla
/// sola lettura). `family` per data: ogni giorno visitato ha una propria
/// cache, così tornare a un giorno già consultato non richiede una nuova
/// richiesta.
@riverpod
Future<PlanDay> planDay(Ref ref, DateTime date) => ref.watch(planDayApiProvider).getDay(date);

/// Transizione di stato dello slot (6.3 funzionale, SP-1, SP-4, SP-5),
/// disposta dalla card del pasto. Nessuno stato locale da esporre: la
/// risposta rinnova la cache di [planDayProvider] tramite invalidazione,
/// sullo stesso criterio già seguito da `DietPlanLifecycleController`
/// per l'elenco dei piani, invece di sostituirne il contenuto a mano.
@riverpod
class PlanDaySlotStatusController extends _$PlanDaySlotStatusController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> updateStatus(DateTime date, String slotId, SlotStatus status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(planDayApiProvider).updateSlotStatus(date, slotId, status),
    );
    ref.invalidate(planDayProvider(date));
  }
}
