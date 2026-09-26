import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../workout/presentation/widgets/week_day_workouts.dart';
import '../../data/plan_day.dart';
import '../../data/plan_day_coverage.dart';
import '../../domain/plan_day_date.dart';
import '../../providers/meal_swap_providers.dart';
import '../../providers/plan_day_providers.dart';
import '../weekday_presentation.dart';
import 'swap_confirmations.dart';
import 'week_slot_row.dart';
import '../../../../app/navigation/bottom_bar_insets.dart';

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
    final member = ref.watch(selectedGroupMemberProvider);
    final rangeState = ref.watch(planDayRangeProvider(weekStart, to, userId: member));
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
          SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
        ),
      );
    });
    // IN-28: l'inversione di giornate, con il medesimo trattamento.
    ref.watch(daySwapControllerProvider);
    ref.listen(daySwapControllerProvider, (previous, next) {
      next?.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
        ),
      );
    });

    return rangeState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          describeApiError(context, error.asApiException?.code ?? ''),
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl + bottomBarInset(context),
      ),
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomBarInset(context),
      ),
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
///
/// IN-28, 6.5 interfaccia.md: il tocco prolungato sull'intestazione avvia
/// l'inversione della giornata intera. Durante la selezione il pannello
/// intero è il bersaglio, e i suoi slot non reagiscono al tocco.
class _DayCard extends ConsumerStatefulWidget {
  const _DayCard({required this.day, required this.isToday, required this.onSelectDay});

  final PlanDay day;
  final bool isToday;
  final ValueChanged<DateTime> onSelectDay;

  @override
  ConsumerState<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends ConsumerState<_DayCard> {
  /// 6.5: la ragione del rifiuto si dà a chi insiste, non al primo tocco.
  bool _incompatibleTapped = false;

  /// 6.5, 4.5: come per gli slot, lo scambio si compie previa conferma e
  /// la rinuncia lascia attiva la selezione.
  Future<void> _confirmAndSwap(DaySwapOrigin origin) async {
    final confirmed = await confirmDaySwap(context, firstDate: origin.date, secondDate: widget.day.date);
    if (!confirmed || !mounted) return;
    ref.read(daySwapControllerProvider.notifier).swap(
          origin,
          widget.day.date,
          userId: ref.read(selectedGroupMemberProvider),
        );
  }

  void _onSelectionTap(DaySwapOrigin origin, MealSwapHighlight highlight) {
    switch (highlight) {
      case MealSwapHighlight.origin:
        ref.read(daySwapSelectionProvider.notifier).cancel();
      case MealSwapHighlight.compatible:
        _confirmAndSwap(origin);
      case MealSwapHighlight.incompatible:
        if (_incompatibleTapped) {
          final reason = daySwapRejectionReason(origin, widget.day)!;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeApiError(context, reason))));
        }
        setState(() => _incompatibleTapped = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final day = widget.day;
    final isToday = widget.isToday;
    final outOfPlan = day.coverage != PlanDayCoverage.active;

    // CU-2, UT-12: il Cuoco inverte anche sul piano di un membro, il
    // membro semplice resta in consultazione — come per gli slot.
    final member = ref.watch(selectedGroupMemberProvider);
    final readOnly = member != null && !ref.watch(isCookProvider);
    final daySelection = ref.watch(daySwapSelectionProvider);
    final slotSelection = ref.watch(mealSwapSelectionProvider);
    if (daySelection == null) _incompatibleTapped = false;
    final highlight = daySelection == null ? null : daySwapHighlightFor(daySelection, day);
    final canStart = !readOnly && daySelection == null && slotSelection == null && isDaySwapOriginEligible(day);

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: switch (highlight) {
          MealSwapHighlight.origin => Border.all(color: colors.accent, width: 2),
          MealSwapHighlight.compatible => Border.all(color: colors.accent, width: 1),
          _ => null,
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => widget.onSelectDay(day.date),
            onLongPress: canStart
                ? () => ref.read(daySwapSelectionProvider.notifier).start(DaySwapOrigin.of(day))
                : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isToday || highlight == MealSwapHighlight.origin ? colors.accentSubtle : Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          weekdayLabel(context, weekdayOf(day.date)),
                          style: typography.titleMedium.copyWith(
                            color: outOfPlan ? colors.textTertiary : colors.textPrimary,
                          ),
                        ),
                        Text('${day.date.day}', style: typography.caption.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                    // NP-1, 6.4: il nome personale della giornata, che la
                    // proiezione del proprietario soltanto reca (NP-2).
                    if (day.dayName != null)
                      Text(
                        day.dayName!,
                        style: typography.caption.copyWith(color: colors.accent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
            child: outOfPlan
                ? _Caption(text: _outOfPlanCaption(context, day.coverage))
                : day.slots.isEmpty
                    ? _Caption(text: context.l10n.planNoMealsPlanned)
                    : Column(children: [for (final slot in day.slots) WeekSlotRow(day: day, slot: slot)]),
          ),
          // VS-6, 6.4: gli allenamenti in coda al pannello, in sola
          // presentazione. CU-10: assenti sulla settimana di un altro
          // membro del Gruppo.
          if (member == null) WeekDayWorkouts(weekStart: startOfWeek(day.date), date: day.date),
          const SizedBox(height: AppSpacing.xxs),
        ],
      ),
    );

    if (daySelection == null) return card;
    // 6.5: le giornate non ammesse al 40%, e il pannello intero risponde
    // al tocco in luogo dei suoi elementi.
    return Opacity(
      opacity: highlight == MealSwapHighlight.incompatible ? 0.4 : 1,
      child: Semantics(
        button: true,
        selected: highlight == MealSwapHighlight.origin,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onSelectionTap(daySelection, highlight!),
          child: IgnorePointer(child: card),
        ),
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
String _outOfPlanCaption(BuildContext context, PlanDayCoverage coverage) => switch (coverage) {
      PlanDayCoverage.none => context.l10n.weekNoPlan,
      PlanDayCoverage.scheduled => context.l10n.weekPlanNotStarted,
      PlanDayCoverage.suspended => context.l10n.planSuspended,
      PlanDayCoverage.completed => context.l10n.weekPlanCompleted,
      PlanDayCoverage.active => '',
    };
