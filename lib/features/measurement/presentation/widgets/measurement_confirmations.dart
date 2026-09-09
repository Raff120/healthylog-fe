import 'package:flutter/material.dart';

import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';

/// PR-16, 4.5 interfaccia.md: l'eliminazione di una misurazione richiede
/// conferma semplice — operazione con conseguenze, ma il dato perduto è
/// una singola rilevazione, non un insieme di dati derivati.
Future<bool> confirmDeleteMeasurement(BuildContext context) async {
  final colors = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.measurementDeleteConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.commonDelete, style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
