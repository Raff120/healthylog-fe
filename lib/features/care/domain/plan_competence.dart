/// Competenza sul contenuto e sul ciclo di vita di un piano dal punto di
/// vista dell'Utente (5.4 funzionale). Priva di dipendenze (TE-4): la
/// stessa regola applicata dal backend (`DietPlanService.findManageablePlan`),
/// qui anticipata in interfaccia per non offrire azioni che il server
/// respingerebbe (7.1 interfaccia.md: "Al Paziente non compaiono").
library;

import '../../dietplan/data/diet_plan.dart';
import '../data/care_models.dart';

/// UT-8, PZ-4, TR-17: il piano è "bloccato" per il proprietario quando è
/// stato redatto dal Nutrizionista con cui ha un collegamento vigente.
/// PZ-9, CP-12: i piani redatti dall'Utente stesso non lo sono mai;
/// CP-19, PZ-8: alla revoca ([currentLink] assente, o di un altro
/// professionista) il blocco cade.
bool isPlanLockedForPatient(DietPlan plan, CareLink? currentLink) {
  if (currentLink == null || currentLink.status != CareLinkStatus.active) return false;
  if (plan.authorId == plan.ownerId) return false;
  return plan.authorId == currentLink.nutritionistId && plan.ownerId == currentLink.patientId;
}

/// UT-8: il Paziente non crea piani propri finché il collegamento è vigente.
bool canCreateOwnPlan(CareLink? currentLink) =>
    currentLink == null || currentLink.status != CareLinkStatus.active;
