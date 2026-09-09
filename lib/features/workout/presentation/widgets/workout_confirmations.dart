import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/workout_models.dart';

/// AL-6, RA-9, 4.5 interfaccia.md: la registrazione di un secondo
/// allenamento nella medesima giornata è preceduta da una conferma
/// semplice, che presenta l'allenamento già registrato per quella data —
/// è ciò che rende riconoscibile la duplicazione involontaria, il caso
/// più frequente.
///
/// RA-10: confermata la volontà, la registrazione procede senza ulteriori
/// ostacoli: allenarsi più volte in un giorno è una circostanza legittima.
Future<bool> confirmDuplicateWorkout(
  BuildContext context, {
  required List<Workout> existing,
}) async {
  final colors = context.colors;
  final typography = context.typography;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(
        existing.length == 1
            ? context.l10n.workoutDuplicateSingle
            : context.l10n.workoutDuplicateMany(existing.length),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final workout in existing)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Text(
                workout.caloriesBurned == null
                    ? '• ${workout.activityType}'
                    : '• ${workout.activityType} — ${workout.caloriesBurned} kcal',
                style: typography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.workoutRecordAnyway),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// RA-16, 4.5: l'eliminazione richiede conferma semplice. RA-17: non
/// elimina la pianificazione sottostante — l'allenamento torna
/// semplicemente previsto e non svolto (AL-14).
Future<bool> confirmDeleteWorkout(BuildContext context, {required bool fromPlanning}) async {
  final colors = context.colors;
  final typography = context.typography;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(context.l10n.workoutDeleteConfirm),
      content: fromPlanning
          ? Text(
              context.l10n.workoutDeleteKeepsPlanning,
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            )
          : null,
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
