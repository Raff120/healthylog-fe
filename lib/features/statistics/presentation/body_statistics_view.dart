import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../l10n/l10n_context.dart';
import '../../measurement/presentation/measurements_view.dart' show showMeasurementDetail;
import '../../measurement/presentation/widgets/measurement_list_tile.dart';
import '../data/statistics_models.dart';
import '../providers/statistics_providers.dart';
import 'statistics_formatting.dart';
import '../../../l10n/units.dart';
import '../../identity/providers/profile_providers.dart';
import 'statistics_presentation.dart';
import 'widgets/measure_line_chart.dart';
import 'widgets/statistics_headline.dart';
import 'widgets/statistics_period_menu.dart';

/// Segmento **Corpo** di *Statistiche* (11.3 interfaccia.md): selettore
/// della misura, grafico, variazione nel periodo ed elenco delle
/// misurazioni.
///
/// AN-11: la variazione è presentata in forma neutra, col segno che le
/// compete e in colore primario — nessun colore di merito, nessuna
/// freccia verde o rossa, nessuna denominazione di progresso o regresso.
/// La direzione desiderabile non è determinabile dal sistema: un calo di
/// peso non è per definizione un miglioramento.
///
/// AN-12: nessuna elaborazione ulteriore — non medie mobili, non
/// proiezioni, non tassi di variazione, non indici derivati dal rapporto
/// tra peso e altezza. AN-19: l'andamento non è messo in relazione con
/// l'aderenza né con la frequenza degli allenamenti.
class BodyStatisticsView extends ConsumerWidget {
  const BodyStatisticsView({super.key, required this.statistics});

  final MeasurementStatistics statistics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    if (statistics.series.isEmpty) {
      // AN-2: non si presentano grafici vuoti; 4.4: constatazione neutra.
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            context.l10n.bodyStatsNoMeasurements,
            style: typography.titleMedium.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final selected = ref.watch(selectedBodyMeasureProvider);
    // LO-4, LO-7, LO-8: la conversione è di sola presentazione e si
    // applica per ciò stesso a tutta la serie, quale ne sia l'epoca.
    final units = ref.watch(unitSystemProvider);
    final series = statistics.series.firstWhere(
      (candidate) => candidate.measure == selected,
      orElse: () => statistics.series.first,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      children: [
        // AN-1, AN-2: chip scorribili con le sole misure per le quali
        // esistano registrazioni nel periodo. Una misura per volta.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              for (final candidate in statistics.series)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: ChoiceChip(
                    label: Text(bodyMeasureLabel(context, candidate.measure)),
                    selected: candidate.measure == series.measure,
                    onSelected: (_) =>
                        ref.read(selectedBodyMeasureProvider.notifier).select(candidate.measure),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: MeasureLineChart(
            points: [
              for (final point in series.points)
                MeasurePoint(
                  date: point.date,
                  value: bodyMeasureToDisplay(series.measure, point.value, units),
                  source: point.source,
                ),
            ],
            unit: bodyMeasureUnit(context, series.measure, units),
            // AN-6, AN-7: la linea di riferimento riguarda il solo peso.
            targetValue: series.measure.hasTarget && statistics.targetWeightKg != null
                ? weightToDisplay(statistics.targetWeightKg!, units)
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AN-10: la differenza rispetto al primo valore del periodo.
              StatisticsHeadline(
                value: series.change == null
                    ? null
                    : _formatChange(context, bodyMeasureToDisplay(series.measure, series.change!, units)),
                unit: series.change == null ? null : bodyMeasureUnit(context, series.measure, units),
                caption: describePeriod(context, 
                  statistics.period,
                  statistics.from,
                  statistics.to,
                  statistics.planName,
                ),
                emptyText: context.l10n.bodyStatsSingleValue,
                // AD-8, AN-13: la didascalia è il selettore del periodo.
                onCaptionTap: (anchor) =>
                    showStatisticsPeriodMenu(anchor, ref, statistics.period),
              ),
              // AN-5: la legenda della fonte compare solo se le due fonti
              // coesistono — altrimenti non vi è nulla da distinguere.
              if (series.points.any((point) => point.fromNutritionist) &&
                  series.points.any((point) => !point.fromNutritionist))
                Text(
                  context.l10n.bodyStatsNutritionistLegend,
                  style: typography.caption.copyWith(color: colors.textSecondary),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(context.l10n.bodyMeasurementsTitle, style: typography.overline.copyWith(color: colors.textTertiary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _PeriodMeasurements(from: statistics.from, to: statistics.to),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  /// AN-10, AN-11: differenza assoluta con il proprio segno, nell'unità
  /// propria della grandezza.
  static String _formatChange(BuildContext context, double change) {
    final value = change.abs().toStringAsFixed(1);
    if (change > 0) return context.l10n.signedPositive(value);
    if (change < 0) return context.l10n.signedNegative(value);
    return value;
  }
}

/// AN-4: l'elenco delle misurazioni del periodo, in ordine cronologico
/// decrescente, con la medesima struttura di 10.3.
class _PeriodMeasurements extends ConsumerWidget {
  const _PeriodMeasurements({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final measurements = ref.watch(periodMeasurementsProvider((from: from, to: to)));

    return measurements.maybeWhen(
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final measurement in items) ...[
            MeasurementListTile(
              measurement: measurement,
              onTap: () => showMeasurementDetail(context, measurement),
            ),
            Divider(height: 1, color: colors.dividerLight),
          ],
        ],
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
