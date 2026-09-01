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
