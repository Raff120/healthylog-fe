import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/core/storage/plan_day_local_store.dart';
import 'package:healthylog/core/storage/records/local_plan_day_record.dart';

LocalPlanDayRecord _day(DateTime date, {String slots = '[]'}) => LocalPlanDayRecord(
      date: date,
      coverage: 'ACTIVE',
      planId: 'p1',
      planName: 'Piano',
      planStartDate: DateTime(2026, 1, 1),
      planEndDate: null,
      slotsJson: slots,
    );

/// Cache di lettura delle occorrenze giornaliere (PL-5, PL-6, F14).
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('upsert sostituisce la sola riga con la stessa data', () async {
    final store = PlanDayLocalStore(db);
    final date = DateTime(2026, 9, 7);

    await store.upsert(_day(date, slots: '[]'));
    await store.upsert(_day(date, slots: '[{"status":"CONSUMED"}]'));

    final rows = await store.readRange(date, date);
    expect(rows, hasLength(1));
    expect(rows.single.slotsJson, '[{"status":"CONSUMED"}]');
  });

  test('readRange/watchRange filtrano per data, estremi inclusi, ordinati', () async {
    final store = PlanDayLocalStore(db);
    final mon = DateTime(2026, 9, 7);
    final tue = DateTime(2026, 9, 8);
    final wed = DateTime(2026, 9, 9);
    final farAway = DateTime(2026, 10, 1);

    await store.upsertAll([_day(wed), _day(mon), _day(tue), _day(farAway)]);

    final week = await store.readRange(mon, wed);
    expect(week.map((d) => d.date), [mon, tue, wed]);

    final watched = await store.watchRange(mon, wed).first;
    expect(watched.map((d) => d.date), [mon, tue, wed]);
  });

  test('deleteOutsideRange rimuove solo ciò che è fuori dai limiti (PL-10)', () async {
    final store = PlanDayLocalStore(db);
    final mon = DateTime(2026, 9, 7);
    final sun = mon.add(const Duration(days: 6));
    final farBefore = mon.subtract(const Duration(days: 30));
    final farAfter = mon.add(const Duration(days: 30));

    await store.upsertAll([_day(farBefore), _day(mon), _day(sun), _day(farAfter)]);
    await store.deleteOutsideRange(mon, sun);

    final remaining = await db.select(db.localPlanDays).get();
    expect(remaining.map((r) => r.date), containsAll([mon, sun]));
    expect(remaining, hasLength(2));
  });
}
