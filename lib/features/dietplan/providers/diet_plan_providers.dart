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

/// PA-9, 7.1 interfaccia.md: l'elenco dei piani non conclusi, Bozza
/// compresa — a differenza del solo piano "in corso" di PA-8, che la
/// schermata di gestione determina da questo stesso elenco (vedi
/// `findCurrentPlan`), non con una richiesta separata.
@riverpod
Future<List<DietPlan>> ownedDietPlans(Ref ref) => ref.watch(dietPlanApiProvider).list();

/// Transizioni di stato ed eliminazione disposte dalla schermata di
/// gestione (7.1 interfaccia.md, F10): ciascuna invalida
/// [ownedDietPlansProvider], così che l'elenco rifletta lo stato
/// realmente raggiunto — anche quando il piano "in corso" cambia
/// identità (AS-11: il piano ritirato non è più "in corso"; CV-5: il
/// piano concluso lascia il posto, se esiste, al prossimo Programmato,
/// pur restando nell'elenco come Concluso) — invece di aggiornare uno
/// stato locale che dovrebbe replicare la stessa logica di priorità del
/// server. Il payload della risposta non serve a nessun chiamante:
/// `AsyncValue<void>` invece di `AsyncValue<DietPlan>`.
@riverpod
class DietPlanLifecycleController extends _$DietPlanLifecycleController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(action);
    ref.invalidate(ownedDietPlansProvider);
  }

  Future<void> withdraw(String planId) => _run(() => ref.read(dietPlanApiProvider).withdraw(planId));

  Future<void> activate(String planId) => _run(() => ref.read(dietPlanApiProvider).activate(planId));

  Future<void> suspend(String planId) => _run(() => ref.read(dietPlanApiProvider).suspend(planId));

  Future<void> resume(String planId) => _run(() => ref.read(dietPlanApiProvider).resume(planId));

  Future<void> complete(String planId) => _run(() => ref.read(dietPlanApiProvider).complete(planId));

  /// CV-10, CV-11.
  Future<void> delete(String planId) => _run(() => ref.read(dietPlanApiProvider).delete(planId));
}
