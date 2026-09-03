import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/plan_day.dart';
import '../data/plan_day_coverage.dart';
import '../domain/plan_day_date.dart';
import '../providers/diet_plan_providers.dart';
import '../providers/meal_swap_providers.dart';
import '../providers/plan_day_providers.dart';
import 'widgets/date_selector.dart';
import 'widgets/meal_card.dart';
import 'widgets/plan_status_banner.dart';
import 'widgets/segmented_view_control.dart';
import 'widgets/week_selector.dart';
import 'widgets/weekly_view.dart';

/// *Piano* (6.1 interfaccia.md; VG-1..VG-4, VS-1): schermata principale
/// dell'applicazione, destinazione di *Piano* nella barra di
/// navigazione. Raccoglie le due viste sul medesimo contenuto — giorno
/// (6.2) e settimana (6.4) — dietro il segmented control
/// dell'intestazione (6.1), condividendo un solo riferimento temporale
/// (`selectedDayProvider`, VS-14).
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final viewMode = ref.watch(selectedPlanViewProvider);
    final selectedDate = ref.watch(selectedDayProvider);
    final swapSelection = ref.watch(mealSwapSelectionProvider);

    void selectDate(DateTime date) => ref.read(selectedDayProvider.notifier).select(date);
    void showDay(DateTime date) {
      // VS-14: il tocco su un giorno della settimana conduce alla
      // giornaliera di quel giorno, conservando il riferimento.
      selectDate(date);
      ref.read(selectedPlanViewProvider.notifier).select(PlanViewMode.day);
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        // 6.5 interfaccia.md: in modalità di selezione l'intestazione è
        // sostituita da "Scegli dove spostarlo" e l'azione Annulla.
        title: swapSelection == null
            ? SegmentedViewControl(
                value: viewMode,
                onChanged: (mode) => ref.read(selectedPlanViewProvider.notifier).select(mode),
              )
            : Text('Scegli dove spostarlo', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
        actions: swapSelection == null
            ? null
            : [
                TextButton(
                  onPressed: () => ref.read(mealSwapSelectionProvider.notifier).cancel(),
                  child: const Text('Annulla'),
                ),
              ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppSpacing.motionScreenTransition,
          transitionBuilder: (child, animation) => SlideTransition(
            // 6.1: "Settimana entra da destra, Giorno da sinistra".
            position: Tween(
              begin: Offset(viewMode == PlanViewMode.week ? 0.05 : -0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: viewMode == PlanViewMode.day
              ? _DailyView(key: const ValueKey('day'), selectedDate: selectedDate, onSelect: selectDate)
              : _WeeklyTab(key: const ValueKey('week'), selectedDate: selectedDate, onNavigate: selectDate, onSelectDay: showDay),
        ),
      ),
    );
  }
}

class _DailyView extends ConsumerWidget {
  const _DailyView({super.key, required this.selectedDate, required this.onSelect});

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.typography;
    final colors = context.colors;
    final dayState = ref.watch(planDayProvider(selectedDate));

    return Column(
      children: [
        DateSelector(selectedDate: selectedDate, onSelect: onSelect),
        Expanded(
          // 6.2: "lo scorrimento orizzontale del contenuto cambia
          // giorno" — lo stesso gesto della riga dei giorni, qui
          // applicato al contenuto sottostante.
          child: GestureDetector(
            key: const Key('dailyViewContentSwipe'),
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -200) {
                onSelect(selectedDate.add(const Duration(days: 1)));
              } else if (velocity > 200) {
                onSelect(selectedDate.subtract(const Duration(days: 1)));
              }
            },
            child: dayState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  describeApiError(error.asApiException?.code ?? ''),
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
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
    );
  }
}

class _WeeklyTab extends StatelessWidget {
  const _WeeklyTab({
    super.key,
    required this.selectedDate,
    required this.onNavigate,
    required this.onSelectDay,
  });

  final DateTime selectedDate;

  /// Frecce e "Questa settimana" (VS-12, VS-13): sposta il riferimento
  /// temporale senza lasciare la vista settimanale.
  final ValueChanged<DateTime> onNavigate;

  /// VS-14: tocco sull'intestazione di un giorno, passa alla vista
  /// giornaliera di quel giorno.
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final weekStart = startOfWeek(selectedDate);
    final currentWeekStart = startOfWeek(dateOnly(DateTime.now()));
    final isCurrentWeek = weekStart == currentWeekStart;

    return Column(
      children: [
        WeekSelector(
          weekStart: weekStart,
          onPrevious: () => onNavigate(weekStart.subtract(const Duration(days: 7))),
          onNext: () => onNavigate(weekStart.add(const Duration(days: 7))),
          onCurrentWeek: isCurrentWeek ? null : () => onNavigate(currentWeekStart),
        ),
        Expanded(child: WeeklyView(weekStart: weekStart, onSelectDay: onSelectDay)),
      ],
    );
  }
}

