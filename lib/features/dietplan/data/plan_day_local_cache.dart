import 'dart:convert';

import '../../../core/storage/plan_day_local_store.dart';
import '../../../core/storage/records/local_plan_day_record.dart';
import '../domain/plan_day_date.dart';
import 'plan_day.dart';
import 'plan_day_coverage.dart';
import 'slot_status.dart';
import 'slot_type.dart';

/// Converte [PlanDay] da/verso [LocalPlanDayRecord] (PL-5, PL-6, F14):
/// `core/storage` non conosce questo DTO, la conversione appartiene alla
/// feature. Unico punto in cui la vista giornaliera (F12/F13) legge e
/// scrive la cache di sola lettura della consultazione offline (OF-19).
class PlanDayLocalCache {
  const PlanDayLocalCache(this._store);

  final PlanDayLocalStore _store;

  /// Salva la giornata e rimuove nella stessa occasione ciò che è uscito
  /// dall'orizzonte (PL-10): la settimana corrente al momento del
  /// salvataggio, non quella di [day] — che può essere una data
  /// qualunque, consultata navigando (VG-16, VG-17).
  Future<void> save(PlanDay day) async {
    await _store.upsert(
      LocalPlanDayRecord(
        date: dateOnly(day.date),
        coverage: day.coverage.toJson(),
        planId: day.planId,
        planName: day.planName,
        planStartDate: day.planStartDate == null ? null : dateOnly(day.planStartDate!),
        planEndDate: day.planEndDate == null ? null : dateOnly(day.planEndDate!),
        slotsJson: jsonEncode(day.slots.map((slot) => slot.toJson()).toList()),
      ),
    );
    final monday = startOfWeek(DateTime.now());
    await _store.deleteOutsideRange(monday, monday.add(const Duration(days: 6)));
  }

  Future<PlanDay?> read(DateTime date) async {
    final rows = await _store.readRange(dateOnly(date), dateOnly(date));
    if (rows.isEmpty) return null;
    return _fromRecord(rows.single);
  }

  PlanDay _fromRecord(LocalPlanDayRecord record) => PlanDay(
    date: record.date,
    coverage: PlanDayCoverage.fromJson(record.coverage),
    planId: record.planId,
    planName: record.planName,
    planStartDate: record.planStartDate,
    planEndDate: record.planEndDate,
    slots: (jsonDecode(record.slotsJson) as List)
        .map((e) => _slotFromJson(e as Map<String, dynamic>))
        .toList(),
  );

  PlanDaySlot _slotFromJson(Map<String, dynamic> json) => PlanDaySlot(
    slotId: json['slotId'] as String,
    type: SlotType.fromJson(json['type'] as String),
    label: json['label'] as String?,
    order: json['order'] as int,
    content: json['content'] as String?,
    note: json['note'] as String?,
    recipeName: json['recipeName'] as String?,
    recipeText: json['recipeText'] as String?,
    status: SlotStatus.fromJson(json['status'] as String),
  );
}
