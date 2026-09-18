import 'package:flutter/material.dart';

import '../../../l10n/l10n_context.dart';
import '../data/workout_activity.dart';

/// Denominazione dello sport nella lingua selezionata (LO-1). Per
/// [WorkoutActivity.other] non esiste denominazione propria: il nome è
/// quello che l'Utente ha dato all'attività, e va letto dal campo
/// `activityType` — vedi [workoutActivityName].
String workoutActivityLabel(BuildContext context, WorkoutActivity activity) => switch (activity) {
      WorkoutActivity.basketball => context.l10n.workoutActivityBasketball,
      WorkoutActivity.boxing => context.l10n.workoutActivityBoxing,
      WorkoutActivity.calisthenics => context.l10n.workoutActivityCalisthenics,
      WorkoutActivity.climbing => context.l10n.workoutActivityClimbing,
      WorkoutActivity.crossfit => context.l10n.workoutActivityCrossfit,
      WorkoutActivity.cycling => context.l10n.workoutActivityCycling,
      WorkoutActivity.dance => context.l10n.workoutActivityDance,
      WorkoutActivity.golf => context.l10n.workoutActivityGolf,
      WorkoutActivity.gym => context.l10n.workoutActivityGym,
      WorkoutActivity.hockey => context.l10n.workoutActivityHockey,
      WorkoutActivity.horseRiding => context.l10n.workoutActivityHorseRiding,
      WorkoutActivity.martialArts => context.l10n.workoutActivityMartialArts,
      WorkoutActivity.padel => context.l10n.workoutActivityPadel,
      WorkoutActivity.pilates => context.l10n.workoutActivityPilates,
      WorkoutActivity.rowing => context.l10n.workoutActivityRowing,
      WorkoutActivity.rugby => context.l10n.workoutActivityRugby,
      WorkoutActivity.running => context.l10n.workoutActivityRunning,
      WorkoutActivity.skating => context.l10n.workoutActivitySkating,
      WorkoutActivity.skiing => context.l10n.workoutActivitySkiing,
      WorkoutActivity.snowboard => context.l10n.workoutActivitySnowboard,
      WorkoutActivity.soccer => context.l10n.workoutActivitySoccer,
      WorkoutActivity.spinning => context.l10n.workoutActivitySpinning,
      WorkoutActivity.surfing => context.l10n.workoutActivitySurfing,
      WorkoutActivity.swimming => context.l10n.workoutActivitySwimming,
      WorkoutActivity.tennis => context.l10n.workoutActivityTennis,
      WorkoutActivity.treadmill => context.l10n.workoutActivityTreadmill,
      WorkoutActivity.trekking => context.l10n.workoutActivityTrekking,
      WorkoutActivity.volleyball => context.l10n.workoutActivityVolleyball,
      WorkoutActivity.walking => context.l10n.workoutActivityWalking,
      WorkoutActivity.yoga => context.l10n.workoutActivityYoga,
      WorkoutActivity.other => context.l10n.workoutActivityOther,
    };

/// Il nome da presentare per un allenamento: quello dello sport, o —
/// quando lo sport è [WorkoutActivity.other] — quello che l'Utente ha dato
/// all'attività (AL-2).
///
/// Vale anche per gli allenamenti anteriori all'elenco degli sport, che si
/// leggono come [WorkoutActivity.other] e conservano la denominazione
/// allora registrata: continuano a presentarsi come sempre.
String workoutActivityName(BuildContext context, WorkoutActivity activity, String? customName) {
  if (activity.isOther && customName != null && customName.isNotEmpty) return customName;
  return workoutActivityLabel(context, activity);
}

/// Icona dello sport (2.5 interfaccia.md).
///
/// Tre voci non hanno icona propria nell'insieme disponibile e ne
/// condividono una: il padel quella del tennis, il crossfit quella della
/// sala pesi, l'equitazione quella generica dello sport. *Altro* reca i
/// puntini di sospensione, che non fingono uno sport che non è stato
/// indicato.
IconData workoutActivityIcon(WorkoutActivity activity) => switch (activity) {
      WorkoutActivity.basketball => Icons.sports_basketball_outlined,
      WorkoutActivity.boxing => Icons.sports_mma_outlined,
      WorkoutActivity.calisthenics => Icons.sports_gymnastics_outlined,
      WorkoutActivity.climbing => Icons.terrain_outlined,
      WorkoutActivity.crossfit => Icons.fitness_center_outlined,
      WorkoutActivity.cycling => Icons.directions_bike_outlined,
      WorkoutActivity.dance => Icons.music_note_outlined,
      WorkoutActivity.golf => Icons.sports_golf_outlined,
      WorkoutActivity.gym => Icons.fitness_center_outlined,
      WorkoutActivity.hockey => Icons.sports_hockey_outlined,
      WorkoutActivity.horseRiding => Icons.sports_outlined,
      WorkoutActivity.martialArts => Icons.sports_martial_arts_outlined,
      WorkoutActivity.padel => Icons.sports_tennis_outlined,
      WorkoutActivity.pilates => Icons.accessibility_new_outlined,
      WorkoutActivity.rowing => Icons.rowing_outlined,
      WorkoutActivity.rugby => Icons.sports_rugby_outlined,
      WorkoutActivity.running => Icons.directions_run_outlined,
      WorkoutActivity.skating => Icons.ice_skating_outlined,
      WorkoutActivity.skiing => Icons.downhill_skiing_outlined,
      WorkoutActivity.snowboard => Icons.snowboarding_outlined,
      WorkoutActivity.soccer => Icons.sports_soccer_outlined,
      WorkoutActivity.spinning => Icons.pedal_bike_outlined,
      WorkoutActivity.surfing => Icons.surfing_outlined,
      WorkoutActivity.swimming => Icons.pool_outlined,
      WorkoutActivity.tennis => Icons.sports_tennis_outlined,
      WorkoutActivity.treadmill => Icons.run_circle_outlined,
      WorkoutActivity.trekking => Icons.hiking_outlined,
      WorkoutActivity.volleyball => Icons.sports_volleyball_outlined,
      WorkoutActivity.walking => Icons.directions_walk_outlined,
      WorkoutActivity.yoga => Icons.self_improvement_outlined,
      WorkoutActivity.other => Icons.more_horiz_outlined,
    };

/// Gli sport in ordine alfabetico nella lingua corrente, con *Altro*
/// sempre in fondo (10.2 interfaccia.md): è la voce che apre al nome
/// libero, non uno sport fra gli altri.
List<WorkoutActivity> workoutActivitiesAlphabetical(BuildContext context) {
  final activities = WorkoutActivity.values.where((activity) => !activity.isOther).toList()
    ..sort((a, b) => workoutActivityLabel(context, a)
        .toLowerCase()
        .compareTo(workoutActivityLabel(context, b).toLowerCase()));
  return [...activities, WorkoutActivity.other];
}
