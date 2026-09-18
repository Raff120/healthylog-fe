import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/formats.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../dietplan/data/diet_plan.dart';
import '../../../dietplan/domain/plan_day_date.dart';
import '../../../dietplan/presentation/widgets/week_selector.dart' show weekRangeLabel;
import '../../../dietplan/providers/diet_plan_providers.dart';
import '../../data/statistics_models.dart';
import '../../providers/statistics_providers.dart';

/// Navigazione fra i periodi di *Statistiche* (AD-8bis, 11.1
/// interfaccia.md): il periodo osservato con le frecce verso quelli
/// adiacenti, e il ritorno a quello corrente quando altrove.
///
/// Sta **sotto l'intestazione e sopra il contenuto**, come il selettore
/// dell'orizzonte: nel segmento *Corpo* privo di misurazioni il contenuto
/// è una constatazione di assenza, e un comando che vi stesse dentro
/// sparirebbe insieme a esso — proprio dove serve, perché è di là che si
/// torna indietro a cercare i dati (vedi decisioni.md).
///
/// Settimana e mese si scorrono per data; l'orizzonte *Piano* scorre i
/// piani che sono stati in vigore, dal più recente al più antico: là il
/// periodo è il piano, e non una finestra di calendario.
class StatisticsPeriodNavigator extends ConsumerWidget {
  const StatisticsPeriodNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedStatisticsPeriodProvider).value;
    if (period == null) return const SizedBox.shrink();
    return period == StatisticsPeriod.plan ? const _PlanNavigator() : _DateNavigator(period: period);
  }
}

/// Settimana e mese: la data di riferimento si sposta di un periodo per
/// volta. Il periodo successivo non è raggiungibile quando si è già su
/// quello corrente — le statistiche non riferiscono il futuro.
class _DateNavigator extends ConsumerWidget {
  const _DateNavigator({required this.period});

  final StatisticsPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedStatisticsDateProvider);
    final controller = ref.read(selectedStatisticsDateProvider.notifier);
    final isCurrent = _samePeriod(date, DateTime.now(), period);

    return _NavigatorRow(
      label: period == StatisticsPeriod.week
          ? weekRangeLabel(context, startOfWeek(date))
          : formatMonthAndYear(context, date),
      onPrevious: () => controller.select(_shifted(date, period, -1)),
      onNext: isCurrent ? null : () => controller.select(_shifted(date, period, 1)),
      onCurrent: isCurrent ? null : controller.toCurrent,
      currentLabel: context.l10n.commonToday,
    );
  }

  static DateTime _shifted(DateTime date, StatisticsPeriod period, int steps) {
    if (period == StatisticsPeriod.week) return date.add(Duration(days: 7 * steps));
    // Il giorno si riporta al primo del mese: un 31 spostato all'indietro
    // finirebbe altrimenti nel mese sbagliato.
    return DateTime(date.year, date.month + steps, 1);
  }

  static bool _samePeriod(DateTime a, DateTime b, StatisticsPeriod period) {
    if (period == StatisticsPeriod.week) return startOfWeek(a) == startOfWeek(b);
    return a.year == b.year && a.month == b.month;
  }
}

/// *Piano*: si scorrono i piani che sono stati in vigore, dal più recente
/// al più antico. I piani mai entrati in vigore — bozze e programmati —
/// non vi figurano: non hanno giorni di cui riferire.
class _PlanNavigator extends ConsumerWidget {
  const _PlanNavigator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(ownedDietPlansProvider).value ?? const <DietPlan>[];
    final navigable = [...plans.where((plan) => plan.periods.isNotEmpty)]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final selectedId = ref.watch(selectedStatisticsPlanProvider);
    final controller = ref.read(selectedStatisticsPlanProvider.notifier);

    // Senza piano indicato vale quello in corso (PA-8), che è il più
    // recente fra quelli stati in vigore.
    final index = selectedId == null
        ? (navigable.isEmpty ? -1 : 0)
        : navigable.indexWhere((plan) => plan.id == selectedId);
    final hasOlder = index >= 0 && index < navigable.length - 1;
    final hasNewer = index > 0;

    return _NavigatorRow(
      label: index < 0 ? context.l10n.statisticsWholePlan : navigable[index].name,
      onPrevious: hasOlder ? () => controller.select(navigable[index + 1].id) : null,
      onNext: hasNewer ? () => controller.select(navigable[index - 1].id) : null,
      onCurrent: index > 0 ? () => controller.select(null) : null,
      currentLabel: context.l10n.statisticsCurrentPlan,
    );
  }
}

/// La riga: freccia, periodo, freccia — e il ritorno al corrente, che
/// compare solo altrove, sul criterio già seguito dalla vista settimanale
/// (VS-13) e da quella giornaliera (VG-19).
class _NavigatorRow extends StatelessWidget {
  const _NavigatorRow({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onCurrent,
    required this.currentLabel,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onCurrent;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            color: colors.textSecondary,
            disabledColor: colors.textTertiary,
            tooltip: context.l10n.statisticsPreviousPeriod,
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: typography.bodyLarge.copyWith(color: colors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: colors.textSecondary,
            disabledColor: colors.textTertiary,
            tooltip: context.l10n.statisticsNextPeriod,
          ),
          // Il ritorno al periodo corrente occupa spazio solo quando serve:
          // altrimenti la riga resta simmetrica attorno all'etichetta.
          if (onCurrent != null)
            TextButton(
              onPressed: onCurrent,
              child: Text(currentLabel, style: typography.label.copyWith(color: colors.accent)),
            ),
        ],
      ),
    );
  }
}
