import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/l10n_context.dart';
import '../data/diet_plan.dart';
import '../data/personal_annotations.dart';
import '../providers/diet_plan_providers.dart';
import 'slot_type_presentation.dart';
import 'weekday_presentation.dart';
import 'widgets/personal_plan_note_dialog.dart';
import 'widgets/personal_slot_note_dialog.dart';
import 'widgets/slot_items_view.dart';

/// Le tue note (7.6 interfaccia.md): le annotazioni personali di un piano,
/// al solo proprietario (NP-2). La nota del piano in testa, poi le note
/// degli slot raggruppate per giorno dello schema, ciascuna col contenuto
/// che lo slot ha **nello schema** — non in una data, dove un'inversione o
/// la modifica della singola giornata possono averlo spostato.
///
/// Il nome dei giorni vi si legge soltanto, nell'intestazione del gruppo:
/// si dà dalla giornaliera (6.2).
class PersonalNotesScreen extends ConsumerWidget {
  const PersonalNotesScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final plan = ref.watch(dietPlanScheduleControllerProvider(planId));
    final annotations = ref.watch(personalAnnotationsProvider(planId));
    // Le scritture si osservano perché la pagina non perda lo stato
    // autoDispose dei controller mentre il dialogo salva.
    ref.watch(personalSlotNoteControllerProvider);
    ref.watch(personalPlanNoteControllerProvider);

    final error = plan.error ?? annotations.error;
    final Widget body;
    if (error != null) {
      // 4.4: contenuto non caricabile — anche senza rete, perché le
      // annotazioni non si conservano in locale (OF-20).
      body = EmptyStateView(
        icon: Icons.cloud_off_outlined,
        title: describeApiError(context, error.asApiException?.code ?? ''),
        actionLabel: context.l10n.personalNotesRetry,
        onAction: () {
          ref.invalidate(dietPlanScheduleControllerProvider(planId));
          ref.invalidate(personalAnnotationsProvider(planId));
        },
      );
    } else if (plan.value == null || annotations.value == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (annotations.value!.isEmpty) {
      body = EmptyStateView(
        icon: Icons.edit_note,
        title: context.l10n.personalNotesEmptyTitle,
        text: context.l10n.personalNotesEmptyText,
      );
    } else {
      body = _NotesList(plan: plan.value!, annotations: annotations.value!);
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          context.l10n.personalPlanNotesTitle,
          style: typography.titleMedium.copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(child: body),
    );
  }
}

class _NotesList extends ConsumerWidget {
  const _NotesList({required this.plan, required this.annotations});

  final DietPlan plan;
  final PersonalAnnotations annotations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = annotatedDaysOf(plan.weeklySchedule, annotations);
    final manyWeeks = weekCountOf(plan.weeklySchedule) > 1;
    final planNote = annotations.planNote;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxWidthSingleColumn),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (planNote != null) ...[
              _GroupTitle(context.l10n.personalNotesPlanNote),
              _NoteCard(
                key: const ValueKey('personal-plan-note'),
                note: planNote,
                onTap: () => editPersonalPlanNote(context, ref, plan.id),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            for (final (day, slots) in groups) ...[
              _GroupTitle(_dayTitle(context, day, manyWeeks)),
              for (final slot in slots)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _NoteCard(
                    key: ValueKey('personal-slot-note-${slot.slotId}'),
                    slot: slot,
                    note: annotations.slotNote(slot.slotId)!,
                    onTap: () => editPersonalSchemaSlotNote(
                      context,
                      ref,
                      planId: plan.id,
                      slotId: slot.slotId,
                      currentNote: annotations.slotNote(slot.slotId),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }

  /// NP-4: il giorno — con la settimana, quando sono più d'una — seguito
  /// dal nome che il proprietario gli ha dato.
  String _dayTitle(BuildContext context, DietPlanWeekDay day, bool manyWeeks) {
    final weekday = weekdayLabel(context, day.dayOfWeek);
    final label = manyWeeks ? context.l10n.scheduleWeekDay(day.week, weekday) : weekday;
    final name = annotations.dayName(day.week, day.dayOfWeek);
    return name == null ? label : '$label · $name';
  }
}

/// I giorni dello schema che hanno almeno uno slot annotato, nell'ordine
/// dello schema, ciascuno coi soli slot annotati nell'ordine del giorno.
List<(DietPlanWeekDay, List<DietPlanSlot>)> annotatedDaysOf(
  List<DietPlanWeekDay> days,
  PersonalAnnotations annotations,
) {
  final ordered = [...days]
    ..sort((a, b) => a.week != b.week ? a.week.compareTo(b.week) : a.dayOfWeek.index.compareTo(b.dayOfWeek.index));
  return [
    for (final day in ordered)
      if (day.slots.any((slot) => annotations.slotNote(slot.slotId) != null))
        (
          day,
          [...day.slots.where((slot) => annotations.slotNote(slot.slotId) != null)]
            ..sort((a, b) => a.order.compareTo(b.order)),
        ),
  ];
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: typography.overline.copyWith(color: colors.textTertiary)),
    );
  }
}

/// Una nota in card: per lo slot, il tipo (con la denominazione dello
/// spuntino, GG-10) e il contenuto nello schema sopra il testo della nota.
/// Il tocco la apre nel dialogo delle annotazioni.
class _NoteCard extends StatelessWidget {
  const _NoteCard({super.key, this.slot, required this.note, required this.onTap});

  final DietPlanSlot? slot;
  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final slot = this.slot;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (slot != null) ...[
                Row(
                  children: [
                    Icon(slot.type.icon, color: colors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        slot.label?.isNotEmpty == true ? slot.label! : slotTypeLabel(context, slot.type),
                        style: typography.titleMedium.copyWith(color: colors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                SlotItemsView(items: slot.items, dense: true),
                const SizedBox(height: AppSpacing.sm),
                Divider(height: 1, color: colors.dividerLight),
                const SizedBox(height: AppSpacing.sm),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.edit_note, color: colors.accent),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(note, style: typography.bodyMedium.copyWith(color: colors.textPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
