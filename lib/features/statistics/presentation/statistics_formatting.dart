import 'package:flutter/widgets.dart';

import '../../../l10n/l10n_context.dart';
import '../data/statistics_models.dart';

const _months = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
];

/// LO-9: formato di data in forma italiana fissa, come nel resto
/// dell'applicazione — la scelta per lingua resta a F29.
String formatDay(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String formatDayAndMonth(DateTime date) => '${date.day} ${_months[date.month - 1]}';

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
      StatisticsPeriod.week => context.l10n.statisticsWeekRange(formatDayAndMonth(from), formatDayAndMonth(to)),
      StatisticsPeriod.month =>
        context.l10n.statisticsMonthOf('${_months[from.month - 1]} ${from.year}'),
      StatisticsPeriod.plan => planName == null
          ? context.l10n.statisticsWholePlan
          : context.l10n.statisticsPlanRange(planName, formatDay(from), formatDay(to)),
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
/// mese del lunedì che la apre (LO-11).
String formatWeekLabel(DateTime weekStart) =>
    '${weekStart.day}/${weekStart.month}';
