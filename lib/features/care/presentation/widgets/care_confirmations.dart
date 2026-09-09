import 'package:flutter/material.dart';

import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';

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
      title: Text(context.l10n.careRevokeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            asNutritionist
                ? context.l10n.careRevokeNutritionistSideBody
                : context.l10n.careRevokeNutritionistBody,
            style: typography.bodyMedium.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            asNutritionist ? context.l10n.careRevokeYouKeep : context.l10n.careRevokeNutritionistKeeps,
            style: typography.label.copyWith(color: colors.textPrimary),
          ),
          Text(
            context.l10n.careRevokeKeepsList,
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            asNutritionist ? context.l10n.careRevokeYouLose : context.l10n.careRevokeNutritionistLoses,
            style: typography.label.copyWith(color: colors.textPrimary),
          ),
          Text(
            context.l10n.careRevokeLosesList,
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
