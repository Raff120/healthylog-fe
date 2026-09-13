import 'package:flutter/widgets.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/formats.dart';
import '../../../l10n/l10n_context.dart';

/// CD-3, 7.2 interfaccia.md: il conflitto di sovrapposizione (PA-8)
/// indicato con il piano che lo genera. AS-15: al Nutrizionista il piano
/// redatto da altri è indicato per il solo periodo occupato, senza
/// denominazione. Condiviso dalla creazione del piano e dalla modifica
/// del suo periodo.
String describePlanOverlap(BuildContext context, Object error) {
  final body = error.asApiException?.body as Map?;
  final conflictingName = body?['conflictingPlanName'] as String?;
  final conflictingStart = body?['conflictingStartDate'] as String?;
  final conflictingEnd = body?['conflictingEndDate'] as String?;
  if (conflictingName != null) return context.l10n.planOverlapWithName(conflictingName);
  if (conflictingStart == null) return context.l10n.errorPlanPeriodOverlap;
  if (conflictingEnd == null) return context.l10n.planOverlapNoticeOpen(_formatIso(context, conflictingStart));
  return context.l10n.planOverlapNotice(_formatIso(context, conflictingStart), _formatIso(context, conflictingEnd));
}

String _formatIso(BuildContext context, String iso) {
  final parsed = DateTime.tryParse(iso);
  return parsed == null ? iso : formatDate(context, parsed);
}
