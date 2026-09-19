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
import 'water_entries_sheet.dart';
import 'water_goal_sheet.dart';

/// L'idratazione in coda al segmento *Aderenza* (11.1 interfaccia.md;
/// 8.6 funzionale).
///
/// Presenta **due cose sole** (AQ-25): quanta acqua si è bevuta in
/// ciascuna giornata, e se in quella giornata l'obiettivo sia stato
/// raggiunto. Nessun valore aggregato — nessuna media, nessun totale di
/// periodo, nessuna proiezione.
///
/// La distinzione fra giornata raggiunta e non raggiunta si vale della
/// **sola evidenza**, pieno e tenue della medesima tinta d'accento: mai
/// un colore di merito, mai un premio, mai una striscia di giornate
/// consecutive, mai un punteggio (AQ-23).
///
/// AQ-11, AQ-26: l'obiettivo giornaliero si imposta **da qui**, dove la
/// linea di riferimento che ne discende è sotto gli occhi. Stava fra i
/// dati personali, dove non lo si trovava (segnalato dall'utente, vedi
/// decisioni.md). AQ-17 resta osservato: la vista quotidiana continua a
/// non recare né totale né obiettivo.
///
/// La contiguità con l'aderenza è di presentazione e **non di calcolo**
/// (AQ-30): l'idratazione non concorre in alcun modo al valore che sta
/// sopra, e nessuna somma li unisce.
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
          _Chart(statistics: statistics),
        // AQ-11, AQ-12: l'obiettivo e il comando che lo imposta,
        // riservati all'Utente sui propri dati — il Nutrizionista non si
        // dà gli obiettivi del Paziente (AQ-28bis per analogia).
        // Compare anche senza alcuna registrazione: è allora che un
        // traguardo si dà, non dopo.
        if (query.userId == null) ...[
          const SizedBox(height: AppSpacing.xs),
          const _GoalRow(),
        ],
        // AQ-28, AQ-28bis: l'elenco da cui si rettifica, riservato
        // all'Utente sui propri dati — il Nutrizionista consulta.
        if (query.userId == null && !statistics.isEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('waterEntriesButton'),
              onPressed: () => showWaterEntriesSheet(
                context,
                from: statistics.from,
                to: statistics.to,
              ),
              icon: const Icon(Icons.list, size: 20),
              label: Text(context.l10n.waterEntriesOpen),
              style: TextButton.styleFrom(foregroundColor: colors.accent),
            ),
          ),
        ],
      ],
    );
  }
}

class _Chart extends ConsumerWidget {
  const _Chart({required this.statistics});

  final WaterStatistics statistics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitSystemProvider);
    final goal = statistics.referenceGoalMl;

    return WeeklyBarChart(
      bars: [
        // AQ-25, AQ-27: una barra per giornata dell'orizzonte, comprese
        // quelle prive di registrazione, che vi stanno a zero — la barra
        // assente direbbe che quel giorno non esiste.
        for (final day in statistics.daily)
          BarDatum(
            label: formatDayOfMonth(context, day.date),
            value: day.totalMl.toDouble(),
            valueLabel: formatVolume(context, day.totalMl, units),
            // AQ-23: pieno dove l'obiettivo è stato raggiunto, tenue
            // altrove e dove obiettivo non ve n'era.
            emphasised: day.goalReached,
          ),
      ],
      // AQ-26: la linea orizzontale di riferimento all'obiettivo, con le
      // modalità della linea del peso obiettivo (AN-6).
      referenceValue: goal?.toDouble(),
      referenceLabel: goal == null ? null : formatVolume(context, goal, units),
    );
  }
}

/// AQ-11, AQ-26: l'obiettivo giornaliero e il comando che lo imposta.
///
/// AQ-23: il valore e nulla più — nessun avanzamento, nessuna striscia
/// di giornate raggiunte, nessun punteggio. Quel che l'obiettivo fa lo
/// fa sul grafico sopra, dove distingue le barre.
class _GoalRow extends ConsumerWidget {
  const _GoalRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final units = ref.watch(unitSystemProvider);
    final goal = ref.watch(dailyWaterGoalProvider).value;

    return Row(
      children: [
        Expanded(
          child: Text(
            goal == null
                ? context.l10n.waterGoalNone
                : context.l10n.waterGoalReference(formatVolume(context, goal, units)),
            style: typography.bodyMedium.copyWith(
              color: goal == null ? colors.textSecondary : colors.textPrimary,
            ),
          ),
        ),
        TextButton(
          key: const Key('waterGoalButton'),
          onPressed: () => showWaterGoalSheet(context),
          child: Text(goal == null ? context.l10n.commonSet : context.l10n.commonEdit),
        ),
      ],
    );
  }
}
