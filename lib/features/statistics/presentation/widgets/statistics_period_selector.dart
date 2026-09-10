import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/statistics_models.dart';
import '../../providers/statistics_providers.dart';
import '../statistics_presentation.dart';

/// Selettore del periodo (11.1 interfaccia.md, AD-8): *Settimana* ·
/// *Mese* · *Piano*, comune ai tre segmenti e conservato tra le sessioni
/// (3.2).
///
/// Sta nell'intestazione, a sinistra delle pillole dei segmenti, dove
/// *Piano* tiene il selettore del membro del Gruppo (4.2): governa la
/// schermata, non il contenuto, e resta perciò raggiungibile qualunque
/// cosa il contenuto mostri. Viveva prima nella didascalia del valore
/// complessivo, che nel segmento *Corpo* privo di misurazioni non esiste:
/// non c'era allora modo di cambiare orizzonte se non passando a un altro
/// segmento (segnalato dall'utente, vedi decisioni.md).
///
/// AD-10: gli orizzonti sono i tre di AD-8, senza intervallo
/// personalizzato.
class StatisticsPeriodSelector extends ConsumerWidget {
  const StatisticsPeriodSelector({super.key});

  /// Quanto l'intestazione riserva al selettore. Il resto va alle pillole
  /// dei tre segmenti, che si riducono allo spazio disponibile: su schermo
  /// stretto è il selettore a cedere per primo — l'etichetta si tronca —
  /// non il comando dei segmenti.
  static double widthIn(BuildContext context) =>
      context.breakpoint.isCompact ? 108 : 150;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final current = ref.watch(selectedStatisticsPeriodProvider).value;
    // Finché la preferenza si carica non si dichiara un orizzonte che
    // potrebbe non essere quello scelto.
    if (current == null) return const SizedBox.shrink();

    return PopupMenuButton<StatisticsPeriod>(
      color: colors.surface,
      initialValue: current,
      onSelected: (period) => _select(ref, period, current),
      itemBuilder: (_) => [
        for (final period in StatisticsPeriod.values)
          CheckedPopupMenuItem(
            value: period,
            checked: period == current,
            child: Text(statisticsPeriodLabel(context, period)),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                statisticsPeriodLabel(context, current),
                style: typography.label.copyWith(color: colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _select(
    WidgetRef ref,
    StatisticsPeriod period,
    StatisticsPeriod current,
  ) async {
    if (period == current) return;
    await ref.read(selectedStatisticsPeriodProvider.notifier).select(period);
    // ST-10: cambiando orizzonte l'alternanza fra complessivo e singolo
    // periodo non ha più oggetto.
    ref.read(selectedAdherencePeriodIndexProvider.notifier).select(null);
  }
}
