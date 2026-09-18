import 'package:flutter/material.dart';

import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';

/// AQ-8, 4.5 interfaccia.md: l'annullamento di un'aggiunta richiede
/// **conferma semplice**. Il dato perduto è una registrazione sola e la
/// si può rifare, ma non si torna indietro dal tocco: è il medesimo
/// livello dell'eliminazione di un allenamento o di una misurazione
/// *(segnalato dall'utente)*.
///
/// L'aggiunta, che è reversibile di qui, resta invece senza conferma
/// (AQ-5): confermarla abituerebbe a confermare senza leggere proprio
/// dove la conferma serve.
Future<bool> confirmRemoveWaterEntry(BuildContext context, String amount) async {
  final colors = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.waterRemoveConfirm(amount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.commonRemove, style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
