import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/core/storage/plan_day_local_store.dart';
import 'package:healthylog/core/storage/records/local_plan_day_record.dart';
import 'package:healthylog/features/dietplan/data/plan_day.dart';
import 'package:healthylog/features/dietplan/data/plan_day_coverage.dart';
import 'package:healthylog/features/dietplan/data/plan_day_local_cache.dart';
import 'package:healthylog/features/dietplan/data/slot_item.dart';
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
          items: const [
            SlotItem(
              itemId: 'i1',
              kindCode: 'FOOD',
              name: 'Pasta al pomodoro',
              quantity: 80,
              unitCode: 'GRAM',
              alternatives: [SlotItemAlternative(kindCode: 'FOOD', name: 'Riso', quantity: 70, unitCode: 'GRAM')],
            ),
            SlotItem(itemId: 'i2', kindCode: 'RECIPE', name: 'Pasta fresca', recipeText: 'Cuocere...'),
          ],
          note: 'Con parmigiano',
          status: SlotStatus.consumed,
          replacementNote: 'Pizza al volo',
        ),
      ],
    );

/// Conversione tra [PlanDay] e la cache locale (PL-5, PL-6, F14):
/// `core/storage` non conosce questo DTO. PL-11bis: il mutamento di formato
/// svuota quanto è conservato anziché reinterpretarlo.
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
    expect(slot.items.map((item) => item.name), ['Pasta al pomodoro', 'Pasta fresca']);
    expect(slot.items.first.quantity, 80);
    expect(slot.items.first.unit, QuantityUnit.gram);
    expect(slot.items.first.alternatives.single.name, 'Riso');
    expect(slot.items.last.recipeText, 'Cuocere...');
    expect(slot.note, 'Con parmigiano');
    expect(slot.status, SlotStatus.consumed);
    expect(slot.replacementNote, 'Pizza al volo');
  });

  test('read su una data mai salvata restituisce null', () async {
    final cache = PlanDayLocalCache(PlanDayLocalStore(db));
    expect(await cache.read(DateTime(2026, 9, 7)), isNull);
  });

  /// CC-50, PL-11bis: quanto è stato scritto da una versione precedente non si
  /// reinterpreta — si svuota, e la cache si ricostituisce alla prima lettura
  /// riuscita (PL-11).
  /// CC-50, PL-11bis: quanto è stato scritto da una versione precedente non si
  /// reinterpreta — si svuota all'avvio della versione che muta il formato, e
  /// la cache si ricostituisce alla prima lettura riuscita (PL-11).
  test('le occorrenze scritte in un formato precedente sono svuotate', () async {
    final file = File('${Directory.systemTemp.createTempSync('healthylog').path}/cache.sqlite');
    addTearDown(() => file.parent.deleteSync(recursive: true));
    final today = dateOnly(DateTime.now());

    // Una base dati alla versione precedente, con dentro la forma vecchia:
    // contenuto testuale, nessun elemento.
    final vecchia = AppDatabase(NativeDatabase(file));
    await PlanDayLocalStore(vecchia).upsert(LocalPlanDayRecord(
      date: today,
      coverage: 'ACTIVE',
      planId: 'p1',
      planName: 'Dieta',
      planStartDate: null,
      planEndDate: null,
      slotsJson: jsonEncode([
        {
          'slotId': 's1',
          'type': 'LUNCH',
          'label': null,
          'order': 0,
          'content': 'Pasta al pomodoro',
          'note': null,
          'status': 'TO_CONSUME',
          'replacementNote': null,
        }
      ]),
    ));
    await vecchia.customStatement('PRAGMA user_version = 1');
    await vecchia.close();

    // Riaperta dalla versione che introduce gli elementi.
    final nuova = AppDatabase(NativeDatabase(file));
    addTearDown(nuova.close);
    final cache = PlanDayLocalCache(PlanDayLocalStore(nuova));

    expect(await cache.read(today), isNull);
  });

  test('il formato corrente non fa svuotare nulla', () async {
    final today = dateOnly(DateTime.now());
    final cache = PlanDayLocalCache(PlanDayLocalStore(db));
    await cache.save(_day(today));

    expect(await PlanDayLocalCache(PlanDayLocalStore(db)).read(today), isNotNull);
  });
}
