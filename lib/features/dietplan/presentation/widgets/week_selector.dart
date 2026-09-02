import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../domain/plan_day_date.dart';

/// Intestazione della vista settimanale (6.4 interfaccia.md, VS-12,
/// VS-13): intervallo di date con frecce verso le settimane adiacenti,
/// più il ritorno alla settimana corrente quando altrove.
class WeekSelector extends StatelessWidget {
  const WeekSelector({
    super.key,
    required this.weekStart,
    required this.onPrevious,
    required this.onNext,
    this.onCurrentWeek,
  });

  final DateTime weekStart;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// `null` quando si sta già guardando la settimana corrente (VS-13):
  /// l'azione compare solo altrove, sullo stesso criterio di "Oggi"
  /// nella vista giornaliera (VG-19).
  final VoidCallback? onCurrentWeek;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: Icon(Icons.chevron_left, color: colors.textSecondary),
            tooltip: 'Settimana precedente',
          ),
          Expanded(
            child: Text(
              weekRangeLabel(weekStart),
              textAlign: TextAlign.center,
              style: typography.titleMedium.copyWith(color: colors.textPrimary),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: Icon(Icons.chevron_right, color: colors.textSecondary),
            tooltip: 'Settimana successiva',
          ),
          if (onCurrentWeek != null)
            TextButton(
              onPressed: onCurrentWeek,
              child: Text('Questa settimana', style: typography.label.copyWith(color: colors.accent)),
            ),
        ],
      ),
    );
  }
}

/// "7 – 13 settembre 2026", ovvero con mese (ed eventualmente anno)
/// ripetuto sul primo estremo quando la settimana attraversa un confine
/// di mese o d'anno (VS-2, LO-11: la settimana può farlo, essendo
/// ancorata al lunedì e non al calendario del mese).
String weekRangeLabel(DateTime weekStart) {
  final end = weekStart.add(const Duration(days: 6));
  final sameMonth = weekStart.month == end.month && weekStart.year == end.year;
  if (sameMonth) {
    return '${weekStart.day} – ${end.day} ${italianMonths[end.month - 1]} ${end.year}';
  }
  final sameYear = weekStart.year == end.year;
  final startLabel = sameYear
      ? '${weekStart.day} ${italianMonths[weekStart.month - 1]}'
      : '${weekStart.day} ${italianMonths[weekStart.month - 1]} ${weekStart.year}';
  return '$startLabel – ${end.day} ${italianMonths[end.month - 1]} ${end.year}';
}
