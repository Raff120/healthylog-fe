import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/statistics_models.dart';
import '../../providers/statistics_providers.dart';

/// Selettore del periodo (11.1 interfaccia.md, AD-8): *Settimana* ·
/// *Mese* · *Piano*, comune ai tre segmenti e conservato tra le sessioni.
///
/// Non è una barra di comandi propria ma un menu ancorato alla didascalia
/// del valore complessivo, che ne dichiara già il periodo: due pillole
/// identiche impilate — una per la sezione, una per il periodo — si
/// leggevano come lo stesso comando ripetuto (segnalato dall'utente, vedi
/// decisioni.md). Il comando sta ora accanto al dato che governa.
///
/// AD-10: gli orizzonti sono i tre di AD-8, senza intervallo
/// personalizzato.
Future<void> showStatisticsPeriodMenu(
  BuildContext context,
  WidgetRef ref,
  StatisticsPeriod current,
) async {
  final anchor = context.findRenderObject() as RenderBox?;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (anchor == null || overlay == null) return;

  final topLeft = anchor.localToGlobal(Offset.zero, ancestor: overlay);
  final bottomRight = anchor.localToGlobal(
    anchor.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );
  final selected = await showMenu<StatisticsPeriod>(
    context: context,
    position: RelativeRect.fromLTRB(
      topLeft.dx,
      bottomRight.dy,
      overlay.size.width - bottomRight.dx,
      overlay.size.height - bottomRight.dy,
    ),
    items: [
      for (final period in StatisticsPeriod.values)
        CheckedPopupMenuItem(
          value: period,
          checked: period == current,
          child: Text(period.label),
        ),
    ],
  );
  if (selected == null || selected == current) return;
  await ref.read(selectedStatisticsPeriodProvider.notifier).select(selected);
  // ST-10: cambiando orizzonte l'alternanza fra complessivo e singolo
  // periodo non ha più oggetto.
  ref.read(selectedAdherencePeriodIndexProvider.notifier).select(null);
}
