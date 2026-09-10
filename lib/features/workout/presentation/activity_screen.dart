import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/formats.dart';
import '../../../l10n/l10n_context.dart';
import '../../notification/presentation/widgets/notification_bell.dart';
import '../providers/workout_providers.dart';
import 'widgets/planning_card.dart';
import 'widgets/workout_filter_sheet.dart';
import 'widgets/workout_list_tile.dart';
import 'widgets/workout_sheet.dart';

/// *Attività* (10.1 interfaccia.md): seconda destinazione della
/// navigazione, dedicata ai soli allenamenti (AL-17).
///
/// Ospitava anche le misurazioni, dietro un segmented control. Non più:
/// le misure vivono ora nel segmento *Corpo* di *Statistiche* (11.3),
/// dove già si presentavano — e dove ora si registrano e si modificano
/// (vedi decisioni.md). Senza il secondo segmento l'intestazione torna a
/// portare il titolo della destinazione.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          context.l10n.activityWorkouts,
          style: typography.titleMedium.copyWith(color: colors.textPrimary),
        ),
        actions: [
          // RA-12: i filtri riguardano l'elenco degli allenamenti.
          IconButton(
            tooltip: context.l10n.workoutFilters,
            icon: const Icon(Icons.filter_list),
            onPressed: () => showWorkoutFilterSheet(context),
          ),
          // 12.3, 3.1: icona notifiche nell'intestazione di ogni
          // destinazione principale, dopo l'azione contestuale (3.2).
          const NotificationBell(),
        ],
      ),
      body: const SafeArea(child: _WorkoutsView()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showWorkoutSheet(context),
        backgroundColor: colors.accent,
        foregroundColor: colors.surface,
        tooltip: context.l10n.workoutRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 10.1: pianificazione in forma compatta, elenco degli allenamenti
/// registrati e pulsante mobile per la registrazione.
///
/// "Cosa non compare": nessun totale di calorie, nessuna media, nessun
/// grafico (CB-9); nessun conteggio di allenamenti mancanti rispetto
/// all'obiettivo, nessun sollecito (RA-18, OS-10).
class _WorkoutsView extends ConsumerWidget {
  const _WorkoutsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final workouts = ref.watch(workoutsProvider);
    final filters = ref.watch(workoutFilterControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlanningCard(),
        if (!filters.isEmpty) const _FilterChips(),
        Expanded(
          child: workouts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                describeApiError(context, error.asApiException?.code ?? ''),
                style: typography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ),
            data: (items) => items.isEmpty
                // 4.4 interfaccia.md, RA-18: constatazione neutra, mai la
                // segnalazione di una mancanza.
                ? EmptyStateView(
                    icon: Icons.directions_run_outlined,
                    title: filters.isEmpty
                        ? context.l10n.workoutNoneRecorded
                        : context.l10n.workoutNoneWithFilters,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.xxl),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: colors.dividerLight),
                    itemBuilder: (context, index) => WorkoutListTile(
                      workout: items[index],
                      // RA-14, RA-15: il tocco conduce alla modifica.
                      onTap: () => showWorkoutSheet(context, existing: items[index]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// RA-12, 10.1: i filtri attivi come chip sotto l'intestazione,
/// rimovibili singolarmente.
class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(workoutFilterControllerProvider);
    final controller = ref.read(workoutFilterControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Wrap(
        spacing: AppSpacing.xs,
        children: [
          if (filters.activityType != null)
            InputChip(
              label: Text(filters.activityType!),
              onDeleted: () => controller.apply(filters.withoutActivityType()),
            ),
          if (filters.from != null && filters.to != null)
            InputChip(
              label: Text('${formatDate(context, filters.from!)} — ${formatDate(context, filters.to!)}'),
              onDeleted: () => controller.apply(filters.withoutPeriod()),
            ),
        ],
      ),
    );
  }
}

