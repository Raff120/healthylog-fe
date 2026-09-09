import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/plan_status.dart';

/// CV-10, CV-11, CV-12, ST-14, 4.5 interfaccia.md: conferma
/// dell'eliminazione di un piano. Rafforzata (elenco delle conseguenze)
/// per Sospeso e Concluso, dove si perde il lavoro già svolto sul periodo
/// (CV-12); semplice per Bozza e Programmato, dove nulla si è ancora
/// materializzato. Mai proposta per un piano Attivo, che CV-11 esclude
/// dall'eliminazione a monte — i chiamanti non offrono l'azione in quel
/// caso.
///
/// ST-14: la perdita riguarda occorrenze, spunte, statistiche di aderenza
/// e storico delle inversioni di **tutti** i periodi del piano. ST-15:
/// allenamenti e misurazioni del medesimo intervallo sono dati
/// indipendenti (CV-13) e non ne risentono — la conferma lo dice, perché
/// il timore di perderli non trattenga da un'operazione che non li
/// tocca.
Future<bool> confirmDeletePlan(BuildContext context, PlanStatus status) async {
  final colors = context.colors;
  final rafforzata = status == PlanStatus.suspended || status == PlanStatus.completed;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.planDeleteTitle),
      content: rafforzata
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status == PlanStatus.completed
                      ? context.l10n.planDeleteLossAllPeriods
                      : context.l10n.planDeleteLossThisPeriod,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(context.l10n.planDeleteLossDays, style: TextStyle(color: colors.textSecondary)),
                Text(context.l10n.planDeleteLossStatistics, style: TextStyle(color: colors.textSecondary)),
                Text(context.l10n.planDeleteLossSwaps, style: TextStyle(color: colors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.planDeleteWorkoutsKept,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            )
          : Text(context.l10n.planDeleteIrreversible),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Elimina', style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
