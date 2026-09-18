import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/formats.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../../statistics/presentation/widgets/weekly_bar_chart.dart';
import '../../../statistics/providers/statistics_providers.dart';
import '../../data/hydration_models.dart';
import '../../providers/hydration_providers.dart';
import '../hydration_formatting.dart';

/// L'idratazione in coda al segmento *Aderenza* (11.1 interfaccia.md;
/// 8.6 funzionale): media giornaliera, obiettivo e andamento per giornata.
///
/// La collocazione qui, e non in un quarto segmento, discende dalla
/// natura del dato — condotta alimentare quotidiana, come l'aderenza — e
/// dallo spazio dell'intestazione, che porta già tre segmenti e il
/// selettore dell'orizzonte.
///
/// **La contiguità è di presentazione e non di calcolo** (AQ-30):
/// l'idratazione non concorre in alcun modo al valore di aderenza, che
/// resta sopra, separato, e nessuna somma li unisce.
///
/// AQ-23: le barre non mutano colore al raggiungimento dell'obiettivo né
/// al mancato raggiungimento; nessuna striscia di giornate consecutive,
/// nessun conteggio di traguardi raggiunti.
class WaterStatisticsSection extends ConsumerWidget {
  const WaterStatisticsSection({super.key, required this.query});

  final StatisticsQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final statistics = ref.watch(waterStatisticsProvider(query)).value;
    // La sezione non compare finché la lettura non si risolve, né quando
    // fallisce: l'aderenza che la sovrasta è già a schermo, e un errore
    // in coda a essa non le appartiene.
    if (statistics == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.water_drop_outlined, size: 16, color: colors.textTertiary),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              context.l10n.waterSectionTitle,
              style: typography.overline.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (statistics.isEmpty)
          // AQ-27, AD-4: nessuna registrazione nell'orizzonte è una
          // constatazione, non uno zero.
          Text(
            context.l10n.statisticsNoDataYet,
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          )
        else
          _Content(statistics: statistics),
      ],
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.statistics});

  final WaterStatistics statistics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final units = ref.watch(unitSystemProvider);
    final goal = statistics.referenceGoalMl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.waterAveragePerDay(formatVolume(context, statistics.averageMl!, units)),
          // Colore primario, mai di stato: non è un giudizio (AQ-23).
          style: typography.titleLarge.copyWith(color: colors.textPrimary),
        ),
        if (goal != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            context.l10n.waterGoalReference(formatVolume(context, goal, units)),
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
        // AQ-28: la media muove dalla prima registrazione compiuta, e lo
        // dichiara quando l'orizzonte comprende giornate anteriori — che
        // non attestano un consumo nullo, ma che la funzione non era in
        // uso.
        if (statistics.averageFrom != null && statistics.averageFrom!.isAfter(statistics.from)) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            context.l10n.waterAverageFrom(formatDayAndMonth(context, statistics.averageFrom!)),
            style: typography.caption.copyWith(color: colors.textTertiary),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        // AQ-25, AQ-27: una barra per giornata dell'orizzonte, comprese
        // quelle prive di registrazione, che vi stanno a zero — la barra
        // assente direbbe che quel giorno non esiste.
        WeeklyBarChart(
          bars: [
            for (final day in statistics.daily)
              BarDatum(
                label: formatDayOfMonth(context, day.date),
                value: day.totalMl.toDouble(),
                valueLabel: formatVolume(context, day.totalMl, units),
              ),
          ],
          // AQ-26: la linea orizzontale di riferimento all'obiettivo, con
          // le modalità della linea del peso obiettivo (AN-6).
          referenceValue: goal?.toDouble(),
          referenceLabel: goal == null ? null : formatVolume(context, goal, units),
        ),
      ],
    );
  }
}
