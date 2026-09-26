import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_breakpoints.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../l10n/l10n_context.dart';
import '../data/diet_plan.dart';
import '../data/diet_plan_requests.dart';
import '../data/diet_plan_template.dart';
import '../data/slot_type.dart';
import '../data/weekday.dart';
import '../domain/slot_item_errors.dart';
import '../providers/diet_plan_template_providers.dart';
import 'editable_slot.dart';
import 'editable_weeks.dart';
import 'slot_type_presentation.dart';
import 'widgets/schedule_navigation.dart';
import 'widgets/slot_card.dart';
import 'widgets/slot_copy_sheet.dart';


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
  int _selectedWeek = DietPlanWeekDay.firstWeek;
  Weekday _selectedDay = Weekday.monday;
  bool _dirty = false;
  bool _saving = false;

  /// Come per il piano: dopo un salvataggio si resta dove si era.
  void _initializeFrom(DietPlanTemplate template) {
    if (_days != null) return;
    _days = template.weeklySchedule.map(EditableDay.fromWeekDay).toList();
    if (!_days!.any((day) => day.week == _selectedWeek && day.dayOfWeek == _selectedDay)) {
      _select(_days!.first);
    }
  }

  void _select(EditableDay day) {
    _selectedWeek = day.week;
    _selectedDay = day.dayOfWeek;
  }

  @override
  void dispose() {
    _days?.forEach((day) => day.dispose());
    super.dispose();
  }

  EditableDay get _currentDay =>
      _days!.firstWhere((day) => day.week == _selectedWeek && day.dayOfWeek == _selectedDay);

  /// TP-1, PA-2bis: il template ha settimane come il piano, e le si
  /// aggiunge e toglie allo stesso modo (7.3 e 7.4 interfaccia.md).
  void _addWeek() {
    setState(() {
      _selectedWeek = _days!.appendCopyOfWeek(_selectedWeek);
      _dirty = true;
    });
  }

  Future<void> _removeWeek() async {
    final confirmed = await _confirmDialog(
      title: context.l10n.scheduleRemoveWeekTitle(_selectedWeek),
      message: context.l10n.scheduleRemoveWeekBody,
      confirmLabel: context.l10n.commonRemove,
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _days!.removeWeek(_selectedWeek);
      if (_selectedWeek > _days!.weekCount) _selectedWeek = _days!.weekCount;
      _dirty = true;
    });
  }

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
        title: context.l10n.editRemoveSlotTitle,
        message: context.l10n.editRemoveSlotBody,
        confirmLabel: context.l10n.commonRemove,
      );
      if (confirmed != true) return;
    }
    setState(() {
      _currentDay.slots.remove(slot);
      _dirty = true;
    });
    slot.dispose();
  }

  /// CD-8bis: copia il contenuto di [slot] in altri slot dello schema,
  /// di qualsiasi giorno e settimana.
  Future<void> _copySlot(EditableSlot slot) async {
    final copied = await copySlotContent(
      context,
      source: slot,
      groups: scheduleCopyGroups(context, _days!, slot),
    );
    if (copied && mounted) _markDirty();
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
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.commonCancel)),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.templateSaved)));
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
      final outcome = applySlotItemErrors(context, fields, (dayIndex, slotIndex) {
        if (dayIndex == null || dayIndex >= _days!.length) return null;
        final day = _days![dayIndex];
        return slotIndex >= day.slots.length ? null : day.slots[slotIndex];
      });
      setState(() {
        if (outcome.dayIndex != null) _select(_days![outcome.dayIndex!]);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            outcome.matched ? context.l10n.editItemsInvalid : describeApiError(context, 'VALIDATION_FAILED'),
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(describeApiError(context, exception?.code ?? ''))),
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
                onCopy: _days!.copyTargetsFor(slot).isEmpty ? null : () => _copySlot(slot),
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
                  label: Text(context.l10n.slotAddOfType(slotTypeLabel(context, type).toLowerCase())),
                ),
              OutlinedButton.icon(
                onPressed: () => _addSlot(SlotType.snack),
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.l10n.editAddSnack),
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
    // Come nella redazione del piano: il menu delle settimane
    // nell'intestazione ha bisogno dei giorni fin dal primo fotogramma in
    // cui il template è disponibile, e l'intestazione precede il corpo.
    templateState.whenData(_initializeFrom);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final confirmed = await _confirmDialog(
          title: context.l10n.editDiscardTitle,
          message: context.l10n.editDiscardBody,
          confirmLabel: context.l10n.editDiscardConfirm,
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
            templateState.value?.name ?? context.l10n.templateScheduleTitle,
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
                              context.l10n.commonSave,
                              style: typography.label.copyWith(
                                color: _dirty ? colors.accent : colors.textTertiary,
                              ),
                            ),
                          ),
                    if (_dirty)
                      Text(context.l10n.editDiscardTitle, style: typography.caption.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
            ),
            // PA-2bis: fino a quattro settimane, e mai meno di una.
            if (_days != null && (_days!.canAddWeek || _days!.canRemoveWeek))
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'add-week') _addWeek();
                  if (value == 'remove-week') _removeWeek();
                },
                itemBuilder: (context) => [
                  if (_days!.canAddWeek)
                    PopupMenuItem(value: 'add-week', child: Text(context.l10n.scheduleAddWeek)),
                  if (_days!.canRemoveWeek)
                    PopupMenuItem(value: 'remove-week', child: Text(context.l10n.scheduleRemoveWeek)),
                ],
              ),
          ],
        ),
        body: SafeArea(
          child: templateState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                describeApiError(context, error.asApiException?.code ?? ''),
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
                      child: ScheduleNavigation(
                        days: _days!,
                        selectedWeek: _selectedWeek,
                        selectedDay: _selectedDay,
                        onSelectWeek: (week) => setState(() => _selectedWeek = week),
                        onSelectDay: (d) => setState(() => _selectedDay = d),
                        sidebar: true,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _buildDayEditor(day)),
                  ],
                );
              }

              return Column(
                children: [
                  ScheduleNavigation(
                    days: _days!,
                    selectedWeek: _selectedWeek,
                    selectedDay: _selectedDay,
                    onSelectWeek: (week) => setState(() => _selectedWeek = week),
                    onSelectDay: (d) => setState(() => _selectedDay = d),
                    sidebar: false,
                  ),
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
