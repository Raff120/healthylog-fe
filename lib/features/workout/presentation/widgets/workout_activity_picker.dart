import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/workout_activity.dart';
import '../../providers/workout_providers.dart';
import '../workout_activity_presentation.dart';

/// Lo sport scelto nel selettore, con il nome che l'Utente gli ha dato
/// quando è [WorkoutActivity.other] (AL-2).
class WorkoutActivityChoice {
  const WorkoutActivityChoice(this.activity, this.customName);

  final WorkoutActivity activity;

  /// Valorizzato per il solo [WorkoutActivity.other]: è la denominazione
  /// dell'attività, e la sola che la distingua dalle altre.
  final String? customName;
}

/// Selezione dello sport (AL-2, 10.2 interfaccia.md).
///
/// L'elenco porta in cima gli sport già impiegati — quelli che l'Utente
/// pratica davvero — e sotto tutti gli altri in ordine alfabetico, con
/// *Altro* sempre in fondo: è la voce che apre al nome libero, non uno
/// sport fra gli altri.
///
/// Il campo di ricerca in testa serve alla lunghezza dell'elenco: trenta
/// voci non si scorrono, si cercano.
Future<WorkoutActivityChoice?> showWorkoutActivityPicker(
  BuildContext context, {
  WorkoutActivity? selected,
  String? customName,
}) {
  return showModalBottomSheet<WorkoutActivityChoice>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _WorkoutActivityPicker(selected: selected, customName: customName),
  );
}

class _WorkoutActivityPicker extends ConsumerStatefulWidget {
  const _WorkoutActivityPicker({this.selected, this.customName});

  final WorkoutActivity? selected;
  final String? customName;

  @override
  ConsumerState<_WorkoutActivityPicker> createState() => _WorkoutActivityPickerState();
}

class _WorkoutActivityPickerState extends ConsumerState<_WorkoutActivityPicker> {
  final _searchController = TextEditingController();
  late final _customNameController = TextEditingController(text: widget.customName ?? '');
  String _query = '';

  /// La voce *Altro* è stata toccata: l'elenco lascia il posto al campo
  /// del nome, che è ciò che resta da indicare.
  bool _naming = false;
  String? _customNameError;

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  void _choose(WorkoutActivity activity, {String? customName}) {
    Navigator.of(context).pop(WorkoutActivityChoice(activity, customName));
  }

  void _confirmCustomName() {
    final name = _customNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _customNameError = context.l10n.workoutActivityNameRequired);
      return;
    }
    _choose(WorkoutActivity.other, customName: name);
  }

  /// Gli sport già impiegati, nell'ordine di frequenza in cui il backend
  /// li restituisce, seguiti da tutti gli altri in ordine alfabetico.
  /// *Altro* non compare qui: chiude l'elenco da sé.
  List<_ActivityEntry> _entries(List<WorkoutActivityUsage> used) {
    final entries = <_ActivityEntry>[];
    final seen = <String>{};
    for (final usage in used) {
      final key = '${usage.activity.param}:${usage.customName ?? ''}';
      if (!seen.add(key)) continue;
      entries.add(_ActivityEntry(usage.activity, usage.customName));
    }
    for (final activity in workoutActivitiesAlphabetical(context)) {
      if (activity.isOther) continue;
      if (seen.contains('${activity.param}:')) continue;
      entries.add(_ActivityEntry(activity, null));
    }
    return entries;
  }

  bool _matches(_ActivityEntry entry) {
    if (_query.isEmpty) return true;
    return entry.name(context).toLowerCase().contains(_query);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final used = ref.watch(workoutActivitiesProvider).value ?? const <WorkoutActivityUsage>[];
    final entries = _entries(used).where(_matches).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    context.l10n.workoutActivityType,
                    style: typography.titleMedium.copyWith(color: colors.textPrimary),
                  ),
                ),
                if (_naming) _customNameForm(context) else ..._list(context, entries),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// AL-2: il nome dell'attività che l'elenco non prevede.
  Widget _customNameForm(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: context.l10n.workoutActivityName,
            controller: _customNameController,
            errorText: _customNameError,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_customNameError != null) setState(() => _customNameError = null);
            },
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            context.l10n.workoutActivityNameHint,
            style: typography.caption.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(label: context.l10n.commonConfirm, onPressed: _confirmCustomName),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () => setState(() => _naming = false),
            child: Text(context.l10n.commonBack),
          ),
        ],
      ),
    );
  }

  List<Widget> _list(BuildContext context, List<_ActivityEntry> entries) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppTextField(
          label: context.l10n.commonSearch,
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _ActivityRow(
              activity: entry.activity,
              name: entry.name(context),
              selected: entry.activity == widget.selected && entry.customName == widget.customName,
              onTap: () => _choose(entry.activity, customName: entry.customName),
            );
          },
        ),
      ),
      Divider(height: 1, color: context.colors.dividerLight),
      // AL-2: la voce che apre al nome libero, sempre in fondo.
      _ActivityRow(
        activity: WorkoutActivity.other,
        name: context.l10n.workoutActivityOther,
        selected: false,
        onTap: () => setState(() => _naming = true),
      ),
      const SizedBox(height: AppSpacing.xs),
    ];
  }
}

/// Una voce dell'elenco: lo sport, e per *Altro* il nome che lo distingue.
class _ActivityEntry {
  const _ActivityEntry(this.activity, this.customName);

  final WorkoutActivity activity;
  final String? customName;

  String name(BuildContext context) => workoutActivityName(context, activity, customName);
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.activity,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final WorkoutActivity activity;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.heightListItemOneLine),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              workoutActivityIcon(activity),
              size: 20,
              color: selected ? colors.accent : colors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                name,
                style: typography.bodyLarge.copyWith(
                  color: selected ? colors.accent : colors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected) Icon(Icons.check, size: 20, color: colors.accent),
          ],
        ),
      ),
    );
  }
}
