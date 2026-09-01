import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/plan_status.dart';

/// CV-10, CV-11, CV-12, 4.5 interfaccia.md: conferma dell'eliminazione di
/// un piano. Rafforzata (elenco delle conseguenze) per Sospeso e
/// Concluso, dove si perde il lavoro già svolto sul periodo (CV-12);
/// semplice per Bozza e Programmato, dove nulla si è ancora
/// materializzato. Mai proposta per un piano Attivo, che CV-11 esclude
/// dall'eliminazione a monte — i chiamanti non offrono l'azione in quel
/// caso.
Future<bool> confirmDeletePlan(BuildContext context, PlanStatus status) async {
  final colors = context.colors;
  final rafforzata = status == PlanStatus.suspended || status == PlanStatus.completed;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: const Text('Eliminare il piano?'),
      content: rafforzata
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Andranno perdute in modo definitivo, per questo periodo:'),
                const SizedBox(height: AppSpacing.xs),
                Text('•  le giornate e le spunte di consumo', style: TextStyle(color: colors.textSecondary)),
                Text('•  le statistiche di aderenza', style: TextStyle(color: colors.textSecondary)),
              ],
            )
          : const Text('L\'operazione non può essere annullata.'),
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
