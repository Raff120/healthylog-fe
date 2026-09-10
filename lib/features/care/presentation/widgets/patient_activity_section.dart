import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/formats.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../measurement/presentation/widgets/measurement_list_tile.dart';
import '../../../measurement/presentation/widgets/measurement_sheet.dart';
import '../../../measurement/providers/measurement_providers.dart';
import '../../../workout/data/workout_models.dart';
import '../../../workout/providers/workout_providers.dart';

/// Misurazioni e allenamenti del Paziente nel dettaglio (9.2
/// interfaccia.md), con il pulsante *Registra misurazione* che apre il
/// modulo di 11.3 (NU-12).
///
/// ST-16bis, CS-6: quanto vi compare è circoscritto ai periodi coperti
/// dai piani redatti dal Nutrizionista — salvo le misurazioni da lui
/// stesso registrate, sempre accessibili (CS-14). Le assenze non sono
/// spiegate oltre: la ragione attiene a piani che non deve conoscere.
///
/// AL-17, OS-6: gli allenamenti sono in sola lettura, e l'obiettivo
/// settimanale non compare qui — la materia resta dominio dell'Utente,
/// e OS-7 gli concede la sola consultazione, che 8.3 colloca nelle
/// statistiche (F26).
class PatientActivitySection extends ConsumerWidget {
  const PatientActivitySection({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final measurements = ref.watch(patientMeasurementsProvider(patientId)).value;
    final workouts = ref.watch(patientWorkoutsProvider(patientId)).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.patientMeasurementsHeader, style: typography.overline.copyWith(color: colors.textTertiary)),
            TextButton(
              onPressed: () => showMeasurementSheet(context, patientId: patientId),
              child: Text(context.l10n.commonRecord),
            ),
          ],
        ),
        if (measurements == null || measurements.isEmpty)
          Text(
            context.l10n.patientNoMeasurements,
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          )
        else
          for (final measurement in measurements.take(5))
            MeasurementListTile(
              key: ValueKey(measurement.id),
              measurement: measurement,
              // PR-17: il Nutrizionista modifica le proprie rilevazioni,
              // non quelle registrate dal Paziente.
              onTap: measurement.editable
                  ? () => showMeasurementSheet(context, existing: measurement, patientId: patientId)
                  : null,
            ),
        const SizedBox(height: AppSpacing.lg),
        Text(context.l10n.patientWorkoutsHeader, style: typography.overline.copyWith(color: colors.textTertiary)),
        const SizedBox(height: AppSpacing.xs),
        if (workouts == null || workouts.isEmpty)
          Text(
            context.l10n.patientNoWorkouts,
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          )
        else
          for (final workout in workouts.take(5)) _WorkoutRow(workout: workout),
      ],
    );
  }
}

/// AL-18, CB-11: sola lettura — data, tipo e calorie se indicate; nessuna
/// azione, il Nutrizionista non crea né modifica allenamenti (AL-17).
class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${formatDate(context, workout.date)} · ${workout.activityType}',
              style: typography.bodyMedium.copyWith(color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (workout.caloriesBurned != null)
            Text(
              context.l10n.workoutCaloriesWithUnit(workout.caloriesBurned!),
              style: typography.caption.copyWith(color: colors.textSecondary),
            ),
        ],
      ),
    );
  }
}

