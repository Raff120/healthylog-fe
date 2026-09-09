import 'package:flutter/material.dart';

import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';

/// GE-12: uscita volontaria, conferma semplice — riservata a chi non è
/// Proprietario. Il Proprietario con altri membri deve prima trasferire
/// la proprietà (2.5 funzionale, nota ³; CU-8; 8.2 interfaccia.md) prima
/// di poter uscire a sua volta; il Proprietario unico membro non trova
/// affatto questa azione, ma quella di scioglimento
/// ([confirmDissolveGroup]).
Future<bool> confirmLeaveGroup(BuildContext context) async {
  final colors = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.groupLeaveTitle),
      content: Text(context.l10n.groupLeaveKeepsData),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Esci', style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// 2.5 funzionale (nota ³), CU-8, 8.2 interfaccia.md: il Proprietario con
/// altri membri non può abbandonare direttamente — deve prima
/// trasferire la proprietà a un altro membro. La successione automatica
/// di GR-16 resta come comportamento del solo endpoint (robustezza per
/// vie diverse dall'interfaccia standard, es. l'eliminazione
/// dell'account di F31): l'azione "Esci" non la invoca mai per un
/// Proprietario con altri membri.
Future<void> explainOwnerMustTransferBeforeLeaving(BuildContext context) {
  final colors = context.colors;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.groupTransferFirstTitle),
      content: Text(
        context.l10n.groupTransferFirstBody,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(context.l10n.commonUnderstood)),
      ],
    ),
  );
}

/// GE-12: scioglimento del Gruppo, sempre con conferma rafforzata —
/// comporta l'uscita di tutti i membri (GR-12: nessuna perdita di dati,
/// che restano ai singoli).
Future<bool> confirmDissolveGroup(BuildContext context) async {
  final colors = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.groupDissolveTitle),
      content: Text(context.l10n.groupDissolveBody),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Sciogli', style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// GE-6: rimozione di un membro, conferma semplice — il rimosso conserva
/// integralmente i propri dati (nessuna perdita, a differenza
/// dell'eliminazione di un piano).
Future<bool> confirmRemoveMember(BuildContext context, String memberName) async {
  final colors = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.groupRemoveMemberTitle),
      content: Text(context.l10n.groupRemoveMemberBody(memberName)),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Rimuovi', style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// GE-9: trasferimento della proprietà, conferma rafforzata — non
/// annullabile se non per volontà del nuovo Proprietario (GR-15).
Future<bool> confirmTransferOwnership(BuildContext context, String memberName) async {
  final colors = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.groupTransferOwnershipTitle),
      content: Text(
        context.l10n.groupTransferOwnershipBody(memberName),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Trasferisci')),
      ],
    ),
  );
  return confirmed ?? false;
}
