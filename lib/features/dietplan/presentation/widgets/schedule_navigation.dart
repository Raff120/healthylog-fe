import 'package:flutter/material.dart';

import '../../data/weekday.dart';
import '../editable_slot.dart';
import '../editable_weeks.dart';
import 'day_selector.dart';
import 'day_sidebar.dart';
import 'schedule_week_selector.dart';

/// Navigazione dello schema in redazione (7.3 interfaccia.md, MP-6): le
/// settimane, quando sono più d'una, sopra i giorni della settimana scelta
/// — in riga su `compact` ([DaySelector]), in colonna su schermo ampio
/// ([DaySidebar]). Con una settimana sola restano i soli giorni, come prima
/// dei piani su più settimane (PA-2bis).
class ScheduleNavigation extends StatelessWidget {
  const ScheduleNavigation({
    super.key,
    required this.days,
    required this.selectedWeek,
    required this.selectedDay,
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.sidebar,
  });

  final List<EditableDay> days;
  final int selectedWeek;
  final Weekday selectedDay;
  final ValueChanged<int> onSelectWeek;
  final ValueChanged<Weekday> onSelectDay;

  /// `true` su schermo ampio: i giorni in colonna, che occupa l'altezza.
  final bool sidebar;

  @override
  Widget build(BuildContext context) {
    final weekDays = days.daysOfWeek(selectedWeek);
    final weeks = days.weekCount > 1
        ? ScheduleWeekSelector(days: days, selected: selectedWeek, onSelect: onSelectWeek)
        : null;

    if (sidebar) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?weeks,
          Expanded(child: DaySidebar(days: weekDays, selected: selectedDay, onSelect: onSelectDay)),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?weeks,
        DaySelector(days: weekDays, selected: selectedDay, onSelect: onSelectDay),
      ],
    );
  }
}
