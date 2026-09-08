import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../data/plan_day.dart';
import '../../data/plan_day_coverage.dart';
import '../../domain/plan_day_date.dart';
import '../../providers/meal_swap_providers.dart';
import '../../providers/plan_day_providers.dart';
import 'week_slot_row.dart';

/// Contenuto della vista settimanale (6.2 funzionale, VS-1; 6.4
/// interfaccia.md): i sette giorni della settimana che inizia a
/// [weekStart] (lunedì, LO-11), in elenco verticale su schermo stretto
/// (MP-6) o in colonne affiancate da `expanded` in su.
///
/// Semplificazione dichiarata rispetto a 6.4: su schermo ampio la
/// griglia è per colonne di giorno (ciascuna un pannello compatto),
/// non per righe di tipo-slot come descritto in interfaccia — quella
/// disposizione ricalca la modalità affiancata (6.3), non ancora
/// realizzata (F20); vedi decisioni.md.
class WeeklyView extends ConsumerWidget {
  const WeeklyView({super.key, required this.weekStart, required this.onSelectDay});

  final DateTime weekStart;

  /// VS-14: il tocco sull'intestazione di un giorno conduce alla vista
  /// giornaliera di quel giorno.
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final to = weekStart.add(const Duration(days: 6));
    final rangeState = ref.watch(planDayRangeProvider(weekStart, to));
    final today = dateOnly(DateTime.now());

    // Tiene in vita il controller (autoDispose) per la durata della
    // richiesta, sullo stesso criterio di MealCard per la spunta.
    ref.watch(mealSwapControllerProvider);
    // CF-9/CF-12 non si applicano (F15 fuori ambito): un rifiuto del
    // server (MS-21, es. per uno stato mutato nel frattempo) è comunque
    // un esito ordinario, non un errore dell'Utente — barra temporanea
    // neutra, non un avviso allarmante.
    ref.listen(mealSwapControllerProvider, (previous, next) {
      next?.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
        ),
      );
    });

    return rangeState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          describeApiError(error.asApiException?.code ?? ''),
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ),
      data: (days) => context.breakpoint.isAtLeastExpanded
          ? _WeekGrid(days: days, today: today, onSelectDay: onSelectDay)
          : _WeekPanelList(days: days, today: today, onSelectDay: onSelectDay),
    );
  }
}

class _WeekPanelList extends StatelessWidget {
  const _WeekPanelList({required this.days, required this.today, required this.onSelectDay});

  final List<PlanDay> days;
  final DateTime today;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
      itemCount: days.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) => _DayCard(
        day: days[index],
        isToday: days[index].date == today,
        onSelectDay: onSelectDay,
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.days, required this.today, required this.onSelectDay});

  final List<PlanDay> days;
  final DateTime today;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < days.length; i++) ...[
            Expanded(
              child: _DayCard(day: days[i], isToday: days[i].date == today, onSelectDay: onSelectDay),
            ),
            if (i < days.length - 1) const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

/// Pannello di un giorno (6.4 interfaccia.md): intestazione (nome del
/// giorno, data, fondo in accento tenue se corrente — VS-5) e, sotto,
/// le righe sintetiche degli slot (VS-3) ovvero una constatazione in
/// `caption` per un giorno fuori dal piano attivo (VS-7).
class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.isToday, required this.onSelectDay});

  final PlanDay day;
  final bool isToday;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final outOfPlan = day.coverage != PlanDayCoverage.active;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => onSelectDay(day.date),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isToday ? colors.accentSubtle : Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      weekdayOf(day.date).label,
                      style: typography.titleMedium.copyWith(
                        color: outOfPlan ? colors.textTertiary : colors.textPrimary,
                      ),
                    ),
                    Text('${day.date.day}', style: typography.caption.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
            child: outOfPlan
                ? _Caption(text: _outOfPlanCaption(day.coverage))
                : day.slots.isEmpty
                    ? const _Caption(text: 'Nessun pasto previsto')
                    : Column(children: [for (final slot in day.slots) WeekSlotRow(day: day, slot: slot)]),
          ),
          const SizedBox(height: AppSpacing.xxs),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.xs),
      child: Text(text, style: typography.caption.copyWith(color: colors.textTertiary)),
    );
  }
}

/// VS-7, PA-10: la stessa distinzione già fatta dalla vista giornaliera
/// (`_DayContent` in `plan_screen.dart`), qui condensata in una singola
/// riga di constatazione anziché in uno stato vuoto a schermo intero.
String _outOfPlanCaption(PlanDayCoverage coverage) => switch (coverage) {
      PlanDayCoverage.none => 'Nessun piano',
      PlanDayCoverage.scheduled => 'Piano non ancora iniziato',
      PlanDayCoverage.suspended => 'Piano sospeso',
      PlanDayCoverage.completed => 'Piano concluso',
      PlanDayCoverage.active => '',
    };
