import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../l10n/l10n_context.dart';
import '../data/statistics_models.dart';
import 'statistics_formatting.dart';
import 'widgets/breakdown_row.dart';
import 'widgets/statistics_headline.dart';
import 'widgets/statistics_period_menu.dart';
import 'widgets/weekly_bar_chart.dart';

/// Segmento **Allenamenti** di *Statistiche* (11.2 interfaccia.md):
/// numero di sessioni, confronto con l'obiettivo, confronto con la
/// pianificazione, andamento settimanale, distribuzione per tipo.
///
/// SA-16: valori in forma neutra, senza soglie di merito né denominazioni
/// valutative. La barra dell'obiettivo non muta colore al mancato
/// raggiungimento (OS-13), e il superamento non produce alcuna
/// celebrazione. SA-17: nessuna notifica, nessun messaggio valutativo.
///
/// **Calorie**: non compaiono in alcuna forma aggregata — nessun totale,
/// nessuna media, nessun grafico (CB-9, SA-8). Il dato è inserito a stima
/// e da fonti eterogenee; aggregarlo gli attribuirebbe un'attendibilità
/// che non possiede (CB-10).
class WorkoutStatisticsView extends ConsumerWidget {
  const WorkoutStatisticsView({super.key, required this.statistics});

  final WorkoutStatistics statistics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final maxByType = statistics.byActivityType.isEmpty ? 1 : statistics.byActivityType.first.count;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      children: [
        StatisticsHeadline(
          value: '${statistics.total}',
          unit: statistics.total == 1 ? 'allenamento' : 'allenamenti',
          caption: describePeriod(context, 
            statistics.period,
            statistics.from,
            statistics.to,
            statistics.planName,
          ),
          // AD-8: la didascalia è il selettore del periodo, comune ai tre
          // segmenti.
          onCaptionTap: (anchor) => showStatisticsPeriodMenu(anchor, ref, statistics.period),
        ),
        // SA-15: sull'orizzonte del piano i giorni di sospensione, esclusi
        // dall'aderenza, concorrono invece qui per intero (SA-14).
        if (statistics.divergesFromAdherence)
          Text(
            context.l10n.workoutStatsSuspendedNotice(statistics.suspendedDays),
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        const SizedBox(height: AppSpacing.lg),
        // SA-3, SA-6: la sezione compare solo se l'obiettivo è impostato;
        // in sua assenza nulla segnala che manchi.
        if (statistics.hasGoal) ...[
          _Section(
            title: context.l10n.workoutStatsGoalComparison,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BreakdownRow(
                  label: context.l10n.workoutStatsGoalProgress(statistics.goalDone!, statistics.goal!),
                  value: null,
                  fraction: statistics.goal! == 0 ? null : statistics.goalDone! / statistics.goal!,
                ),
                if (statistics.goalWeeks > 1)
                  Text(
                    context.l10n.workoutStatsGoalWeeksNotice(statistics.goalWeeks),
                    style: typography.caption.copyWith(color: colors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        // SA-5: distinto dal precedente e presentato separatamente —
        // l'obiettivo riguarda *quante volte*, la pianificazione *quando*.
        _Section(
          title: context.l10n.workoutStatsPlanComparison,
          child: Text(
            statistics.planned == 0
                ? context.l10n.workoutStatsNonePlannedInPeriod
                : context.l10n.workoutStatsPlanProgress(statistics.planned, statistics.plannedDone),
            style: typography.bodyMedium.copyWith(color: colors.textPrimary),
          ),
        ),
        // SA-11: come per l'aderenza, una barra sola non è un andamento.
        if (statistics.weekly.length > 1) ...[
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: context.l10n.workoutStatsWeeklyTrend,
            child: WeeklyBarChart(
              bars: [
                for (final week in statistics.weekly)
                  BarDatum(
                    label: formatWeekLabel(week.weekStart),
                    value: week.count.toDouble(),
                    valueLabel: '${week.count}',
                  ),
              ],
              // 11.2: quando l'obiettivo è impostato, una linea orizzontale di
              // riferimento ne indica il livello, come la linea del peso
              // obiettivo (AN-6).
              referenceValue: _referenceGoal()?.toDouble(),
              referenceLabel: _referenceGoal() == null ? null : 'obiettivo',
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: context.l10n.workoutStatsDistribution,
          // SA-7: le statistiche non distinguono gli allenamenti pianificati
          // da quelli spontanei — la distinzione resta nell'elenco (RA-13).
          child: statistics.byActivityType.isEmpty
              ? Text(
                  context.l10n.workoutStatsNoneRecordedInPeriod,
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                )
              : Column(
                  children: [
                    for (final entry in statistics.byActivityType)
                      BreakdownRow(
                        label: entry.activityType,
                        value: '${entry.count}',
                        fraction: entry.count / maxByType,
                      ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  /// SA-12: l'obiettivo di riferimento del grafico è quello dell'ultima
  /// settimana dell'orizzonte che ne aveva uno — le settimane trascorse
  /// conservano comunque il proprio nella lettura dei dati.
  int? _referenceGoal() {
    for (final week in statistics.weekly.reversed) {
      if (week.goal != null) return week.goal;
    }
    return null;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: typography.overline.copyWith(color: colors.textTertiary)),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}
