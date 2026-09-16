import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';
import 'records/local_plan_day_record.dart';

part 'plan_day_local_store.g.dart';

/// Livello di astrazione per le occorrenze giornaliere locali (PL-5,
/// PL-6). A differenza del piano, più righe convivono (la settimana
/// corrente, PL-7): [upsert] sostituisce la sola riga con la stessa
/// data, le altre restano intatte.
class PlanDayLocalStore {
  const PlanDayLocalStore(this._db);

  final AppDatabase _db;

  Future<void> upsert(LocalPlanDayRecord record) {
    return _db.into(_db.localPlanDays).insertOnConflictUpdate(_toCompanion(record));
  }

  Future<void> upsertAll(List<LocalPlanDayRecord> records) {
    return _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.localPlanDays, records.map(_toCompanion));
    });
  }

  /// Legge le occorrenze con data compresa tra [from] e [to], estremi
  /// inclusi. Entrambe DEVONO essere già normalizzate a mezzanotte
  /// (ML-18), come le righe conservate.
  Future<List<LocalPlanDayRecord>> readRange(DateTime from, DateTime to) async {
    final query = _db.select(_db.localPlanDays)
      ..where((t) => t.date.isBetweenValues(from, to))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]);
    final rows = await query.get();
    return rows.map(_toRecord).toList();
  }

  Stream<List<LocalPlanDayRecord>> watchRange(DateTime from, DateTime to) {
    final query = _db.select(_db.localPlanDays)
      ..where((t) => t.date.isBetweenValues(from, to))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]);
    return query.watch().map((rows) => rows.map(_toRecord).toList());
  }

  /// Rimuove le occorrenze con data esterna a [from]..[to] (PL-10):
  /// quanto esce dall'orizzonte conservato (PL-6, PL-7).
  Future<void> deleteOutsideRange(DateTime from, DateTime to) {
    return (_db.delete(_db.localPlanDays)
          ..where((t) => t.date.isSmallerThanValue(from) | t.date.isBiggerThanValue(to)))
        .go();
  }

  LocalPlanDaysCompanion _toCompanion(LocalPlanDayRecord record) => LocalPlanDaysCompanion.insert(
        date: record.date,
        coverage: record.coverage,
        planId: Value(record.planId),
        planName: Value(record.planName),
        planStartDate: Value(record.planStartDate),
        planEndDate: Value(record.planEndDate),
        slotsJson: record.slotsJson,
      );

  LocalPlanDayRecord _toRecord(LocalPlanDay row) => LocalPlanDayRecord(
        date: row.date,
        coverage: row.coverage,
        planId: row.planId,
        planName: row.planName,
        planStartDate: row.planStartDate,
        planEndDate: row.planEndDate,
        slotsJson: row.slotsJson,
      );
}

@riverpod
PlanDayLocalStore planDayLocalStore(Ref ref) => PlanDayLocalStore(ref.watch(appDatabaseProvider));
