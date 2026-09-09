import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/diet_plan_requests.dart';
import '../data/plan_day.dart';
import '../data/plan_day_coverage.dart';
import '../data/slot_status.dart';
import '../data/slot_type.dart';
import '../domain/plan_day_date.dart';
import '../providers/plan_day_providers.dart';
import 'editable_slot.dart';
import 'slot_type_presentation.dart';
import 'widgets/slot_card.dart';

final RegExp _recipeNameFieldPattern = RegExp(r'^slots\[(\d+)\]\.recipeName$');

/// Modifica della singola occorrenza giornaliera (5.3 funzionale, MD-8,
/// MD-9, MD-10): altera il contenuto di una sola data senza toccare lo
/// schema settimanale. MD-11: la striscia in cima chiarisce che la
/// modifica riguarda la sola giornata e rimanda alla modifica dello
/// schema per le successive. MD-3: gli slot già consumati sono
/// presentati ma non modificabili né rimovibili.
///
/// Serve sia l'Utente autonomo sul proprio piano sia il Nutrizionista
/// sul piano del Paziente ([userId], EP-2, F22): la competenza è
/// verificata dal server (MD-15, UT-8), qui si riflette solo l'esito.
class EditPlanDayScreen extends ConsumerStatefulWidget {
  const EditPlanDayScreen({super.key, required this.date, this.userId});

  final DateTime date;
  final String? userId;

  @override
  ConsumerState<EditPlanDayScreen> createState() => _EditPlanDayScreenState();
}

class _EditPlanDayScreenState extends ConsumerState<EditPlanDayScreen> {
  List<EditableSlot>? _slots;
  final Set<String> _consumedSlotIds = {};
  bool _dirty = false;

  void _initializeFrom(PlanDay day) {
    if (_slots != null) return;
    _slots = day.slots.map(EditableSlot.fromPlanDaySlot).toList();
    _consumedSlotIds
      ..clear()
      ..addAll(day.slots.where((slot) => slot.status == SlotStatus.consumed).map((slot) => slot.slotId));
  }

  @override
  void dispose() {
    _slots?.forEach((slot) => slot.dispose());
    super.dispose();
  }

  bool _isConsumed(EditableSlot slot) => slot.slotId != null && _consumedSlotIds.contains(slot.slotId);

  void _markDirty() => setState(() => _dirty = true);

  void _addSlot(SlotType type) {
    setState(() {
      _slots!.add(EditableSlot.newSlot(type));
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
      _slots!.remove(slot);
      _dirty = true;
    });
    slot.dispose();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final slot = _slots!.removeAt(oldIndex);
      _slots!.insert(newIndex, slot);
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
    final request = UpdatePlanDayRequest(slots: _slots!.map((slot) => slot.toRequest()).toList());
    await ref.read(updatePlanDayControllerProvider.notifier).save(widget.date, request, userId: widget.userId);
    if (!mounted) return;
    final state = ref.read(updatePlanDayControllerProvider);
    state?.whenOrNull(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giornata salvata.')));
        setState(() => _dirty = false);
        if (context.canPop()) context.pop();
      },
      error: (error, _) => _handleSaveError(error),
    );
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
        final slot = _slots![int.parse(match.group(1)!)];
        slot.recipeNameError = 'Serve una denominazione se è presente il testo della ricetta';
        slot.expanded = true;
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            matchedRecipeField ? 'Controlla i campi della ricetta segnalati.' : describeApiError(context, 'VALIDATION_FAILED'),
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeApiError(context, exception?.code ?? ''))));
  }

  List<PopupMenuEntry<SlotType>> _addSlotMenuItems() => [
        for (final type in [SlotType.breakfast, SlotType.lunch, SlotType.dinner])
          PopupMenuItem(
            value: type,
            enabled: !_slots!.any((slot) => slot.type == type),
            child: Row(
              children: [
                Icon(type.icon, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Flexible(child: Text('Aggiungi ${type.displayName.toLowerCase()}', overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        PopupMenuItem(
          value: SlotType.snack,
          child: const Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: AppSpacing.xs),
              Flexible(child: Text('Aggiungi spuntino', overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ];

  /// MD-11: scelta esplicita e comprensibile tra la modifica della sola
  /// giornata e quella dello schema, che si ripercuote sulle successive.
  Widget _buildScopeBanner(String? planId) {
    final colors = context.colors;
    final typography = context.typography;
    return Container(
      width: double.infinity,
      color: colors.accentSubtle,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colors.accent),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Le modifiche riguardano solo questa giornata: lo schema settimanale resta invariato.',
                  style: typography.caption.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
          if (planId != null && widget.userId == null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                onPressed: () => context.pushReplacement('/diet-plans/$planId/schedule'),
                child: Text(
                  'Modifica invece lo schema, per tutte le giornate',
                  style: typography.caption.copyWith(color: colors.accent),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final dayState = ref.watch(planDayProvider(dateOnly(widget.date), userId: widget.userId));
    final saving = ref.watch(updatePlanDayControllerProvider)?.isLoading ?? false;
    dayState.whenData(_initializeFrom);

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
            'Giornata del ${_formatDate(widget.date)}',
            style: typography.titleMedium.copyWith(color: colors.textPrimary),
          ),
          actions: [
            if (_slots != null)
              PopupMenuButton<SlotType>(
                icon: const Icon(Icons.add),
                tooltip: 'Aggiungi',
                onSelected: _addSlot,
                itemBuilder: (context) => _addSlotMenuItems(),
              ),
          ],
        ),
        body: SafeArea(
          child: dayState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                describeApiError(context, error.asApiException?.code ?? ''),
                style: typography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ),
            data: (day) {
              if (day.coverage != PlanDayCoverage.active) {
                return const EmptyStateView(
                  icon: Icons.event_busy,
                  title: 'Giornata non modificabile',
                  text: 'Solo le giornate coperte da un piano attivo possono essere modificate',
                );
              }
              final slots = _slots!;
              return Column(
                children: [
                  _buildScopeBanner(day.planId),
                  Expanded(
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: slots.length,
                      onReorderItem: _reorder,
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        if (_isConsumed(slot)) {
                          return _ConsumedSlotCard(key: ValueKey(slot), slot: slot, index: index);
                        }
                        return SlotCard(
                          key: ValueKey(slot),
                          slot: slot,
                          index: index,
                          onChanged: _markDirty,
                          onRemove: () => _removeSlot(slot),
                          showAdherenceWeight: false,
                        );
                      },
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border(top: BorderSide(color: colors.dividerStrong)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: AppPrimaryButton(label: 'Salva giornata', loading: saving, onPressed: _dirty ? _save : null),
                      ),
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

/// MD-3, NU-8: lo slot già consumato è un dato storico — presentato
/// chiuso, riordinabile ma non modificabile né rimovibile.
class _ConsumedSlotCard extends StatelessWidget {
  const _ConsumedSlotCard({super.key, required this.slot, required this.index});

  final EditableSlot slot;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors.dividerLight),
      ),
      child: Row(
        children: [
          Icon(slot.type.icon, color: colors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.type == SlotType.snack && slot.labelController.text.trim().isNotEmpty
                      ? slot.labelController.text.trim()
                      : slot.type.displayName,
                  style: typography.bodyLarge.copyWith(color: colors.textSecondary),
                ),
                Text(
                  slot.contentController.text.trim().isEmpty ? 'Non specificato' : slot.contentController.text.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.caption.copyWith(color: colors.textTertiary),
                ),
                Text('Già consumato: non modificabile', style: typography.caption.copyWith(color: colors.textTertiary)),
              ],
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              child: Icon(Icons.drag_handle, color: colors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
