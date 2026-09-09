import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../../l10n/formats.dart';

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
            tooltip: context.l10n.weekPrevious,
          ),
          Expanded(
            child: Text(
              weekRangeLabel(context, weekStart),
              textAlign: TextAlign.center,
              style: typography.titleMedium.copyWith(color: colors.textPrimary),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: Icon(Icons.chevron_right, color: colors.textSecondary),
            tooltip: context.l10n.weekNext,
          ),
          if (onCurrentWeek != null)
            TextButton(
              onPressed: onCurrentWeek,
              child: Text(context.l10n.weekThisWeek, style: typography.label.copyWith(color: colors.accent)),
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
String weekRangeLabel(BuildContext context, DateTime weekStart) {
  final end = weekStart.add(const Duration(days: 6));
  if (weekStart.month == end.month && weekStart.year == end.year) {
    return context.l10n.weekRangeSameMonth(
      formatDayOfMonth(context, weekStart),
      formatDayOfMonth(context, end),
      formatMonthAndYear(context, end),
    );
  }
  // LO-9: gli estremi portano il proprio mese, ciascuno nel formato
  // della lingua.
  return context.l10n.weekRangeAcrossMonths(
    weekStart.year == end.year
        ? formatDayAndMonth(context, weekStart)
        : '${formatDayAndMonth(context, weekStart)} ${weekStart.year}',
    '${formatDayAndMonth(context, end)} ${end.year}',
  );
}
