/// Determinazione del piano "in corso" (PA-8) fra l'elenco dei piani non
/// conclusi (7.1 interfaccia.md). Priva di dipendenze (sul modello di
/// `diet_plan_field_validators.dart`): la stessa priorità già scritta sul
/// backend (`DietPlanService.getCurrentPlan`), qui applicata all'elenco già
/// ricevuto invece di una richiesta separata.
library;

import '../data/diet_plan.dart';
import '../data/plan_status.dart';

/// `null` se nessun piano Attivo, Sospeso o Programmato esiste — anche in
/// presenza di sole Bozze, che non compaiono mai come piano "in corso"
/// (7.1 interfaccia.md non prevede quello stato per la card).
DietPlan? findCurrentPlan(List<DietPlan> plans) {
  for (final plan in plans) {
    if (plan.status == PlanStatus.active) return plan;
  }
  for (final plan in plans) {
    if (plan.status == PlanStatus.suspended) return plan;
  }
  DietPlan? nearestScheduled;
  for (final plan in plans) {
    if (plan.status != PlanStatus.scheduled) continue;
    if (nearestScheduled == null || plan.startDate.isBefore(nearestScheduled.startDate)) {
      nearestScheduled = plan;
    }
  }
  return nearestScheduled;
}
