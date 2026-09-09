import 'package:flutter/widgets.dart';

import '../../../l10n/l10n_context.dart';
import '../data/weekday.dart';

/// Denominazione del giorno-modello nella lingua selezionata (LO-1,
/// LO-11: la settimana comincia sempre di lunedì, in ogni lingua).
///
/// Non sono getter dell'enumerativo: la traduzione richiede il contesto, e
/// l'enumerativo — che rispecchia `java.time.DayOfWeek` sul backend — non
/// deve conoscerlo.
String weekdayLabel(BuildContext context, Weekday day) => switch (day) {
      Weekday.monday => context.l10n.weekdayMonday,
      Weekday.tuesday => context.l10n.weekdayTuesday,
      Weekday.wednesday => context.l10n.weekdayWednesday,
      Weekday.thursday => context.l10n.weekdayThursday,
      Weekday.friday => context.l10n.weekdayFriday,
      Weekday.saturday => context.l10n.weekdaySaturday,
      Weekday.sunday => context.l10n.weekdaySunday,
    };

/// Iniziale del selettore dei giorni (7.3 interfaccia.md).
String weekdayInitial(BuildContext context, Weekday day) => switch (day) {
      Weekday.monday => context.l10n.weekdayInitialMonday,
      Weekday.tuesday => context.l10n.weekdayInitialTuesday,
      Weekday.wednesday => context.l10n.weekdayInitialWednesday,
      Weekday.thursday => context.l10n.weekdayInitialThursday,
      Weekday.friday => context.l10n.weekdayInitialFriday,
      Weekday.saturday => context.l10n.weekdayInitialSaturday,
      Weekday.sunday => context.l10n.weekdayInitialSunday,
    };
