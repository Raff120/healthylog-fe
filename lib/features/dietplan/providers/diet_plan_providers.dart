import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/download/file_download.dart';
import '../../care/providers/care_providers.dart';
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
    // F22: il dettaglio del Paziente elenca i piani redatti dal Nutrizionista.
    if (state?.hasError == false) ref.invalidate(patientDetailControllerProvider);
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
    if (state?.hasError == false) {
      ref.invalidate(ownedDietPlansProvider);
      // F22: il Nutrizionista rientra nel dettaglio del Paziente.
      ref.invalidate(patientDetailControllerProvider);
      ref.invalidate(patientsProvider);
    }
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
    // F22: le stesse transizioni disposte dal Nutrizionista dal dettaglio
    // del Paziente (NU-2), che elenca i piani per stato.
    ref.invalidate(patientDetailControllerProvider);
    ref.invalidate(patientsProvider);
  }

  Future<void> withdraw(String planId) => _run(() => ref.read(dietPlanApiProvider).withdraw(planId));

  Future<void> activate(String planId) => _run(() => ref.read(dietPlanApiProvider).activate(planId));

  Future<void> suspend(String planId) => _run(() => ref.read(dietPlanApiProvider).suspend(planId));

  Future<void> resume(String planId) => _run(() => ref.read(dietPlanApiProvider).resume(planId));

  Future<void> complete(String planId) => _run(() => ref.read(dietPlanApiProvider).complete(planId));

  /// CV-10, CV-11.
  Future<void> delete(String planId) => _run(() => ref.read(dietPlanApiProvider).delete(planId));
}

/// PV-12, PV-13, PV-15: esportazione del piano in PDF. Controller
/// distinto dal ciclo di vita: non muta nulla e non deve invalidare
/// alcun elenco.
@riverpod
class DietPlanExportController extends _$DietPlanExportController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> export(String planId) async {
    state = const AsyncValue.loading();
    final outcome = await AsyncValue.guard(() async {
      final exported = await ref.read(dietPlanApiProvider).export(planId);
      await deliverFile(
        fileName: exported.fileName,
        bytes: exported.bytes,
        mimeType: 'application/pdf',
      );
    });
    // La consegna può concludersi quando la schermata è già stata
    // lasciata — il foglio di condivisione del sistema la copre.
    if (!ref.mounted) return;
    state = outcome;
  }
}
