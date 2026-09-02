/// Natura della giornata rispetto al piano che la copre (VG-18, PA-10).
/// Rispecchia `it.healthylog.model.PlanDayCoverage` sul backend.
enum PlanDayCoverage {
  none,
  scheduled,
  active,
  suspended,
  completed;

  static PlanDayCoverage fromJson(String value) => switch (value) {
    'SCHEDULED' => PlanDayCoverage.scheduled,
    'ACTIVE' => PlanDayCoverage.active,
    'SUSPENDED' => PlanDayCoverage.suspended,
    'COMPLETED' => PlanDayCoverage.completed,
    _ => PlanDayCoverage.none,
  };

  /// Per la cache locale di sola lettura (PL-6, F14): mai inviato al
  /// backend, che non espone alcun corpo con questo campo in scrittura.
  String toJson() => switch (this) {
    PlanDayCoverage.none => 'NONE',
    PlanDayCoverage.scheduled => 'SCHEDULED',
    PlanDayCoverage.active => 'ACTIVE',
    PlanDayCoverage.suspended => 'SUSPENDED',
    PlanDayCoverage.completed => 'COMPLETED',
  };
}
