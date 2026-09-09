import 'package:flutter/widgets.dart';

import '../../../l10n/l10n_context.dart';
import '../data/workout_models.dart';

/// Denominazione del giorno della settimana nella lingua selezionata
/// (LO-1, LO-11: la settimana comincia sempre di lunedì).
String workoutWeekdayLabel(BuildContext context, Weekday day) => switch (day) {
      Weekday.monday => context.l10n.weekdayMonday,
      Weekday.tuesday => context.l10n.weekdayTuesday,
      Weekday.wednesday => context.l10n.weekdayWednesday,
      Weekday.thursday => context.l10n.weekdayThursday,
      Weekday.friday => context.l10n.weekdayFriday,
      Weekday.saturday => context.l10n.weekdaySaturday,
      Weekday.sunday => context.l10n.weekdaySunday,
    };

/// 10.1 interfaccia.md: sette iniziali nella card della pianificazione.
String workoutWeekdayInitial(BuildContext context, Weekday day) => switch (day) {
      Weekday.monday => context.l10n.weekdayInitialMonday,
      Weekday.tuesday => context.l10n.weekdayInitialTuesday,
      Weekday.wednesday => context.l10n.weekdayInitialWednesday,
      Weekday.thursday => context.l10n.weekdayInitialThursday,
      Weekday.friday => context.l10n.weekdayInitialFriday,
      Weekday.saturday => context.l10n.weekdayInitialSaturday,
      Weekday.sunday => context.l10n.weekdayInitialSunday,
    };
