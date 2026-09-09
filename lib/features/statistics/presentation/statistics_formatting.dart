import 'package:flutter/widgets.dart';

import '../../../l10n/formats.dart';
import '../../../l10n/l10n_context.dart';
import '../data/statistics_models.dart';

/// LO-9: i formati di data sono quelli propri della lingua selezionata
/// (`l10n/formats.dart`); qui restano le sole composizioni proprie delle
/// statistiche.

/// AD-1ter, AH-12: **qui** e solo qui il risultato percentuale è
/// arrotondato all'intero più prossimo. Le somme intermedie restano a
/// precisione piena sul server, che restituisce il valore non arrotondato.
String formatPercentage(double value) => '${value.round()}';

/// Il periodo considerato, che accompagna in `caption` il valore
/// complessivo (11.1).
String describePeriod(
  BuildContext context,
  StatisticsPeriod period,
  DateTime from,
  DateTime to,
  String? planName,
) =>
    switch (period) {
      StatisticsPeriod.week => context.l10n
          .statisticsWeekRange(formatDayAndMonth(context, from), formatDayAndMonth(context, to)),
      StatisticsPeriod.month => context.l10n.statisticsMonthOf(formatMonthAndYear(context, from)),
      StatisticsPeriod.plan => planName == null
          ? context.l10n.statisticsWholePlan
          : context.l10n.statisticsPlanRange(planName, formatDate(context, from), formatDate(context, to)),
    };

/// AD-12, AH-16: i giorni dell'intervallo osservato che il calcolo
/// esclude, dichiarati distinguendo la sospensione dall'assenza di piano —
/// perché un valore riferito a pochi giorni effettivi non sia scambiato
/// per un dato d'insieme.
String? describeExcludedDays(BuildContext context, int suspendedDays, int uncoveredDays) {
  final l10n = context.l10n;
  final parts = <String>[
    if (suspendedDays > 0) l10n.statisticsExclusionDaysSuspended(suspendedDays),
    if (uncoveredDays > 0) l10n.statisticsExclusionDaysUncovered(uncoveredDays),
  ];
  if (parts.isEmpty) return null;
  return l10n.statisticsExclusionNotice(parts.join(l10n.commonListAnd));
}

/// L'etichetta di una settimana sull'asse dell'andamento (AD-14): giorno e
/// mese del lunedì che la apre (LO-11), nel formato della lingua (LO-9).
String formatWeekLabel(BuildContext context, DateTime weekStart) =>
    formatDayAndMonthShort(context, weekStart);
