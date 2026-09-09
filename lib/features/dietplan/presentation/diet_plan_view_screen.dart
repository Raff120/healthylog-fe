import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../l10n/l10n_context.dart';
import '../../statistics/data/statistics_models.dart';
import '../../statistics/presentation/statistics_formatting.dart';
import '../../statistics/presentation/widgets/breakdown_row.dart';
import '../../statistics/presentation/widgets/statistics_headline.dart';
import '../../statistics/providers/statistics_providers.dart';
import '../data/diet_plan.dart';
import '../data/meal_swap_log.dart';
import '../data/plan_status.dart';
import '../providers/diet_plan_providers.dart';
import '../providers/meal_swap_providers.dart';
import 'diet_plan_management_screen.dart' show planPeriodLabel;
import 'plan_status_presentation.dart';
import 'slot_type_presentation.dart';
import 'widgets/day_preview.dart';
import 'widgets/delete_plan_dialog.dart';

/// Dettaglio di un piano Concluso (7.5 interfaccia.md, ST-7): sola
/// lettura, nella composizione prescritta — intestazione, periodi di
/// svolgimento se più d'uno, statistiche del periodo, schema settimanale,
/// storico delle inversioni.
///
/// ST-6: il dettaglio giornaliero delle occorrenze non compare qui; resta
/// raggiungibile navigando le date in *Piano* (VG-17).
///
/// ST-7 ammette anche la riattivazione (CV-7) e il salvataggio come
/// template (TP-5), tuttora rinviate insieme all'esportazione in PDF
/// (PV-13, F30): l'unica operazione presente resta l'eliminazione (CV-10).
///
/// F22: la stessa vista serve al Paziente per il piano redatto dal proprio
/// Nutrizionista, in qualunque stato (UT-8: sola lettura, senza
/// eliminazione né altre azioni) — l'etichetta segue lo stato.
class DietPlanViewScreen extends ConsumerWidget {
  const DietPlanViewScreen({super.key, required this.planId});

  final String planId;

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDeletePlan(context, PlanStatus.completed);
    if (!confirmed) return;
    if (!context.mounted) return;
    await ref.read(dietPlanLifecycleControllerProvider.notifier).delete(planId);
    if (!context.mounted) return;
    final state = ref.read(dietPlanLifecycleControllerProvider);
    state?.whenOrNull(
      data: (_) => context.pushReplacement('/profile/plans'),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final planState = ref.watch(dietPlanScheduleControllerProvider(planId));
    ref.watch(dietPlanLifecycleControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          planState.value?.name ?? 'Piano',
          style: typography.titleMedium.copyWith(color: colors.textPrimary),
        ),
        actions: [
          if (planState.value != null && planState.value!.status == PlanStatus.completed)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') _delete(context, ref);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'delete', child: Text('Elimina', style: TextStyle(color: colors.error))),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: planState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(context, error.asApiException?.code ?? ''),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          data: (plan) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(_statusLabel(context, plan.status), style: typography.overline.copyWith(color: colors.textTertiary)),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                planPeriodLabel(context, plan, _formatDate),
                style: typography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
              // ST-9: il piano riattivato presenta l'elenco dei periodi
              // attraversati, con date e aderenza di ciascuno.
              if (plan.hasMultiplePeriods) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(context.l10n.planViewPeriods),
                _PlanPeriods(plan: plan),
              ],
              // ST-4: le statistiche del periodo, nella forma ridotta di
              // 7.5 — il tocco conduce alla sezione *Statistiche* con il
              // periodo preselezionato.
              if (plan.status == PlanStatus.completed) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(context.l10n.planViewPeriodStatistics),
                _PlanStatistics(planId: plan.id),
              ],
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(context.l10n.planViewWeeklySchedule),
              for (final day in plan.weeklySchedule) DayPreview(day: day),
              // ST-5, IN-27: lo storico delle inversioni operate sul piano.
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(context.l10n.planViewSwapHistory),
              _SwapHistory(planId: plan.id),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: typography.overline.copyWith(color: colors.textTertiary)),
    );
  }
}

