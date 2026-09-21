import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../l10n/l10n_context.dart';
import '../../providers/diet_plan_providers.dart';
import 'personal_text_dialog.dart';

/// NP-1: legge la nota personale del piano e la apre nel dialogo delle
/// annotazioni; confermata, la salva — vuota, la toglie. Comune ai punti
/// da cui il proprietario la raggiunge: la card del piano in corso (7.1),
/// il menu della giornaliera (6.2) e il dettaglio del piano (7.5).
Future<void> editPersonalPlanNote(BuildContext context, WidgetRef ref, String planId) async {
  final String? current;
  try {
    current = await ref.read(personalPlanNoteProvider(planId).future);
  } catch (error) {
    if (context.mounted) _showError(context, error);
    return;
  }
  if (!context.mounted) return;
  final note = await showPersonalTextDialog(
    context,
    title: context.l10n.personalPlanNotesTitle,
    label: context.l10n.personalNoteLabel,
    initialText: current ?? '',
    maxLength: 2000,
    multiline: true,
  );
  if (note == null || !context.mounted) return;
  await ref.read(personalPlanNoteControllerProvider.notifier).save(planId, note.isEmpty ? null : note);
  if (!context.mounted) return;
  ref.read(personalPlanNoteControllerProvider)?.whenOrNull(error: (error, _) => _showError(context, error));
}

void _showError(BuildContext context, Object error) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
    );
