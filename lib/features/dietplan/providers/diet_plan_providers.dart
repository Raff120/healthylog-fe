import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/diet_plan.dart';
import '../data/diet_plan_api.dart';
import '../data/diet_plan_requests.dart';

part 'diet_plan_providers.g.dart';

@riverpod
DietPlanApi dietPlanApi(Ref ref) => DietPlanApi(ref.watch(apiClientProvider));

/// Creazione del piano (CD-1, CD-4): nessuno stato da ricaricare al primo
/// utilizzo, a differenza di [DietPlanScheduleController] — la schermata di
/// creazione non legge alcun piano esistente.
@riverpod
class CreateDietPlanController extends _$CreateDietPlanController {
  @override
  AsyncValue<DietPlan>? build() => null;

  Future<void> create(CreateDietPlanRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(dietPlanApiProvider).create(request));
  }
}

/// Piano in redazione (CD-5, CD-7, CD-8, CD-10): caricato per `planId` al
/// primo accesso alla schermata (ST-4) e sostituito con l'esito di ogni
/// salvataggio riuscito, così che un nuovo `slotId` generato lato server
/// (per uno slot appena aggiunto) sia disponibile ai salvataggi successivi.
@riverpod
class DietPlanScheduleController extends _$DietPlanScheduleController {
  @override
  Future<DietPlan> build(String planId) => ref.read(dietPlanApiProvider).getPlan(planId);

  Future<DietPlan> save(UpdateWeeklyScheduleRequest request) async {
    final plan = await ref.read(dietPlanApiProvider).updateSchedule(planId, request);
    state = AsyncValue.data(plan);
    return plan;
  }
}

/// CV-2: conferma del piano in redazione.
@riverpod
class ConfirmDietPlanController extends _$ConfirmDietPlanController {
  @override
  AsyncValue<DietPlan>? build() => null;

  Future<void> confirm(String planId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(dietPlanApiProvider).confirm(planId));
  }
}

/// PA-8: il piano "in corso" (7.1 interfaccia.md).
@riverpod
Future<DietPlan?> currentDietPlan(Ref ref) => ref.watch(dietPlanApiProvider).getCurrent();

/// Transizioni di stato disposte dalla schermata di gestione (7.1
/// interfaccia.md, F10): ciascuna invalida [currentDietPlanProvider], così
/// che la card rifletta lo stato realmente raggiunto — anche quando
/// cambia identità (AS-11: il piano ritirato non è più "in corso";
/// CV-5: il piano concluso lascia il posto, se esiste, al prossimo
/// Programmato) — invece di aggiornare uno stato locale che dovrebbe
/// replicare la stessa logica di priorità del server (PA-9).
@riverpod
class DietPlanLifecycleController extends _$DietPlanLifecycleController {
  @override
  AsyncValue<DietPlan>? build() => null;

  Future<void> _run(Future<DietPlan> Function() action) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(action);
    ref.invalidate(currentDietPlanProvider);
  }

  Future<void> withdraw(String planId) => _run(() => ref.read(dietPlanApiProvider).withdraw(planId));

  Future<void> activate(String planId) => _run(() => ref.read(dietPlanApiProvider).activate(planId));

  Future<void> suspend(String planId) => _run(() => ref.read(dietPlanApiProvider).suspend(planId));

  Future<void> resume(String planId) => _run(() => ref.read(dietPlanApiProvider).resume(planId));

  Future<void> complete(String planId) => _run(() => ref.read(dietPlanApiProvider).complete(planId));
}