/// ST-9, ST-10: i periodi attraversati, ciascuno con le proprie date e la
/// propria aderenza. I due calcoli — complessivo e per singolo periodo —
/// non sono omogenei: un piano ripreso a distanza di mesi produce dati che
/// la sola somma occulterebbe, e l'alternanza fra i due si opera nella
/// sezione *Statistiche* (11.1).
class _PlanPeriods extends ConsumerWidget {
  const _PlanPeriods({required this.plan});

  final DietPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final statistics = ref.watch(
      adherenceStatisticsProvider(StatisticsQuery(period: StatisticsPeriod.plan, planId: plan.id)),
    );
    final periods = statistics.value?.periods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < plan.periods.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _periodLabel(context, plan.periods[index]),
                    style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                  ),
                ),
                if (periods != null && index < periods.length && periods[index].value != null)
                  Text(
                    '${formatPercentage(periods[index].value!)}%',
                    style: typography.label.copyWith(color: colors.textPrimary),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String _periodLabel(BuildContext context, DietPlanPeriod period) {
    final end = period.endDate == null ? context.l10n.planViewOngoing : formatDay(period.endDate!);
    return context.l10n.planViewPeriodRange(formatDay(period.startDate), end);
  }
}

/// ST-4: aderenza complessiva, per tipo di slot e per giorno della
/// settimana, in forma ridotta. AD-15: presentate qui come altrove in
/// forma neutra, senza soglie né colori di giudizio.
class _PlanStatistics extends ConsumerWidget {
  const _PlanStatistics({required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final statistics = ref.watch(
      adherenceStatisticsProvider(StatisticsQuery(period: StatisticsPeriod.plan, planId: planId)),
    );

    return statistics.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: CircularProgressIndicator(),
      )),
      error: (error, _) => Text(
        describeApiError(context, error.asApiException?.code ?? ''),
        style: typography.bodyMedium.copyWith(color: colors.textSecondary),
      ),
      data: (data) => InkWell(
        // 7.5: il tocco conduce alla sezione *Statistiche* con il periodo
        // preselezionato.
        onTap: () => context.push('/statistics?planId=$planId'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatisticsHeadline(
              value: data.value == null ? null : formatPercentage(data.value!),
              unit: data.value == null ? null : '%',
              caption: context.l10n.planViewOverallAdherence,
            ),
            if (describeExcludedDays(context, data.suspendedDays, data.uncoveredDays) case final note?)
              Text(note, style: typography.caption.copyWith(color: colors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            for (final bucket in data.bySlotType)
              BreakdownRow(
                icon: bucket.slotType.icon,
                label: slotTypeLabel(context, bucket.slotType),
                value: bucket.value == null ? null : '${formatPercentage(bucket.value!)}%',
                fraction: bucket.value == null ? null : bucket.value! / 100,
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.planViewOpenStatistics,
              style: typography.label.copyWith(color: colors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

/// ST-5, IN-24, IN-25: elenco cronologico decrescente, di sola lettura.
class _SwapHistory extends ConsumerWidget {
  const _SwapHistory({required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final history = ref.watch(mealSwapHistoryProvider(planId));

    return history.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => Text(
        describeApiError(context, error.asApiException?.code ?? ''),
        style: typography.bodyMedium.copyWith(color: colors.textSecondary),
      ),
      data: (logs) => logs.isEmpty
          // 4.4: constatazione neutra, mai la segnalazione di una mancanza.
          ? Text(
              context.l10n.planViewNoSwaps,
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final log in logs)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Text(
                      _describe(context, log),
                      style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                    ),
                  ),
              ],
            ),
    );
  }

  String _describe(BuildContext context, MealSwapLog log) =>
      '${formatDay(log.first.date)} ${slotTypeLabel(context, log.first.type)} '
      '↔ ${formatDay(log.second.date)} ${slotTypeLabel(context, log.second.type)}';
}

/// 7.5: la striscia di stato del piano concluso, in maiuscolo. L'Attivo
/// vi si presenta come "IN CORSO", non con il nome tecnico dello stato.
String _statusLabel(BuildContext context, PlanStatus status) =>
    (status == PlanStatus.active ? context.l10n.planViewOngoingUpper : planStatusLabel(context, status))
        .toUpperCase();
