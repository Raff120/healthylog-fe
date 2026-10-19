import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../l10n/l10n_context.dart';
import '../../providers/diet_plan_providers.dart';
import 'personal_text_dialog.dart';

/// NP-1, EP-12: apre la nota dello slot dello schema [slotId] nel dialogo
/// delle annotazioni, con [currentNote] se già scritta; confermata, la
/// salva — vuota, la toglie. Dalla pagina delle note (7.6), che presenta
/// lo schema e non una data.
Future<void> editPersonalSchemaSlotNote(
  BuildContext context,
  WidgetRef ref, {
  required String planId,
  required String slotId,
  String? currentNote,
}) async {
  final note = await showPersonalTextDialog(
    context,
    title: context.l10n.personalNoteLabel,
    label: context.l10n.personalNoteLabel,
    initialText: currentNote ?? '',
    maxLength: 500,
    multiline: true,
  );
  if (note == null || !context.mounted) return;
  await ref.read(personalSlotNoteControllerProvider.notifier).save(planId, slotId, note.isEmpty ? null : note);
  if (!context.mounted) return;
  ref
      .read(personalSlotNoteControllerProvider)
      ?.whenOrNull(
        error: (error, _) =>
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? '')))),
      );
}
