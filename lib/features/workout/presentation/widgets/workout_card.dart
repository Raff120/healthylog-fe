import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/formats.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/workout_models.dart';
import '../workout_activity_presentation.dart';

/// Card di un allenamento registrato (10.1 interfaccia.md).
///
/// Sostituisce la voce d'elenco alta 68: pastiglia circolare con l'icona
/// dello sport, denominazione, calorie come valore principale e data in
/// colore terziario. Le calorie sono il dato che l'Utente cerca quando
/// scorre l'elenco, e qui si leggono senza cercarle — restano comunque
/// facoltative (CB-1) e la card senza di esse non presenta alcun vuoto.
///
/// CB-8, CB-9: il valore è del singolo allenamento cui si riferisce; qui
/// non compare alcun totale né alcuna media.
///
/// RA-13: un'icona a 16 distingue l'allenamento svolto a fronte di una
/// pianificazione. RA-14: il tocco conduce alla modifica, dove è
/// consentito — la scheda del Paziente lo omette (AL-17, AL-18).
class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key, required this.workout, this.onTap});

  final Workout workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final calories = workout.caloriesBurned;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ActivityBadge(workout: workout),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            workoutActivityName(context, workout.activityCode, workout.activityType),
                            style: typography.bodyLarge.copyWith(color: colors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (workout.fromPlanning) ...[
                          const SizedBox(width: AppSpacing.xxs),
                          Icon(Icons.event_available, size: 16, color: colors.textTertiary),
                        ],
                      ],
                    ),
                    if (calories != null) _Calories(value: calories),
                    if (workout.note != null && workout.note!.isNotEmpty)
                      Text(
                        workout.note!,
                        style: typography.caption.copyWith(color: colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                formatDate(context, workout.date),
                style: typography.caption.copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2.5 interfaccia.md: l'icona dello sport su fondo d'accento attenuato.
/// L'icona conserva il tratto lineare; è il fondo a dare il rilievo.
class _ActivityBadge extends StatelessWidget {
  const _ActivityBadge({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: AppSpacing.minInteractiveTarget,
      height: AppSpacing.minInteractiveTarget,
      decoration: BoxDecoration(color: colors.accentSubtle, shape: BoxShape.circle),
      child: Icon(workoutActivityIcon(workout.activityCode), size: 20, color: colors.accent),
    );
  }
}

/// CB-3: il valore in chilocalorie, con l'unità accanto in corpo minore —
/// il numero si legge da solo, l'unità lo qualifica.
class _Calories extends StatelessWidget {
  const _Calories({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('$value', style: typography.displayLarge.copyWith(color: colors.accent)),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          context.l10n.workoutCaloriesUnit,
          style: typography.label.copyWith(color: colors.accent),
        ),
      ],
    );
  }
}
