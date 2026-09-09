import 'package:drift/drift.dart';

/// Occorrenze giornaliere (PL-6: "Settimana corrente e due settimane
/// adiacenti"). A differenza dello schema del piano, una riga per data
/// (non annidata: ML-9 vieta l'annidamento per elementi che crescono
/// senza limite noto). `date` è la chiave: la finestra di conservazione
/// (PL-7, PL-10) e le selezioni per intervallo richieste dalle regole di
/// dominio replicate (FE-7, PL-3) filtrano su questa colonna.
///
/// `slots` resta JSON in `slotsJson` (ML-7: `MealSlot` annida in
/// `PlanDay` anche sul backend) per lo stesso motivo di
/// [LocalDietPlans]: la forma dei DTO di dominio non appartiene a
/// `core/storage` (PL-5).
class LocalPlanDays extends Table {
  DateTimeColumn get date => dateTime()();
  TextColumn get coverage => text()();
  TextColumn get planId => text().nullable()();
  TextColumn get planName => text().nullable()();
  DateTimeColumn get planStartDate => dateTime().nullable()();
  DateTimeColumn get planEndDate => dateTime().nullable()();
  TextColumn get slotsJson => text()();

  @override
  Set<Column> get primaryKey => {date};
}
