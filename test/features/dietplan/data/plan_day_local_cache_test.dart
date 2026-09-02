import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/core/storage/plan_day_local_store.dart';
import 'package:healthylog/features/dietplan/data/plan_day.dart';
import 'package:healthylog/features/dietplan/data/plan_day_coverage.dart';
import 'package:healthylog/features/dietplan/data/plan_day_local_cache.dart';
import 'package:healthylog/features/dietplan/data/slot_status.dart';
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/domain/plan_day_date.dart';

PlanDay _day(DateTime date) => PlanDay(
      date: date,
      coverage: PlanDayCoverage.active,
      planId: 'p1',
      planName: 'Dieta',
      planStartDate: DateTime(2026, 1, 1),
      planEndDate: null,
      slots: [
        PlanDaySlot(
          slotId: 's1',
          type: SlotType.lunch,
          label: null,
          order: 0,
          content: 'Pasta al pomodoro',
          note: 'Con parmigiano',
          recipeName: 'Pasta fresca',
          recipeText: 'Cuocere...',
          status: SlotStatus.consumed,
        ),
      ],
    );

/// Conversione tra [PlanDay] e la cache locale (PL-5, PL-6, F14):
/// `core/storage` non conosce questo DTO.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('save/read: round trip fedele di tutti i campi, incluso lo slot', () async {
    final cache = PlanDayLocalCache(PlanDayLocalStore(db));
    // `save` pulisce anche fuori dalla settimana corrente reale (PL-10):
    // una data qualunque nel 2026 rischierebbe di essere rimossa subito
    // dopo il salvataggio se cade fuori da quella settimana.
    final today = DateTime.now();
    final day = _day(DateTime(today.year, today.month, today.day, 13, 45));

    await cache.save(day);
    final read = await cache.read(dateOnly(today));

    expect(read, isNotNull);
    expect(read!.date, dateOnly(day.date));
    expect(read.coverage, PlanDayCoverage.active);
    expect(read.planId, 'p1');
    expect(read.planName, 'Dieta');
    expect(read.planStartDate, DateTime(2026, 1, 1));
    expect(read.planEndDate, isNull);
    expect(read.slots, hasLength(1));
    final slot = read.slots.single;
    expect(slot.slotId, 's1');
    expect(slot.type, SlotType.lunch);
    expect(slot.content, 'Pasta al pomodoro');
    expect(slot.note, 'Con parmigiano');
    expect(slot.recipeName, 'Pasta fresca');
    expect(slot.recipeText, 'Cuocere...');
    expect(slot.status, SlotStatus.consumed);
  });

  test('read su una data mai salvata restituisce null', () async {
    final cache = PlanDayLocalCache(PlanDayLocalStore(db));
    expect(await cache.read(DateTime(2026, 9, 7)), isNull);
  });
}
