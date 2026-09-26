import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/features/dietplan/data/slot_status.dart';
import 'package:healthylog/features/dietplan/data/slot_type.dart';
import 'package:healthylog/features/dietplan/providers/meal_swap_providers.dart';
import 'package:healthylog/features/dietplan/providers/plan_day_providers.dart';

/// 6.5 interfaccia.md: l'inversione avviata dalla vista giornaliera vi
/// riporta al termine della selezione, qualunque ne sia l'esito.
void main() {
  final monday = DateTime(2026, 9, 28);
  final origin = MealSwapOrigin(
    planId: 'plan-1',
    date: monday,
    slotId: 'breakfast',
    type: SlotType.breakfast,
    status: SlotStatus.toConsume,
  );

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  /// Quanto fanno gli avvii di `MealCard` e della vista affiancata.
  void startFromDay({bool sideBySide = false}) {
    if (sideBySide) container.read(sideBySideModeProvider.notifier).disable();
    container.read(mealSwapSelectionProvider.notifier).start(
          origin,
          returnTo: SwapReturn(date: monday, sideBySide: sideBySide),
        );
    container.read(selectedPlanViewProvider.notifier).select(PlanViewMode.week);
    // Nella settimanale si può navigare prima di scegliere.
    container.read(selectedDayProvider.notifier).select(monday.add(const Duration(days: 3)));
  }

  test('al termine torna alla giornaliera della giornata di partenza', () {
    startFromDay();

    container.read(mealSwapSelectionProvider.notifier).cancel();

    expect(container.read(mealSwapSelectionProvider), isNull);
    expect(container.read(selectedPlanViewProvider), PlanViewMode.day);
    expect(container.read(selectedDayProvider), monday);
    expect(container.read(sideBySideModeProvider), isFalse);
  });

  test('avviata dall\'affiancata, vi torna (VG-12)', () {
    container.read(sideBySideModeProvider.notifier).enable();
    startFromDay(sideBySide: true);
    expect(container.read(sideBySideModeProvider), isFalse);

    container.read(mealSwapSelectionProvider.notifier).cancel();

    expect(container.read(sideBySideModeProvider), isTrue);
    expect(container.read(selectedPlanViewProvider), PlanViewMode.day);
  });

  test('avviata dalla settimanale, vi resta anche dopo un avvio precedente dalla giornaliera', () {
    startFromDay();
    container.read(mealSwapSelectionProvider.notifier).cancel();
    container.read(selectedPlanViewProvider.notifier).select(PlanViewMode.week);

    container.read(mealSwapSelectionProvider.notifier).start(origin);
    container.read(mealSwapSelectionProvider.notifier).cancel();

    expect(container.read(selectedPlanViewProvider), PlanViewMode.week);
  });

  test('il passaggio alla selezione delle giornate non è un termine', () {
    startFromDay();

    container.read(daySwapSelectionProvider.notifier).start(
          DaySwapOrigin(planId: 'plan-1', date: monday, statuses: const [SlotStatus.toConsume]),
        );

    expect(container.read(mealSwapSelectionProvider), isNull);
    expect(container.read(selectedPlanViewProvider), PlanViewMode.week);
  });
}
