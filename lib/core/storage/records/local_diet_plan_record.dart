/// Copia locale del piano attivo con schema settimanale (PL-6).
/// `weeklyScheduleJson` è la serializzazione JSON che la feature produce
/// dal proprio DTO (`DietPlanWeekDay` e slot): `core/storage` non ne
/// conosce la forma (PL-5, vedi `LocalDietPlans`).
class LocalDietPlanRecord {
  const LocalDietPlanRecord({
    required this.id,
    required this.ownerId,
    required this.authorId,
    required this.authorRole,
    required this.name,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.weeklyScheduleJson,
  });

  final String id;
  final String ownerId;
  final String authorId;
  final String authorRole;
  final String name;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String weeklyScheduleJson;
}
