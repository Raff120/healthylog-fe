/// Stato del ciclo di vita del piano (3.6 funzionale). Rispecchia
/// `it.healthylog.model.PlanStatus` sul backend. Le transizioni tra questi
/// valori sono compito di F10; qui se ne rispecchiano solo i valori.
enum PlanStatus {
  draft,
  scheduled,
  active,
  suspended,
  completed;

  static PlanStatus fromJson(String value) => switch (value) {
        'SCHEDULED' => PlanStatus.scheduled,
        'ACTIVE' => PlanStatus.active,
        'SUSPENDED' => PlanStatus.suspended,
        'COMPLETED' => PlanStatus.completed,
        _ => PlanStatus.draft,
      };

  /// VR-10: `null` per uno stato che questa versione del client non
  /// conosce. Negli elenchi il piano è omesso: presentato come Bozza ne
  /// offrirebbe la modifica e l'eliminazione.
  static PlanStatus? tryFromJson(String value) => switch (value) {
        'DRAFT' => PlanStatus.draft,
        'SCHEDULED' => PlanStatus.scheduled,
        'ACTIVE' => PlanStatus.active,
        'SUSPENDED' => PlanStatus.suspended,
        'COMPLETED' => PlanStatus.completed,
        _ => null,
      };
}
