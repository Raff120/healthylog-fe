/// Copia locale di un'occorrenza giornaliera (PL-6). `date` DEVE essere
/// già normalizzata a mezzanotte dal chiamante (ML-18): è la chiave della
/// riga, `core/storage` non la normalizza. `slotsJson` è la
/// serializzazione JSON prodotta dalla feature (PL-5, vedi `LocalPlanDays`).
class LocalPlanDayRecord {
  const LocalPlanDayRecord({
    required this.date,
    required this.coverage,
    required this.planId,
    required this.planName,
    required this.planStartDate,
    required this.planEndDate,
    required this.slotsJson,
  });

  final DateTime date;
  final String coverage;
  final String? planId;
  final String? planName;
  final DateTime? planStartDate;
  final DateTime? planEndDate;
  final String slotsJson;
}
