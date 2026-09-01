import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_breakpoints.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../data/diet_plan_requests.dart';
import '../data/diet_plan_template.dart';
import '../data/slot_type.dart';
import '../data/weekday.dart';
import '../providers/diet_plan_template_providers.dart';
import 'editable_slot.dart';
import 'slot_type_presentation.dart';
import 'widgets/day_selector.dart';
import 'widgets/day_sidebar.dart';
import 'widgets/slot_card.dart';

final RegExp _recipeNameFieldPattern = RegExp(r'^days\[(\d+)\]\.slots\[(\d+)\]\.recipeName$');

/// Redazione dello schema del template (7.4 interfaccia.md, "medesima
/// schermata di 7.3, priva dei campi di data e destinatario", TP-12):
/// stessa struttura di [DietPlanScheduleScreen] — stesse regole GG-4,
/// GG-5, GG-15 sul backend (`WeeklyScheduleConverter`, condiviso col
/// piano) — ma senza conferma né striscia di piano attivo, dato che il
/// template non possiede alcuno stato (CO-8, TP-2). Non generalizzata a
/// partire da [DietPlanScheduleScreen]: le due schermate restano
/// indipendenti finché una reale esigenza di riuso non lo giustifichi
/// (vedi decisioni.md).
class DietPlanTemplateScheduleScreen extends ConsumerStatefulWidget {
  const DietPlanTemplateScheduleScreen({super.key, required this.templateId});

  final String templateId;

  @override
  ConsumerState<DietPlanTemplateScheduleScreen> createState() => _DietPlanTemplateScheduleScreenState();
}

class _DietPlanTemplateScheduleScreenState extends ConsumerState<DietPlanTemplateScheduleScreen> {
  List<EditableDay>? _days;
  late Weekday _selectedDay;
  bool _dirty = false;
  bool _saving = false;

  void _initializeFrom(DietPlanTemplate template) {
    if (_days != null) return;
    _days = template.weeklySchedule.map(EditableDay.fromWeekDay).toList();
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
      final template =
          await ref.read(dietPlanTemplateScheduleControllerProvider(widget.templateId).notifier).save(request);
      if (!mounted) return;
      setState(() {
        _days?.forEach((day) => day.dispose());
        _days = null;
        _initializeFrom(template);
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template salvato.')));
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

  /// Elenco degli slot del giorno selezionato e azioni di aggiunta,
  /// comune a `compact` ed `expanded` (MP-6): stesso criterio già seguito
  /// da `DietPlanScheduleScreen._buildDayEditor`.
  Widget _buildDayEditor(EditableDay day) {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.all(AppSpacing.md),
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
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final templateState = ref.watch(dietPlanTemplateScheduleControllerProvider(widget.templateId));

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
            templateState.value?.name ?? 'Redazione del template',
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
          child: templateState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                describeApiError(error.asApiException?.code ?? ''),
                style: typography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ),
            data: (template) {
              _initializeFrom(template);
              final day = _currentDay;

              if (context.breakpoint.isAtLeastExpanded) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: AppSpacing.widthDayNavigationSidebar,
                      child: DaySidebar(
                        days: _days!,
                        selected: _selectedDay,
                        onSelect: (d) => setState(() => _selectedDay = d),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _buildDayEditor(day)),
                  ],
                );
              }

              return Column(
                children: [
                  DaySelector(days: _days!, selected: _selectedDay, onSelect: (d) => setState(() => _selectedDay = d)),
                  const Divider(height: 1),
                  Expanded(child: _buildDayEditor(day)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
