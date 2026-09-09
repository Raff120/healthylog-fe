import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../dietplan/presentation/slot_type_presentation.dart';
import '../../../statistics/data/statistics_models.dart';
import '../../../statistics/presentation/statistics_formatting.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../../statistics/presentation/statistics_presentation.dart';
import '../../../statistics/presentation/widgets/breakdown_row.dart';
import '../../../statistics/presentation/widgets/statistics_headline.dart';
import '../../../statistics/providers/statistics_providers.dart';

/// Statistiche del Paziente nel dettaglio del Nutrizionista (9.2
/// interfaccia.md, VA-7): aderenza, frequenza degli allenamenti con
/// l'obiettivo settimanale (OS-7) e andamento delle misure.
///
/// ST-16bis, CS-6: tutti i dati sono circoscritti ai periodi coperti dai
/// piani redatti dal professionista. La circoscrizione è applicata dal
/// server come criterio dell'interrogazione (CS-11): ciò che vi ricade
/// non è restituito e non si distingue dall'assenza di dati (CS-13). La
/// nota che accompagna i periodi esclusi non ne spiega la ragione, che
/// attiene a piani che il Nutrizionista non deve conoscere.
///
/// AD-15, SA-16, AN-11: i valori sono presentati in forma neutra, come
/// nella sezione *Statistiche* dell'Utente. VA-5: l'ordinamento per
/// aderenza dell'elenco risponde a un'esigenza di priorità professionale,
/// non è una graduatoria di merito, e nulla qui la qualifica.
///
/// L'orizzonte è il **mese** di calendario (AD-8, AD-9): 9.2 non ne
/// prescrive uno, e il mese è il termine di raffronto abituale della
/// visita (vedi decisioni.md).
class PatientStatisticsSection extends ConsumerWidget {
  const PatientStatisticsSection({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final query = StatisticsQuery(period: StatisticsPeriod.month, userId: patientId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(context.l10n.patientMonthStatisticsHeader, style: typography.overline.copyWith(color: colors.textTertiary)),
        const SizedBox(height: AppSpacing.xs),
        _Adherence(query: query),
        _Workouts(query: query),
        _Body(query: query),
      ],
    );
  }
}

class _Adherence extends ConsumerWidget {
  const _Adherence({required this.query});

  final StatisticsQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final statistics = ref.watch(adherenceStatisticsProvider(query));

    return statistics.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatisticsHeadline(
            value: data.value == null ? null : formatPercentage(data.value!),
            unit: data.value == null ? null : '%',
            caption: context.l10n.patientAdherenceWithPeriod(
                describePeriod(context, data.period, data.from, data.to, null)),
            // 9.2: le interruzioni non sono spiegate oltre.
            emptyText: context.l10n.statisticsNoDataForPeriod,
          ),
          for (final bucket in data.bySlotType)
            BreakdownRow(
              icon: bucket.slotType.icon,
              label: slotTypeLabel(context, bucket.slotType),
              value: bucket.value == null ? null : '${formatPercentage(bucket.value!)}%',
              fraction: bucket.value == null ? null : bucket.value! / 100,
            ),
          if (describeExcludedDays(context, data.suspendedDays, data.uncoveredDays) case final note?)
            Text(note, style: typography.caption.copyWith(color: colors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: colors.dividerLight),
        ],
      ),
    );
  }
}

class _Workouts extends ConsumerWidget {
  const _Workouts({required this.query});

  final StatisticsQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final statistics = ref.watch(workoutStatisticsProvider(query));

    return statistics.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            data.total == 1 ? context.l10n.workoutStatsTotalDone(1) : context.l10n.workoutStatsTotalDone(data.total),
            style: typography.bodyLarge.copyWith(color: colors.textPrimary),
          ),
          // OS-7, SA-6: l'obiettivo compare se in quelle settimane ve n'era
          // uno e se ricadono nei periodi di titolarità; altrimenti nulla,
          // senza segnalarne la mancanza.
          if (data.hasGoal)
            Text(
              context.l10n.workoutStatsGoalProgressWeekly(data.goalDone!, data.goal!),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          if (data.planned > 0)
            Text(
              context.l10n.workoutStatsPlanProgress(data.planned, data.plannedDone),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: colors.dividerLight),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.query});

  final StatisticsQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final statistics = ref.watch(measurementStatisticsProvider(query));
    // LO-4, LO-7: le unità sono quelle del Nutrizionista che consulta, non
    // quelle del Paziente: il valore conservato è unico e la scelta è di
    // sola presentazione.
    final units = ref.watch(unitSystemProvider);

    return statistics.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          if (data.series.isEmpty)
            Text(
              context.l10n.statisticsNoDataForPeriod,
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            )
          else
            for (final series in data.series)
              // AN-10, AN-11: la variazione col proprio segno e senza
              // qualificazioni; la direzione desiderabile non è
              // determinabile dal sistema.
              Text(
                series.change == null
                    ? context.l10n.patientMeasureSingleValue(bodyMeasureLabel(context, series.measure))
                    : context.l10n.patientMeasureChange(
                        bodyMeasureLabel(context, series.measure),
                        _signed(context, bodyMeasureToDisplay(series.measure, series.change!, units)),
                        bodyMeasureUnit(context, series.measure, units),
                      ),
                style: typography.bodyMedium.copyWith(color: colors.textPrimary),
              ),
        ],
      ),
    );
  }

  static String _signed(BuildContext context, double change) {
    final value = change.abs().toStringAsFixed(1);
    if (change > 0) return context.l10n.signedPositive(value);
    if (change < 0) return context.l10n.signedNegative(value);
    return value;
  }
}
