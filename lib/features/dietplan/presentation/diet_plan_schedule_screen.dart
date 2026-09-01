import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../data/diet_plan.dart';
import '../data/diet_plan_requests.dart';
import '../data/slot_type.dart';
import '../data/weekday.dart';
import '../providers/diet_plan_providers.dart';
import 'editable_slot.dart';
import 'slot_type_presentation.dart';
import 'widgets/day_selector.dart';
import 'widgets/slot_card.dart';

final RegExp _recipeNameFieldPattern = RegExp(r'^days\[(\d+)\]\.slots\[(\d+)\]\.recipeName$');

/// Redazione dello schema settimanale (7.3 interfaccia.md, CD-5, CD-7,
/// CD-8, CD-10, CD-11). Disposizione `compact` soltanto (un giorno per
/// volta): l'adattamento a schermo ampio è il task successivo di F08.
///
/// Non compaiono: la conferma del piano (CV-2, macchina a stati di F10,
/// non ancora implementata), il salvataggio come template (TP-5, F09) e
/// la striscia informativa di modifica di un piano attivo (5.3
/// funzionale, F22) — il backend ammette la sostituzione dello schema
/// solo sul piano in Bozza (`PLAN_NOT_DRAFT`), unico caso qui possibile.
class DietPlanScheduleScreen extends ConsumerStatefulWidget {
  const DietPlanScheduleScreen({super.key, required this.planId});

  final String planId;

  @override
  ConsumerState<DietPlanScheduleScreen> createState() => _DietPlanScheduleScreenState();
}

class _DietPlanScheduleScreenState extends ConsumerState<DietPlanScheduleScreen> {
  List<EditableDay>? _days;
  late Weekday _selectedDay;
  bool _dirty = false;
  bool _saving = false;

  void _initializeFrom(DietPlan plan) {
    if (_days != null) return;
    _days = plan.weeklySchedule.map(EditableDay.fromWeekDay).toList();
    _selectedDay = _days!.first.dayOfWeek;
  }

  @override
  void dispose() {
    _days?.forEach((day) => day.dispose());
    super.dispose();
  }

  EditableDay get _currentDay => _days!.firstWhere((day) => day.dayOfWeek == _selectedDay);

  void _markDirty() => setState(() => _dirty = true);

  void _addSlot(SlotType type) {
    setState(() {
      _currentDay.slots.add(EditableSlot.newSlot(type));
      _dirty = true;
    });
  }

  Future<void> _removeSlot(EditableSlot slot) async {
    if (!slot.isEmpty) {
      final confirmed = await _confirmDialog(
        title: 'Rimuovere lo slot?',
        message: 'Il contenuto compilato andrà perso.',
        confirmLabel: 'Rimuovi',
      );
      if (confirmed != true) return;
    }
    setState(() {
      _currentDay.slots.remove(slot);
      _dirty = true;
    });
    slot.dispose();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final slot = _currentDay.slots.removeAt(oldIndex);
      _currentDay.slots.insert(newIndex, slot);
      _dirty = true;
    });
  }

  Future<bool?> _confirmDialog({required String title, required String message, required String confirmLabel}) {
    final colors = context.colors;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel, style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final request = UpdateWeeklyScheduleRequest(days: _days!.map((day) => day.toRequest()).toList());
    setState(() => _saving = true);
    try {
      final plan = await ref.read(dietPlanScheduleControllerProvider(widget.planId).notifier).save(request);
      if (!mounted) return;
      setState(() {
        _days?.forEach((day) => day.dispose());
        _days = null;
        _initializeFrom(plan);
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Piano salvato.')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _handleSaveError(error);
    }
  }

  void _handleSaveError(Object error) {
    final exception = error.asApiException;
    if (exception?.code == 'VALIDATION_FAILED') {
      final fields = (exception?.body as Map?)?['fields'] as List?;
      var matchedRecipeField = false;
      for (final item in fields ?? const []) {
        final field = (item as Map)['field'] as String?;
        final match = field == null ? null : _recipeNameFieldPattern.firstMatch(field);
        if (match == null) continue;
        matchedRecipeField = true;
        final dayIndex = int.parse(match.group(1)!);
        final slotIndex = int.parse(match.group(2)!);
        final day = _days![dayIndex];
        final slot = day.slots[slotIndex];
        slot.recipeNameError = 'Serve una denominazione se è presente il testo della ricetta';
        slot.expanded = true;
        setState(() => _selectedDay = day.dayOfWeek);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            matchedRecipeField ? 'Controlla i campi della ricetta segnalati.' : describeApiError('VALIDATION_FAILED'),
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(describeApiError(exception?.code ?? ''))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final planState = ref.watch(dietPlanScheduleControllerProvider(widget.planId));

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final confirmed = await _confirmDialog(
          title: 'Modifiche non salvate',
          message: 'Uscendo perderai le modifiche non salvate.',
          confirmLabel: 'Esci senza salvare',
        );
        if (confirmed == true) navigator.pop();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            planState.value?.name ?? 'Redazione dello schema',
            style: typography.titleMedium.copyWith(color: colors.textPrimary),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _saving
                        ? const Padding(
                            padding: EdgeInsets.all(AppSpacing.xs),
                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: _dirty ? _save : null,
                            child: Text(
                              'Salva',
                              style: typography.label.copyWith(
                                color: _dirty ? colors.accent : colors.textTertiary,
                              ),
                            ),
                          ),
                    if (_dirty)
                      Text('Modifiche non salvate', style: typography.caption.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: planState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                describeApiError(error.asApiException?.code ?? ''),
                style: typography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ),
            data: (plan) {
              _initializeFrom(plan);
              final day = _currentDay;

              return Column(
                children: [
                  DaySelector(days: _days!, selected: _selectedDay, onSelect: (d) => setState(() => _selectedDay = d)),
                  const Divider(height: 1),
                  Expanded(
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
                      itemCount: day.slots.length,
                      onReorderItem: _reorder,
                      itemBuilder: (context, index) {
                        final slot = day.slots[index];
                        return SlotCard(
                          key: ValueKey(slot),
                          slot: slot,
                          index: index,
                          onChanged: _markDirty,
                          onRemove: () => _removeSlot(slot),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final type in [SlotType.breakfast, SlotType.lunch, SlotType.dinner])
                          OutlinedButton.icon(
                            onPressed: day.hasType(type) ? null : () => _addSlot(type),
                            icon: Icon(type.icon, size: 18),
                            label: Text('Aggiungi ${type.displayName.toLowerCase()}'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => _addSlot(SlotType.snack),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Aggiungi spuntino'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
