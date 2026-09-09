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
}
