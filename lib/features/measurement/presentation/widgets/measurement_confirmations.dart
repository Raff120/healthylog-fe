import 'package:flutter/material.dart';

import '../../../../app/theme/theme_context.dart';

/// PR-16, 4.5 interfaccia.md: l'eliminazione di una misurazione richiede
/// conferma semplice — operazione con conseguenze, ma il dato perduto è
/// una singola rilevazione, non un insieme di dati derivati.
Future<bool> confirmDeleteMeasurement(BuildContext context) async {
  final colors = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: const Text('Eliminare questa misurazione?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Elimina', style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
