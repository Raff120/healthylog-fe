import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/l10n_context.dart';
import '../../measurement/presentation/widgets/measurement_sheet.dart';
import '../../notification/presentation/widgets/notification_bell.dart';
import '../data/statistics_models.dart';
import '../providers/statistics_providers.dart';
import 'adherence_view.dart';
import 'widgets/statistics_period_selector.dart';
import 'body_statistics_view.dart';
import 'workout_statistics_view.dart';

/// *Statistiche* (11 interfaccia.md): terza destinazione dell'Utente.
///
/// Tre segmenti nell'intestazione — **Aderenza** · **Allenamenti** ·
/// **Corpo** — e a loro sinistra il selettore del periodo comune ai tre
/// (AD-8), dove *Piano* tiene il selettore del membro del Gruppo (4.2).
/// Non è una seconda barra di comandi impilata sotto la prima — due
/// pillole identiche si leggevano come lo stesso comando ripetuto — ma
/// nemmeno vive dentro il contenuto, dove sparirebbe insieme a esso
/// (segnalato dall'utente due volte, vedi decisioni.md). Il periodo
/// scelto è conservato tra le sessioni (3.2).
///
/// Il segmento **Corpo** reca il pulsante mobile per la registrazione di
/// una misurazione (PR-11): dalla presente feature le misure non hanno
/// altra collocazione, *Attività* essendo dedicata ai soli allenamenti.
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
        // AD-8: il selettore del periodo governa la schermata, non il
        // contenuto, e sta perciò nell'intestazione — dove resta
        // raggiungibile anche quando il contenuto è una constatazione di
        // assenza.
        leading: const StatisticsPeriodSelector(),
        leadingWidth: StatisticsPeriodSelector.widthIn(context),
        // Tre segmenti e un selettore nella stessa riga: la rientranza
        // predefinita del titolo andrebbe tolta alle voci, che a schermo
        // stretto rimpicciolirebbero per pochi punti di margine.
        titleSpacing: 0,
        title: AppSegmentedControl(
          labels: [context.l10n.statisticsAdherence, context.l10n.statisticsWorkouts, context.l10n.statisticsBody],
          selectedIndex: StatisticsViewMode.values.indexOf(mode),
          onSelect: (index) => ref
              .read(selectedStatisticsViewProvider.notifier)
              .select(StatisticsViewMode.values[index]),
        ),
        // 12.3, 3.1: icona notifiche nell'intestazione di ogni
        // destinazione principale.
        actions: const [NotificationBell()],
      ),
      // PR-11, 11.3: la registrazione di una misurazione appartiene al
      // solo segmento *Corpo*. Il pulsante compare lì e in nessun altro
      // punto dell'applicazione: *Attività* non ospita più le misure
      // (vedi decisioni.md). Resta disponibile anche quando il periodo
      // non ne contiene alcuna — è anzi allora che serve.
      floatingActionButton: mode == StatisticsViewMode.body
          ? FloatingActionButton(
              onPressed: () => showMeasurementSheet(context),
              backgroundColor: colors.accent,
              foregroundColor: colors.surface,
              tooltip: context.l10n.measurementRecord,
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: period.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const _PeriodSelectorFallback(),
          data: (selectedPeriod) => _Content(
            mode: mode,
            query: StatisticsQuery(
              period: selectedPeriod,
              // 7.5: fuori dal dettaglio di un piano concluso non si
              // indica alcun piano, e il backend intende quello in corso
              // (PA-8).
              planId: selectedPeriod == StatisticsPeriod.plan
                  ? (planId ?? ref.watch(selectedStatisticsPlanProvider))
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodSelectorFallback extends StatelessWidget {
  const _PeriodSelectorFallback();

  @override
  Widget build(BuildContext context) => EmptyStateView(
        icon: Icons.show_chart,
        title: context.l10n.statisticsUnavailable,
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
///
/// Nessuno di questi stati offre il cambio di orizzonte: il selettore sta
/// nell'intestazione e non scompare con il contenuto.
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
          return EmptyStateView(
            icon: Icons.show_chart,
            title: context.l10n.statisticsNoPlanForPeriod,
            text: context.l10n.statisticsAppearWithPlan,
          );
        }
        return Center(
          child: Text(
            describeApiError(context, code),
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        );
      },
      data: builder,
    );
  }
}
