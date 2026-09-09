import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/statistics_models.dart';
import '../providers/statistics_providers.dart';
import 'adherence_view.dart';
import 'body_statistics_view.dart';
import 'workout_statistics_view.dart';

/// *Statistiche* (11 interfaccia.md): terza destinazione dell'Utente.
///
/// Tre segmenti nell'intestazione — **Aderenza** · **Allenamenti** ·
/// **Corpo** — e sotto un selettore del periodo comune ai tre (AD-8),
/// conservato tra le sessioni (3.2).
///
/// **Tono della sezione** (11.1): l'intera schermata presenta i dati in
/// forma neutra — nessuna soglia di merito, nessun colore di giudizio,
/// nessun punteggio, nessuna denominazione qualificativa (AD-15, SA-16,
/// AN-11). Nessun messaggio commenta l'andamento, in senso favorevole o
/// sfavorevole (2.1).
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key, this.planId});

  /// 7.5: il piano preselezionato quando vi si arriva dal dettaglio di un
  /// piano concluso.
  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final mode = ref.watch(selectedStatisticsViewProvider);
    final period = ref.watch(selectedStatisticsPeriodProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: AppSegmentedControl(
          labels: const ['Aderenza', 'Allenamenti', 'Corpo'],
          selectedIndex: StatisticsViewMode.values.indexOf(mode),
          onSelect: (index) => ref
              .read(selectedStatisticsViewProvider.notifier)
              .select(StatisticsViewMode.values[index]),
        ),
      ),
      body: SafeArea(
        child: period.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const _PeriodSelectorFallback(),
          data: (selectedPeriod) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PeriodSelector(selected: selectedPeriod),
              Expanded(
                child: _Content(
                  mode: mode,
                  query: StatisticsQuery(
                    period: selectedPeriod,
                    // 7.5: fuori dal dettaglio di un piano concluso non si
                    // indica alcun piano, e il backend intende quello in
                    // corso (PA-8).
                    planId: selectedPeriod == StatisticsPeriod.plan
                        ? (planId ?? ref.watch(selectedStatisticsPlanProvider))
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 11.1: *Settimana* · *Mese* · *Piano*, comune ai tre segmenti (AD-8).
class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.selected});

  final StatisticsPeriod selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Center(
        child: AppSegmentedControl(
          labels: StatisticsPeriod.values.map((period) => period.label).toList(),
          selectedIndex: StatisticsPeriod.values.indexOf(selected),
          onSelect: (index) {
            ref.read(selectedStatisticsPeriodProvider.notifier).select(StatisticsPeriod.values[index]);
            // ST-10: cambiando orizzonte l'alternanza fra complessivo e
            // singolo periodo non ha più oggetto.
            ref.read(selectedAdherencePeriodIndexProvider.notifier).select(null);
          },
        ),
      ),
    );
  }
}

class _PeriodSelectorFallback extends StatelessWidget {
  const _PeriodSelectorFallback();

  @override
  Widget build(BuildContext context) => const EmptyStateView(
        icon: Icons.show_chart,
        title: 'Statistiche non disponibili',
      );
}

class _Content extends ConsumerWidget {
  const _Content({required this.mode, required this.query});

  final StatisticsViewMode mode;
  final StatisticsQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (mode) {
      StatisticsViewMode.adherence => _Async(
          value: ref.watch(adherenceStatisticsProvider(query)),
          builder: (statistics) => AdherenceView(statistics: statistics),
        ),
      StatisticsViewMode.workouts => _Async(
          value: ref.watch(workoutStatisticsProvider(query)),
          builder: (statistics) => WorkoutStatisticsView(statistics: statistics),
        ),
      StatisticsViewMode.body => _Async(
          value: ref.watch(measurementStatisticsProvider(query)),
          builder: (statistics) => BodyStatisticsView(statistics: statistics),
        ),
    };
  }
}

/// Attesa, errore e dato, con il medesimo trattamento delle altre
/// schermate. L'orizzonte *Piano* senza alcun piano cui riferirsi produce
/// una constatazione, non un errore (4.4).
class _Async<T> extends StatelessWidget {
  const _Async({required this.value, required this.builder});

  final AsyncValue<T> value;
  final Widget Function(T) builder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        final code = error.asApiException?.code ?? '';
        if (code == 'RESOURCE_NOT_FOUND') {
          return const EmptyStateView(
            icon: Icons.show_chart,
            title: 'Nessun piano su cui riferire il periodo',
            text: 'Le statistiche del piano compaiono quando ne esiste uno.',
          );
        }
        return Center(
          child: Text(
            describeApiError(code),
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        );
      },
      data: builder,
    );
  }
}
