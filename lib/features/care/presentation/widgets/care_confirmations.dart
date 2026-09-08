import 'package:flutter/material.dart';

import '../../../../app/theme/theme_context.dart';

/// CP-14, CP-18, 4.5 interfaccia.md: la revoca del collegamento è
/// sempre a conferma rafforzata ed espone cosa il Nutrizionista
/// conserverà (CP-16) e cosa perderà (CP-17) — lo stesso testo da
/// entrambe le parti, perché le conseguenze sono le stesse.
Future<bool> confirmRevokeCareLink(BuildContext context, {required bool asNutritionist}) async {
  final colors = context.colors;
  final typography = context.typography;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: const Text('Revocare il collegamento?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            asNutritionist
                ? 'Perderai immediatamente ogni accesso ai dati della persona e ogni facoltà sui suoi piani.'
                : 'Il nutrizionista perderà immediatamente ogni accesso ai tuoi dati e ogni facoltà sul tuo piano, '
                    'che resterà a tua disposizione.',
            style: typography.bodyMedium.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            asNutritionist ? 'Conserverai:' : 'Il nutrizionista conserverà:',
            style: typography.label.copyWith(color: colors.textPrimary),
          ),
          Text(
            '• gli schemi dei piani che ha redatto, con il periodo di validità;\n'
            '• le misurazioni che ha registrato personalmente;\n'
            '• i dati anagrafici essenziali.',
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            asNutritionist ? 'Non conserverai:' : 'Non conserverà:',
            style: typography.label.copyWith(color: colors.textPrimary),
          ),
          Text(
            '• spunte, inversioni e statistiche di aderenza;\n'
            '• allenamenti e misurazioni registrate dalla persona.',
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Revoca', style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
