import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_error_messages.dart';
import '../data/plan_day.dart';
import '../data/plan_day_coverage.dart';
import '../domain/plan_day_date.dart';
import '../providers/plan_day_providers.dart';
import 'widgets/date_selector.dart';
import 'widgets/meal_card.dart';

/// *Piano*, vista giornaliera (6.1, 6.2 interfaccia.md; VG-1..VG-4):
/// schermata principale dell'applicazione, destinazione di *Piano* nella
/// barra di navigazione. Sostituisce integralmente `PlaceholderHomeScreen`
/// (F06).
///
/// Il segmented control *Giorno* · *Settimana* di 6.1 non compare ancora:
/// la vista settimanale è compito di F16, e un controllo con un solo
/// segmento funzionante sarebbe un'illusione di scelta. Il ritorno a
/// oggi (VG-19) è un task successivo di questa stessa feature; la natura
/// della giornata quando non ordinaria (VG-18, PA-10) è qui presentata in
/// forma minima, da completare con la striscia informativa e gli stati
/// vuoti previsti da 4.4/6.1 interfaccia.md.
class DailyViewScreen extends ConsumerWidget {
  const DailyViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final selectedDate = ref.watch(selectedDayProvider);
    final dayState = ref.watch(planDayProvider(selectedDate));

    void selectDate(DateTime date) =>
        ref.read(selectedDayProvider.notifier).select(date);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Piano',
          style: typography.titleMedium.copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            DateSelector(selectedDate: selectedDate, onSelect: selectDate),
            Expanded(
              // 6.2: "lo scorrimento orizzontale del contenuto cambia
              // giorno" — lo stesso gesto della riga dei giorni, qui
              // applicato al contenuto sottostante.
              child: GestureDetector(
                key: const Key('dailyViewContentSwipe'),
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -200) {
                    selectDate(selectedDate.add(const Duration(days: 1)));
                  } else if (velocity > 200) {
                    selectDate(selectedDate.subtract(const Duration(days: 1)));
                  }
                },
                child: dayState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      describeApiError(error.asApiException?.code ?? ''),
                      style: typography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  data: (day) => AnimatedSwitcher(
                    duration: AppSpacing.motionScreenTransition,
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(isoDate(day.date)),
                      child: _DayContent(day: day),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayContent extends StatelessWidget {
  const _DayContent({required this.day});

  final PlanDay day;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;

    if (day.coverage == PlanDayCoverage.suspended ||
        day.coverage == PlanDayCoverage.none) {
      // VG-18, PA-10: sostituiti dagli stati vuoti previsti da 4.4
      // interfaccia.md in un task successivo di questa feature.
      final message = day.coverage == PlanDayCoverage.suspended
          ? 'Piano sospeso'
          : 'Nessun piano per questo giorno';
      return Center(
        child: Text(
          message,
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      );
    }

    if (day.slots.isEmpty) {
      return Center(
        child: Text(
          'Nessun pasto previsto',
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      );
    }

    // VG-3: nell'ordinamento definito dal piano — già garantito dal
    // backend (GG-8), nessun riordino qui.
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      itemCount: day.slots.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.xs),
      // VG-4: tutti gli slot restano sempre visibili, quale sia il loro
      // stato — nessun filtro qui.
      itemBuilder: (context, index) => MealCard(slot: day.slots[index]),
    );
  }
}
