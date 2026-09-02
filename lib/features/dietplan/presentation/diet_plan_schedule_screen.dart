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
import 'widgets/delete_plan_dialog.dart';
import 'widgets/name_description_dialog.dart';
import 'widgets/slot_card.dart';

final RegExp _recipeNameFieldPattern = RegExp(r'^days\[(\d+)\]\.slots\[(\d+)\]\.recipeName$');

/// Redazione dello schema settimanale (7.3 interfaccia.md, CD-5, CD-7,
/// CD-8, CD-10, CD-11, MP-6): un giorno per volta con selettore in cima
/// su `compact`, navigazione dei giorni affiancata alla redazione su
/// `expanded` e oltre (MP-6, 7.3 interfaccia.md).
///
/// La stessa schermata serve anche la modifica di un piano Attivo o
/// Sospeso (5.3 funzionale, MD-1): una striscia informativa avverte che
/// le modifiche decorrono da oggi (MD-2, MD-3), e "Conferma piano" è
/// sostituito da "Salva modifiche" (7.3 interfaccia.md). Il salvataggio
/// come template (TP-5, CD-18) e l'eliminazione (CV-10, CV-11) compaiono
/// nel menu dell'intestazione, disponibili in ogni momento — l'una non
/// condizionata alle modifiche pendenti, l'altra assente per l'Attivo,
/// che CV-11 esclude.
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

  /// MD-7: su un piano non più in Bozza (Attivo o Sospeso) uno schema
  /// incompleto non si salva — a differenza della Bozza, dove restare
  /// incompleti durante la redazione è normale. Stessa verifica locale
  /// di `_confirm` (CD-15), applicata qui solo quando rilevante.
  Future<void> _save() async {
    final status = ref.read(dietPlanScheduleControllerProvider(widget.planId)).value?.status;
    if (status != null && status != PlanStatus.draft) {
      final incompleteDays = _days!.where((day) => day.hasIncompleteSlot).toList();
      if (incompleteDays.isNotEmpty) {
        await _showIncompleteDaysSheet(incompleteDays);
        return;
      }
    }
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

  /// CV-10, CV-11: eliminazione definitiva, assente dal menu per l'Attivo
  /// (vedi `build`) — il server la rifiuta comunque, questa è solo
  /// l'anticipazione in interfaccia della stessa regola.
  Future<void> _delete(PlanStatus status) async {
    final confirmed = await confirmDeletePlan(context, status);
    if (!confirmed) return;
    if (!mounted) return;
    await ref.read(dietPlanLifecycleControllerProvider.notifier).delete(widget.planId);
    if (!mounted) return;
    final state = ref.read(dietPlanLifecycleControllerProvider);
    state?.whenOrNull(
      data: (_) => context.pushReplacement('/profile/plans'),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
      ),
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

  /// Elenco degli slot del giorno selezionato (CD-7): comune a `compact`
  /// ed `expanded` (MP-6), a cui cambia solo ciò che vi si affianca.
  /// L'aggiunta di uno slot non compare più qui in coda (7.3
  /// interfaccia.md), ma nel menu "+" dell'intestazione — deviazione
  /// deliberata, vedi decisioni.md: la fascia fissa in coda, sommata a
  /// quella di "Conferma piano", lasciava troppo poco spazio all'elenco
  /// scorrevole su schermi reali di altezza ridotta.
  Widget _buildDayEditor(EditableDay day) {
    return ReorderableListView.builder(
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
    );
  }

  /// Menu "+" dell'intestazione (7.3 interfaccia.md, GG-5): un'unica voce
  /// di ingresso invece di quattro pulsanti separati, con lo stesso
  /// criterio di disabilitazione di prima — colazione/pranzo/cena solo
  /// se non già presenti, spuntino sempre.
  List<PopupMenuEntry<SlotType>> _addSlotMenuItems(EditableDay day) => [
        for (final type in [SlotType.breakfast, SlotType.lunch, SlotType.dinner])
          PopupMenuItem(
            value: type,
            enabled: !day.hasType(type),
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

  /// MD-2, MD-3, 7.3 interfaccia.md: unica differenza di contenuto, oltre
  /// al pulsante finale, fra la redazione di una Bozza e la modifica di un
  /// piano Attivo o Sospeso.
  Widget _buildActiveEditBanner() {
    final colors = context.colors;
    final typography = context.typography;
    return Container(
      width: double.infinity,
      color: colors.accentSubtle,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: colors.accent),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Le modifiche decorrono da oggi: le giornate già trascorse restano invariate.',
              style: typography.caption.copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// Fascia fissa in fondo, comune a "Conferma piano" (Bozza, CV-2) e
  /// "Salva modifiche" (Attivo o Sospeso, MD-1) — cambia solo l'etichetta
  /// e l'azione, non la disposizione.
  Widget _bottomActionBar({required String label, required bool loading, required VoidCallback? onPressed}) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.dividerStrong)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppPrimaryButton(label: label, loading: loading, onPressed: onPressed),
        ),
      ),
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
    ref.watch(dietPlanLifecycleControllerProvider);
    final confirming = ref.watch(confirmDietPlanControllerProvider)?.isLoading ?? false;
    // Inizializza `_days` prima dello Scaffold, non dentro il solo `data:`
    // del corpo: il menu "+" dell'intestazione ne ha bisogno fin dal primo
    // fotogramma in cui il piano è disponibile, e l'intestazione è
    // costruita prima del corpo nello stesso `build`.
    planState.whenData(_initializeFrom);

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
            if (_days != null)
              PopupMenuButton<SlotType>(
                icon: const Icon(Icons.add),
                tooltip: 'Aggiungi',
                onSelected: _addSlot,
                itemBuilder: (context) => _addSlotMenuItems(_currentDay),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'save-as-template') _saveAsTemplate(planState.value?.name ?? '');
                if (value == 'delete') _delete(planState.value!.status);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'save-as-template', child: Text('Salva come template')),
                // CV-11: l'Attivo non compare, il server la rifiuterebbe comunque.
                if (planState.value != null && planState.value!.status != PlanStatus.active)
                  PopupMenuItem(value: 'delete', child: Text('Elimina', style: TextStyle(color: colors.error))),
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
                    // Pannello di superficie invece di un divisore a
                    // riga piena (stesso trattamento della barra di
                    // navigazione principale, `main_shell.dart`): lo
                    // stacco resta leggibile senza la riga netta che
                    // dava, sui dispositivi reali, la sensazione di un
                    // taglio (vedi decisioni.md).
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border(bottom: BorderSide(color: colors.dividerStrong)),
                      ),
                      child: DaySelector(
                        days: _days!,
                        selected: _selectedDay,
                        onSelect: (d) => setState(() => _selectedDay = d),
                      ),
                    ),
                    Expanded(child: _buildDayEditor(day)),
                  ],
                );
              }

              // MD-1, MD-2, MD-3, 7.3 interfaccia.md: la stessa schermata
              // serve anche la modifica di un piano Attivo o Sospeso, con
              // la sola striscia informativa in più e "Salva modifiche" al
              // posto di "Conferma piano" — Programmato e Concluso non vi
              // giungono mai (il primo passa per il ritiro, MD-1; il
              // secondo ha la propria vista di sola lettura, 7.5), ma
              // restano privi di fascia fissa per sicurezza.
              final isActiveEdit = plan.status == PlanStatus.active || plan.status == PlanStatus.suspended;
              final content = isActiveEdit
                  ? Column(children: [_buildActiveEditBanner(), Expanded(child: editor)])
                  : editor;

              if (plan.status == PlanStatus.draft) {
                return Column(
                  children: [
                    Expanded(child: content),
                    _bottomActionBar(
                      label: 'Conferma piano',
                      loading: confirming,
                      onPressed: _dirty ? null : _confirm,
                    ),
                  ],
                );
              }

              if (isActiveEdit) {
                return Column(
                  children: [
                    Expanded(child: content),
                    _bottomActionBar(
                      label: 'Salva modifiche',
                      loading: _saving,
                      onPressed: _dirty ? _save : null,
                    ),
                  ],
                );
              }

              return content;
            },
          ),
        ),
      ),
    );
  }
}
