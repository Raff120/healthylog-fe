import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../dietplan/presentation/slot_type_presentation.dart';
import '../data/statistics_models.dart';
import '../providers/statistics_providers.dart';
import 'statistics_formatting.dart';
import 'widgets/breakdown_row.dart';
import 'widgets/statistics_headline.dart';
import 'widgets/statistics_period_menu.dart';
import 'widgets/weekly_bar_chart.dart';

/// Segmento **Aderenza** di *Statistiche* (11.1 interfaccia.md): valore
/// complessivo, andamento settimanale, disaggregazione per tipo di pasto e
/// per giorno della settimana.
///
/// AD-15: l'intera sezione presenta i dati in forma neutra — nessuna
/// soglia di merito, nessun colore di giudizio, nessun punteggio, nessuna
/// denominazione qualificativa. Il valore è reso in colore primario, mai
/// in colore di stato. AD-16: nessun messaggio commenta l'andamento, in
/// senso favorevole o sfavorevole; nessuna notifica ne discende.
///
/// AD-17, AD-18: nessun confronto con altri Utenti, nessuna classifica,
/// nessun obiettivo di aderenza suggerito.
class AdherenceView extends ConsumerWidget {
  const AdherenceView({super.key, required this.statistics});

  final AdherenceStatistics statistics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final periodIndex = ref.watch(selectedAdherencePeriodIndexProvider);
    final shown = _shownValue(periodIndex);
    final excluded = describeExcludedDays(statistics.suspendedDays, statistics.uncoveredDays);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      children: [
        // ST-10: sul piano con più periodi, l'alternanza fra il calcolo
        // complessivo e quello per singolo periodo — i due dati non sono
        // omogenei e la sola somma ne occulterebbe l'andamento.
        if (statistics.hasMultiplePeriods) ...[
          _PeriodBreakdownSelector(statistics: statistics, selectedIndex: periodIndex),
          const SizedBox(height: AppSpacing.sm),
        ],
        StatisticsHeadline(
          value: shown.value == null ? null : formatPercentage(shown.value!),
          unit: shown.value == null ? null : '%',
          caption: shown.caption,
          // AD-8: la didascalia è il selettore del periodo. Sul singolo
          // periodo di svolgimento non lo è: lì la didascalia descrive il
          // periodo scelto col controllo soprastante (ST-10).
          onCaptionTap: periodIndex != null
              ? null
              : (anchor) => showStatisticsPeriodMenu(anchor, ref, statistics.period),
        ),
        if (excluded != null && periodIndex == null)
          Text(excluded, style: typography.caption.copyWith(color: colors.textSecondary)),
        // AD-14: l'andamento ha senso su più settimane. Sull'orizzonte
        // *Settimana* ve n'è una sola, e una barra sola non è un
        // andamento: la sezione non compare (vedi decisioni.md).
        if (statistics.weekly.length > 1) ...[
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Andamento settimanale',
            child: WeeklyBarChart(
              bars: [
                for (final week in statistics.weekly)
                  BarDatum(
                    label: formatWeekLabel(week.weekStart),
                    value: week.value,
                    valueLabel: week.value == null ? '' : '${formatPercentage(week.value!)}%',
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: 'Per tipo di pasto',
          // AD-13: serve a riconoscere quali momenti della giornata
          // risultino più difficili da rispettare.
          child: Column(
            children: [
              for (final bucket in statistics.bySlotType)
                BreakdownRow(
                  icon: bucket.slotType.icon,
                  label: bucket.slotType.displayName,
                  value: bucket.value == null ? null : '${formatPercentage(bucket.value!)}%',
                  fraction: bucket.value == null ? null : bucket.value! / 100,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: 'Per giorno della settimana',
          // AD-13, LO-11: sette righe, dal lunedì alla domenica — servono a
          // riconoscere i giorni ricorrenti in cui il piano viene meno.
          child: Column(
            children: [
              for (final bucket in statistics.byWeekday)
                BreakdownRow(
                  label: bucket.weekday.label,
                  value: bucket.value == null ? null : '${formatPercentage(bucket.value!)}%',
                  fraction: bucket.value == null ? null : bucket.value! / 100,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  ({double? value, String caption}) _shownValue(int? periodIndex) {
    if (periodIndex != null && periodIndex < statistics.periods.length) {
      final period = statistics.periods[periodIndex];
      final end = period.endDate == null ? 'in corso' : formatDay(period.endDate!);
      return (value: period.value, caption: 'Periodo dal ${formatDay(period.startDate)} a $end');
    }
    return (
      value: statistics.value,
      caption: describePeriod(statistics.period, statistics.from, statistics.to, statistics.planName),
    );
  }
}

/// ST-9, ST-10: segmented control secondario fra il complessivo e ciascun
/// periodo di svolgimento attraversato dal piano.
class _PeriodBreakdownSelector extends ConsumerWidget {
  const _PeriodBreakdownSelector({required this.statistics, required this.selectedIndex});

  final AdherenceStatistics statistics;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppSegmentedControl(
      labels: [
        'Complessivo',
        for (var index = 0; index < statistics.periods.length; index++) '${index + 1}° periodo',
      ],
      selectedIndex: selectedIndex == null ? 0 : selectedIndex! + 1,
      onSelect: (index) =>
          ref.read(selectedAdherencePeriodIndexProvider.notifier).select(index == 0 ? null : index - 1),
    );
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