/// VG-18, PA-10: natura della giornata quando non ordinaria. Sospensione
/// e assenza di piano sostituiscono l'intero contenuto con lo stato
/// vuoto previsto da 4.4 interfaccia.md; programmato e concluso restano
/// visibili con la striscia informativa di 6.1 sopra il contenuto — non
/// sono condizioni che impediscono la consultazione, solo che la
/// segnalano.
class _DayContent extends ConsumerWidget {
  const _DayContent({required this.day});

  final PlanDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (day.coverage) {
      case PlanDayCoverage.suspended:
        // ref.watch (non solo read) tiene vivo il controller autoDispose
        // per la durata dell'operazione, oltre a pilotare l'indicatore
        // di attesa del pulsante (2.6).
        final resuming =
            ref.watch(dietPlanLifecycleControllerProvider)?.isLoading ?? false;
        return EmptyStateView(
          icon: Icons.pause_circle_outline,
          title: 'Piano sospeso',
          text: 'Riprenderà quando lo deciderai',
          // UT-8: l'unico caso possibile prima di F22 è l'Utente
          // autonomo, sempre titolare del proprio piano.
          actionLabel: 'Riprendi',
          actionLoading: resuming,
          onAction: () async {
            await ref
                .read(dietPlanLifecycleControllerProvider.notifier)
                .resume(day.planId!);
            ref.invalidate(planDayProvider(day.date));
          },
        );
      case PlanDayCoverage.none:
        final ownedPlans = ref.watch(ownedDietPlansProvider);
        final everCreated = ownedPlans.value?.isNotEmpty ?? true;
        return everCreated
            ? const EmptyStateView(
                icon: Icons.event_busy,
                title: 'Nessun piano per questo giorno',
              )
            : EmptyStateView(
                icon: Icons.calendar_month_outlined,
                title: 'Inizia da qui',
                text: 'Crea il tuo primo piano alimentare',
                actionLabel: 'Crea piano',
                onAction: () => context.push('/diet-plans/new'),
              );
      case PlanDayCoverage.scheduled:
      case PlanDayCoverage.completed:
      case PlanDayCoverage.active:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (day.coverage == PlanDayCoverage.scheduled)
              PlanStatusBanner(
                text: 'Il piano inizia il ${_formatDate(day.planStartDate!)}',
              )
            else if (day.coverage == PlanDayCoverage.completed)
              PlanStatusBanner(
                text: 'Piano concluso il ${_formatDate(day.planEndDate!)}',
              ),
            Expanded(
              child: _SlotsOrEmpty(
                slots: day.slots,
                date: day.date,
                canCheck: day.coverage == PlanDayCoverage.active,
              ),
            ),
          ],
        );
    }
  }
}

class _SlotsOrEmpty extends StatelessWidget {
  const _SlotsOrEmpty({required this.slots, required this.date, required this.canCheck});

  final List<PlanDaySlot> slots;
  final DateTime date;

  /// SP-11: false su Programmato e Concluso, gli unici casi in cui questo
  /// widget è raggiunto con `coverage` diverso da Attivo (Sospeso e
  /// assenza di piano sostituiscono l'intero contenuto, vedi
  /// `_DayContent`).
  final bool canCheck;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      // GG-7: condizione legittima, non un errore — nessuna azione.
      return const EmptyStateView(
        icon: Icons.restaurant_outlined,
        title: 'Nessun pasto previsto',
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
      itemCount: slots.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.xs),
      // VG-4: tutti gli slot restano sempre visibili, quale sia il loro
      // stato — nessun filtro qui.
      itemBuilder: (context, index) =>
          MealCard(slot: slots[index], date: date, canCheck: canCheck),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}
