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
}
