import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/diet_plan_requests.dart';
import '../data/diet_plan_template.dart';
import '../data/diet_plan_template_api.dart';
import '../data/diet_plan_template_requests.dart';
import 'diet_plan_providers.dart';

part 'diet_plan_template_providers.g.dart';

@riverpod
DietPlanTemplateApi dietPlanTemplateApi(Ref ref) => DietPlanTemplateApi(ref.watch(apiClientProvider));

/// Elenco dei template di proprietà di chi opera (CT-2, CT-3), da
/// ricaricare dopo ogni creazione o eliminazione (`ref.invalidateSelf`).
@riverpod
class DietPlanTemplateList extends _$DietPlanTemplateList {
  @override
  Future<List<DietPlanTemplateSummary>> build() => ref.read(dietPlanTemplateApiProvider).list();
}

/// Creazione del template (TP-4, TP-7): nessuno stato da ricaricare al
/// primo utilizzo, sul modello di [CreateDietPlanController].
@riverpod
class CreateDietPlanTemplateController extends _$CreateDietPlanTemplateController {
  @override
  AsyncValue<DietPlanTemplate>? build() => null;

  Future<void> create(CreateDietPlanTemplateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(dietPlanTemplateApiProvider).create(request));
    if (state?.hasError == false) ref.invalidate(dietPlanTemplateListProvider);
  }
}

/// Anteprima del template (CT-4, CT-5): lettura di sola consultazione,
/// nessun metodo di scrittura su questo notifier.
@riverpod
class DietPlanTemplatePreview extends _$DietPlanTemplatePreview {
  @override
  Future<DietPlanTemplate> build(String templateId) => ref.read(dietPlanTemplateApiProvider).get(templateId);
}

/// Template in redazione (TP-12): caricato per `templateId` al primo
/// accesso e sostituito con l'esito di ogni salvataggio riuscito, sul
/// modello di [DietPlanScheduleController].
@riverpod
class DietPlanTemplateScheduleController extends _$DietPlanTemplateScheduleController {
  @override
  Future<DietPlanTemplate> build(String templateId) => ref.read(dietPlanTemplateApiProvider).get(templateId);

  Future<DietPlanTemplate> save(UpdateWeeklyScheduleRequest request) async {
    final template = await ref.read(dietPlanTemplateApiProvider).updateSchedule(templateId, request);
    state = AsyncValue.data(template);
    return template;
  }
}

/// Eliminazione del template (TP-12): nessun effetto sui piani già
/// derivati (CT-16).
@riverpod
class DeleteDietPlanTemplateController extends _$DeleteDietPlanTemplateController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> delete(String templateId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(dietPlanTemplateApiProvider).delete(templateId));
    if (state?.hasError == false) ref.invalidate(dietPlanTemplateListProvider);
  }
}

/// Salvataggio del piano come template (TP-5, CD-18), dalla redazione del
/// piano: nessuno stato da ricaricare al primo utilizzo.
@riverpod
class SaveDietPlanAsTemplateController extends _$SaveDietPlanAsTemplateController {
  @override
  AsyncValue<DietPlanTemplate>? build() => null;

  Future<void> save(String planId, SaveDietPlanAsTemplateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(dietPlanApiProvider).saveAsTemplate(planId, request));
  }
}
