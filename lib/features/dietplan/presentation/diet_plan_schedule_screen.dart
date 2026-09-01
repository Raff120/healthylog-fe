import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_breakpoints.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../data/diet_plan.dart';
import '../data/diet_plan_requests.dart';
import '../data/plan_status.dart';
import '../data/slot_type.dart';
import '../data/weekday.dart';
import '../providers/diet_plan_providers.dart';
import '../providers/diet_plan_template_providers.dart';
import 'editable_slot.dart';
import 'slot_type_presentation.dart';
import 'widgets/day_selector.dart';
import 'widgets/day_sidebar.dart';
import 'widgets/name_description_dialog.dart';
import 'widgets/slot_card.dart';

final RegExp _recipeNameFieldPattern = RegExp(r'^days\[(\d+)\]\.slots\[(\d+)\]\.recipeName$');

/// Redazione dello schema settimanale (7.3 interfaccia.md, CD-5, CD-7,
/// CD-8, CD-10, CD-11, MP-6): un giorno per volta con selettore in cima
/// su `compact`, navigazione dei giorni affiancata alla redazione su
/// `expanded` e oltre (MP-6, 7.3 interfaccia.md).
///
/// La conferma del piano (CV-2) compare in fondo, solo in Bozza (7.3
/// interfaccia.md). Non compare invece la striscia informativa di
/// modifica di un piano attivo (5.3 funzionale, F22) — il backend
/// ammette la sostituzione dello schema solo sul piano in Bozza
/// (`PLAN_NOT_DRAFT`), unico caso qui possibile finché F22 non introduce
/// la modifica di un piano in corso. Il salvataggio come template (TP-5,
/// CD-18) compare nel menu dell'intestazione, disponibile in ogni
/// momento (7.3 interfaccia.md), non condizionato alle modifiche
/// pendenti.
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

  /// TP-5, CD-18: disponibile in ogni momento della redazione (7.3
  /// interfaccia.md), non condizionata alle modifiche pendenti — copia lo
  /// schema salvato sul server, non quello ancora in redazione locale.
  Future<void> _saveAsTemplate(String planName) async {
    final input = await showNameDescriptionDialog(
      context,
      title: 'Salva come template',
      confirmLabel: 'Salva',
      initialName: planName,
    );
    if (input == null) return;
    if (!mounted) return;
    final request = SaveDietPlanAsTemplateRequest(name: input.name, description: input.description);
    await ref.read(saveDietPlanAsTemplateControllerProvider.notifier).save(widget.planId, request);
    if (!mounted) return;
    final state = ref.read(saveDietPlanAsTemplateControllerProvider);
    state?.whenOrNull(
      data: (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template creato.'))),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
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

  /// CV-2, CD-13, CD-15: la completezza è verificata qui, sullo schema
  /// già salvato (l'azione resta disabilitata mentre restano modifiche
  /// pendenti, vedi `build`) — non serve attendere l'esito del server per
  /// sapere quali giorni mancano, `EditableDay.hasIncompleteSlot` lo dice
  /// già (CD-15).
  Future<void> _confirm() async {
    final incompleteDays = _days!.where((day) => day.hasIncompleteSlot).toList();
    if (incompleteDays.isNotEmpty) {
      await _showIncompleteDaysSheet(incompleteDays);
      return;
    }
    await ref.read(confirmDietPlanControllerProvider.notifier).confirm(widget.planId);
    if (!mounted) return;
    final state = ref.read(confirmDietPlanControllerProvider);
    state?.whenOrNull(
      data: (_) => context.pushReplacement('/profile/plans'),
      error: (error, _) {
        final exception = error.asApiException;
        if (exception?.code == 'PLAN_INCOMPLETE') {
          // Difformità fra lo stato locale e quello del server (raro: lo
          // schema è stato modificato altrove nel frattempo): si rimanda
          // comunque a un giorno, sul modello sotto, ma senza poter
          // essere puntuali quanto la verifica locale.
          setState(() => _selectedDay = _days!.first.dayOfWeek);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describeApiError(exception?.code ?? ''))),
        );
      },
    );
  }

  /// CD-15, TR-6: elenco puntuale dei giorni incompleti, ciascuno
  /// toccabile per raggiungerlo direttamente. `isScrollControlled` e
  /// l'elenco proprio (non un `Column` di soli `ListTile`) evitano un
  /// overflow quando lo schema è ancora quasi interamente da compilare —
  /// fino a sette giorni, più di quanti un foglio di altezza fissa ne
  /// contenga.
  Future<void> _showIncompleteDaysSheet(List<EditableDay> incompleteDays) {
    final colors = context.colors;
    final typography = context.typography;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
                child: Text('Schema incompleto', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final day in incompleteDays)
                      ListTile(
                        title: Text(day.dayOfWeek.label, style: typography.bodyLarge.copyWith(color: colors.textPrimary)),
                        subtitle: Text(
                          '${day.slots.where((slot) => slot.isEmpty).length} pasto/i senza contenuto',
                          style: typography.caption.copyWith(color: colors.textSecondary),
                        ),
                        trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          setState(() => _selectedDay = day.dayOfWeek);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Elenco degli slot del giorno selezionato e azioni di aggiunta
  /// (CD-7): comune a `compact` ed `expanded` (MP-6), a cui cambia solo
  /// ciò che vi si affianca.
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
    final planState = ref.watch(dietPlanScheduleControllerProvider(widget.planId));
    // Tiene vivo il controller per la durata del salvataggio come
    // template, e di quello della conferma (autoDispose li eliminerebbe
    // altrimenti fra un `ref.read` e l'altro, dato che nessun altro punto
    // li osserva).
    ref.watch(saveDietPlanAsTemplateControllerProvider);
    final confirming = ref.watch(confirmDietPlanControllerProvider)?.isLoading ?? false;

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
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'save-as-template') _saveAsTemplate(planState.value?.name ?? '');
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'save-as-template', child: Text('Salva come template')),
              ],
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

              // MP-6, MP-7: la disposizione dipende dalla larghezza della
              // finestra, non dalla piattaforma — la stessa soglia già
              // condivisa da tutte le schermate (app_breakpoints.dart).
              final Widget editor;
              if (context.breakpoint.isAtLeastExpanded) {
                editor = Row(
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
              } else {
                editor = Column(
                  children: [
                    DaySelector(days: _days!, selected: _selectedDay, onSelect: (d) => setState(() => _selectedDay = d)),
                    const Divider(height: 1),
                    Expanded(child: _buildDayEditor(day)),
                  ],
                );
              }

              // CV-2, 7.3 interfaccia.md: solo in Bozza. Il pulsante di
              // salvataggio già impedisce di lasciare modifiche pendenti
              // non riflesse nel piano che il server confermerebbe.
              if (plan.status != PlanStatus.draft) return editor;

              return Column(
                children: [
                  Expanded(child: editor),
                  const Divider(height: 1),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: AppPrimaryButton(
                        label: 'Conferma piano',
                        loading: confirming,
                        onPressed: _dirty ? null : _confirm,
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
