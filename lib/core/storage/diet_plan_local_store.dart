import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';
import 'records/local_diet_plan_record.dart';

part 'diet_plan_local_store.g.dart';

/// Livello di astrazione per il piano attivo locale (PL-5, PL-6). Una
/// sola riga ("Sempre" in PL-6): [save] sostituisce l'eventuale piano
/// precedentemente cacheato — non necessariamente lo stesso piano, dato
/// che un piano può concludersi e un altro subentrare come attivo.
class DietPlanLocalStore {
  const DietPlanLocalStore(this._db);

  final AppDatabase _db;

  Future<void> save(LocalDietPlanRecord record) {
    return _db.transaction(() async {
      await _db.delete(_db.localDietPlans).go();
      await _db.into(_db.localDietPlans).insert(
            LocalDietPlansCompanion.insert(
              id: record.id,
              ownerId: record.ownerId,
              authorId: record.authorId,
              authorRole: record.authorRole,
              name: record.name,
              status: record.status,
              startDate: record.startDate,
              endDate: Value(record.endDate),
              weeklyScheduleJson: record.weeklyScheduleJson,
            ),
          );
    });
  }

  Future<void> clear() => _db.delete(_db.localDietPlans).go();

  Future<LocalDietPlanRecord?> read() async {
    final row = await _db.select(_db.localDietPlans).getSingleOrNull();
    return row == null ? null : _toRecord(row);
  }

  Stream<LocalDietPlanRecord?> watch() {
    return _db.select(_db.localDietPlans).watchSingleOrNull().map((row) => row == null ? null : _toRecord(row));
  }

  LocalDietPlanRecord _toRecord(LocalDietPlan row) => LocalDietPlanRecord(
        id: row.id,
        ownerId: row.ownerId,
        authorId: row.authorId,
        authorRole: row.authorRole,
        name: row.name,
        status: row.status,
        startDate: row.startDate,
        endDate: row.endDate,
        weeklyScheduleJson: row.weeklyScheduleJson,
      );
}

@riverpod
DietPlanLocalStore dietPlanLocalStore(Ref ref) => DietPlanLocalStore(ref.watch(appDatabaseProvider));
