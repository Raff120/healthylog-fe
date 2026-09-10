import '../../../../l10n/l10n_context.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../data/group_plan_day.dart';
import '../../data/plan_day.dart';
import '../../data/plan_day_coverage.dart';
import '../../data/slot_status.dart';
import '../../data/slot_type.dart';
import '../../domain/plan_day_date.dart';
import '../../providers/meal_swap_providers.dart';
import '../../providers/plan_day_providers.dart';
import '../slot_type_presentation.dart';

const double _labelColumnWidth = 72;
const double _memberColumnWidth = 140;
const double _headerHeight = 56;
const double _rowHeight = 96;

/// SY-20, 10 tecnica: unico contesto in cui più persone operano sui
/// medesimi dati — il client si aggiorna a questo intervallo mentre la
/// vista resta aperta.
const _sideBySideRefreshInterval = Duration(seconds: 60);

/// Una riga della griglia (VG-14): un momento della giornata comune a
/// tutti i membri.
///
/// Il raggruppamento è per **tipo di slot**, non per posizione
/// nell'ordinamento: colazione, pranzo e cena sono al più uno per
/// giornata (GG-5) e individuano da sé la propria riga, quale che sia il
/// numero di slot che li precedono. Allinearli per `order`, come si
/// faceva, collocava il pranzo di chi non fa colazione nella riga della
/// colazione (segnalato dall'utente).
///
/// Gli spuntini, numericamente liberi (GG-4), si allineano invece per
/// posizione dentro il tratto di giornata delimitato dai tre pasti
/// principali: il primo spuntino del mattino di ciascuno sta con quello
/// degli altri, il secondo con il secondo, e le righe eccedenti recano
/// il tratto di assenza per chi non le prevede (6.3 interfaccia.md,
/// "composizioni disomogenee").
class _GroupRow {
  const _GroupRow({required this.type, required this.label, required this.slots});

  final SlotType type;

  /// La denominazione descrittiva dello spuntino (GG-10) solo se tutti i
  /// membri che lo prevedono in questa riga concordano; altrimenti
  /// l'etichetta generica del tipo (6.3 interfaccia.md: "la riga
  /// riporta la denominazione generica").
  final String? label;

  /// Lo slot di ciascun membro in questa riga, per identificativo:
  /// assente per chi non lo prevede.
  final Map<String, PlanDaySlot> slots;

  String displayLabel(BuildContext context) => label ?? slotTypeLabel(context, type);
}

/// I tre pasti principali nella sequenza della giornata. Sono le ancore
/// dell'allineamento: al più uno per giornata (GG-5), e quindi in
/// quest'ordine per chiunque.
const _anchorTypes = [SlotType.breakfast, SlotType.lunch, SlotType.dinner];

/// Il rango dell'ancora, `null` per lo spuntino — che non delimita
/// alcun tratto, essendone previsto un numero libero (GG-4).
int? _anchorRank(SlotType type) {
  final rank = _anchorTypes.indexOf(type);
  return rank == -1 ? null : rank;
}

List<_GroupRow> _buildRows(List<MemberPlanDay> members) {
  // Il tratto di giornata a cui appartiene uno spuntino: 0 prima della
  // colazione, 1 fra colazione e pranzo, 2 fra pranzo e cena, 3 dopo
  // cena. Per ciascun tratto, gli spuntini nella loro sequenza.
  final snacksBySegment = <int, List<Map<String, PlanDaySlot>>>{};
  final anchorSlots = <SlotType, Map<String, PlanDaySlot>>{};

  for (final member in members) {
    final slots = [...member.slots]..sort((a, b) => a.order.compareTo(b.order));

    // Il rango del pasto principale che segue ciascuna posizione: è esso
    // a collocare lo spuntino, sicché quello del mattino di chi non fa
    // colazione sta comunque con quello degli altri.
    final nextAnchor = List<int?>.filled(slots.length, null);
    int? following;
    for (var i = slots.length - 1; i >= 0; i--) {
      nextAnchor[i] = following;
      following = _anchorRank(slots[i].type) ?? following;
    }

    int? previous;
    final countBySegment = <int, int>{};
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      final rank = _anchorRank(slot.type);
      if (rank != null) {
        (anchorSlots[slot.type] ??= {})[member.userId] = slot;
        previous = rank;
        continue;
      }
      // Nessun pasto principale a seguire: lo spuntino sta nel tratto
      // che si apre dopo l'ultimo incontrato — dopo cena, o in coda a
      // una giornata che alla cena non arriva.
      final segment = nextAnchor[i] ?? (previous == null ? 0 : previous + 1);
      final index = countBySegment[segment] ?? 0;
      countBySegment[segment] = index + 1;
      final rows = snacksBySegment.putIfAbsent(segment, () => []);
      while (rows.length <= index) {
        rows.add(<String, PlanDaySlot>{});
      }
      rows[index][member.userId] = slot;
    }
  }

  final rows = <_GroupRow>[];
  void addSnacks(int segment) {
    for (final slots in snacksBySegment[segment] ?? const <Map<String, PlanDaySlot>>[]) {
      rows.add(_GroupRow(type: SlotType.snack, label: _sharedLabel(slots.values), slots: slots));
    }
  }

  for (var segment = 0; segment < _anchorTypes.length; segment++) {
    addSnacks(segment);
    final slots = anchorSlots[_anchorTypes[segment]];
    if (slots != null) {
      rows.add(_GroupRow(type: _anchorTypes[segment], label: null, slots: slots));
    }
  }
  addSnacks(_anchorTypes.length);
  return rows;
}

/// GG-10: la denominazione descrittiva vale per l'intera riga solo se
/// tutti i membri che vi prevedono uno spuntino concordano — un solo
/// valore distinto, `null` compreso.
String? _sharedLabel(Iterable<PlanDaySlot> slots) {
  final labels = {for (final slot in slots) slot.label};
  return labels.length == 1 ? labels.single : null;
}

/// Modalità affiancata (VG-12, VG-13, VG-14, 6.3 interfaccia.md): i
/// pasti di tutti i membri del Gruppo nella stessa giornata, raggruppati
/// per tipo di slot. Nessun allenamento, nota di sostituzione,
/// misurazione o indicatore aggregato — solo ciò che chi cucina deve
/// sapere.
///
/// SY-20: mentre resta montata, un timer periodico rinnova
/// silenziosamente i dati (`AsyncValue.when` non mostra l'indicatore di
/// caricamento durante un refresh con un valore già presente, per
/// costruzione — nessun codice ulteriore necessario per la dissolvenza
/// silenziosa di 6.3 interfaccia.md). Il timer si ferma alla chiusura
/// della vista (`dispose`), mai altrove.
class GroupDayGridView extends ConsumerStatefulWidget {
  const GroupDayGridView({super.key, required this.date, required this.currentUserId});

  final DateTime date;
  final String currentUserId;

  @override
  ConsumerState<GroupDayGridView> createState() => _GroupDayGridViewState();
}

class _GroupDayGridViewState extends ConsumerState<GroupDayGridView> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(
      _sideBySideRefreshInterval,
      (_) => ref.invalidate(groupPlanDayProvider(widget.date)),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;
    final groupDayState = ref.watch(groupPlanDayProvider(widget.date));
    // CU-2, CU-3: il Cuoco può spuntare su ogni colonna, non solo la
    // propria.
    final isCook = ref.watch(isCookProvider);

    return groupDayState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          describeApiError(context, error.asApiException?.code ?? ''),
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ),
      data: (groupDay) =>
          _Grid(groupDay: groupDay, date: widget.date, currentUserId: widget.currentUserId, isCook: isCook),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.groupDay, required this.date, required this.currentUserId, required this.isCook});

  final GroupPlanDay groupDay;
  final DateTime date;
  final String currentUserId;
  final bool isCook;

  @override
  Widget build(BuildContext context) {
    final members = groupDay.members;
    final rows = _buildRows(members);

    if (rows.isEmpty) {
      final typography = context.typography;
      final colors = context.colors;
      return Center(
        child: Text(context.l10n.planNoMealsPlanned, style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
      );
    }

    // 3.3, 6.3 interfaccia.md: `compact` mostra due colonne, `medium`
    // tre, `expanded` e oltre tutte insieme a larghezza distribuita —
    // senza mai scendere sotto una larghezza leggibile, oltre la quale
    // subentra lo scorrimento orizzontale anche a `expanded`.
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = _columnWidthFor(context.breakpoint, constraints.maxWidth, members.length);
        final totalWidth = _labelColumnWidth + members.length * columnWidth;
        final needsHorizontalScroll = totalWidth > constraints.maxWidth;

        final grid = SizedBox(
          width: needsHorizontalScroll ? totalWidth : constraints.maxWidth,
          child: Column(
            children: [
              _HeaderRow(members: members, currentUserId: currentUserId, columnWidth: columnWidth),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final row in rows)
                        _DataRow(
                          row: row,
                          members: members,
                          date: date,
                          currentUserId: currentUserId,
                          columnWidth: columnWidth,
                          isCook: isCook,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        return needsHorizontalScroll
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: grid)
            : grid;
      },
    );
  }
}

double _columnWidthFor(AppBreakpoint breakpoint, double availableWidth, int memberCount) {
  if (memberCount == 0) return _memberColumnWidth;
  final usableWidth = availableWidth - _labelColumnWidth;
  final visibleColumns = switch (breakpoint) {
    AppBreakpoint.compact => 2,
    AppBreakpoint.medium => 3,
    AppBreakpoint.expanded || AppBreakpoint.large => memberCount,
  };
  if (visibleColumns >= memberCount) {
    return (usableWidth / memberCount).clamp(_memberColumnWidth, double.infinity);
  }
  return usableWidth / visibleColumns;
}

/// Intestazione delle colonne (6.3 interfaccia.md): riga fissa in cima,
/// che permane allo scorrimento verticale (garantito qui dallo stare
/// fuori dallo `SingleChildScrollView` verticale del corpo).
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.members, required this.currentUserId, required this.columnWidth});

  final List<MemberPlanDay> members;
  final String currentUserId;
  final double columnWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.dividerLight)),
      ),
      child: SizedBox(
        height: _headerHeight,
        child: Row(
          children: [
            const SizedBox(width: _labelColumnWidth),
            for (final member in members)
              SizedBox(
                width: columnWidth,
                child: _HeaderCell(member: member, isSelf: member.userId == currentUserId),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.member, required this.isSelf});

  final MemberPlanDay member;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return DecoratedBox(
      // La colonna propria si distingue con un fondo appena diverso
      // (6.3 interfaccia.md), senza dover leggere il nome.
      decoration: BoxDecoration(color: isSelf ? colors.surfaceAlt : null),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: colors.surfaceAlt,
              child: Icon(Icons.person_outline, size: 18, color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              member.firstName,
              style: typography.label.copyWith(color: colors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.row,
    required this.members,
    required this.date,
    required this.currentUserId,
    required this.columnWidth,
    required this.isCook,
  });

  final _GroupRow row;
  final List<MemberPlanDay> members;
  final DateTime date;
  final String currentUserId;
  final double columnWidth;
  final bool isCook;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.dividerLight))),
      // L'altezza della riga è ora un minimo, non una misura fissa: la
      // card espansa (4.1) la fa crescere, e le celle affiancate
      // crescono con essa restando allineate — è la riga a cedere, non
      // la griglia. `IntrinsicHeight` costa una misurazione in più per
      // riga, trascurabile su una griglia di poche righe e poche
      // colonne quale è per natura quella di un Gruppo.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _rowHeight),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: _labelColumnWidth, child: _RowLabel(row: row)),
              for (final member in members)
                SizedBox(
                  width: columnWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: member.userId == currentUserId ? colors.surfaceAlt : null),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      child: _GroupSlotCell(
                        slot: row.slots[member.userId],
                        member: member,
                        date: date,
                        isSelf: member.userId == currentUserId,
                        // CU-2, CU-3: sempre sulla propria colonna, o su
                        // qualunque altra se Cuoco.
                        canOperate: member.userId == currentUserId || isCook,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colonna fissa a sinistra, larga 72 (6.3 interfaccia.md): icona del
/// tipo di slot e l'etichetta in `overline`, colore secondario.
class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.row});

  final _GroupRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(row.type.icon, size: 20, color: colors.textSecondary),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            row.displayLabel(context),
            textAlign: TextAlign.center,
            style: typography.overline.copyWith(color: colors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Card di uno slot nella colonna di un membro (4.1, 6.3
/// interfaccia.md). È un **pannello espandibile** come quella della
/// vista giornaliera: chiusa presenta l'essenziale e consente la spunta,
/// aperta il contenuto integrale, la nota accessoria e l'inversione.
///
/// 6.3 la voleva non espandibile "perché l'espansione di una sfalserebbe
/// le altre": non accade, essendo la riga a crescere per intero (vedi
/// `_DataRow` e decisioni.md).
class _GroupSlotCell extends ConsumerStatefulWidget {
  const _GroupSlotCell({
    required this.slot,
    required this.member,
    required this.date,
    required this.isSelf,
    required this.canOperate,
  });

  /// `null` quando il membro non prevede alcuno slot in questa riga.
  final PlanDaySlot? slot;

  final MemberPlanDay member;
  final DateTime date;

  /// La propria colonna: nessun `userId` da inviare al server, ed è la
  /// sola su cui operi anche chi non è Cuoco.
  final bool isSelf;

  /// CU-2, CU-3, UT-12: il proprio piano sempre; quello di un altro
  /// membro solo se si è Cuoco del Gruppo. Vale tanto per la spunta
  /// quanto per l'inversione (VG-13, IG-1).
  final bool canOperate;

  @override
  ConsumerState<_GroupSlotCell> createState() => _GroupSlotCellState();
}

class _GroupSlotCellState extends ConsumerState<_GroupSlotCell> {
  bool _expanded = false;

  /// CU-3, EP-2: `null` per il proprio piano; altrimenti il membro su
  /// cui il Cuoco sta operando.
  String? get _memberUserId => widget.isSelf ? null : widget.member.userId;

  @override
  Widget build(BuildContext context) {
    // `ref.watch` (non solo `read`) tiene vivo il controller autoDispose
    // per la durata dell'operazione, sullo stesso criterio di MealCard.
    ref.watch(planDaySlotStatusControllerProvider);
    final colors = context.colors;
    final typography = context.typography;
    final consumption = context.consumptionColors;
    final slot = widget.slot;

    if (slot == null) {
      // 6.3 interfaccia.md: "non uno spazio vuoto" — distingue "non
      // previsto" da "non ancora caricato".
      return Center(child: Container(height: 1, color: colors.textTertiary));
    }

    final hasContent = slot.content?.trim().isNotEmpty ?? false;
    final hasRecipe = slot.recipeName?.trim().isNotEmpty ?? false;
    final hasNote = slot.note?.trim().isNotEmpty ?? false;
    final borderColor = switch (slot.status) {
      SlotStatus.consumed => consumption.consumed,
      SlotStatus.skipped => consumption.skipped,
      SlotStatus.toConsume => colors.dividerStrong,
    };

    // 6.3 interfaccia.md: il tocco sulla denominazione della ricetta
    // apre il foglio della ricetta, "che a chi cucina serve più che a
    // chiunque altro" — resta un bersaglio distinto da quello che
    // espande, anche da card aperta.
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasRecipe)
          GestureDetector(
            onTap: () => _openRecipeSheet(context, slot),
            child: Text(
              slot.recipeName!.trim(),
              style: typography.label.copyWith(color: colors.textPrimary),
              maxLines: _expanded ? null : 3,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        // A card chiusa con una ricetta il contenuto cede il posto alla
        // denominazione, che è il dato utile a chi cucina; aperta,
        // compaiono entrambi.
        if (!hasRecipe || _expanded) ...[
          if (hasRecipe) const SizedBox(height: AppSpacing.xxs),
          Text(
            hasContent ? slot.content!.trim() : context.l10n.slotToBeDefined,
            style: typography.bodyMedium.copyWith(
              color: hasContent ? colors.textPrimary : colors.textTertiary,
            ),
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ],
        // GG-14: la nota accessoria non è fra ciò che 6.3 esclude dalla
        // modalità affiancata, ed è spesso proprio un'avvertenza per chi
        // prepara.
        if (_expanded && hasNote) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  slot.note!.trim(),
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
        if (_expanded && _canMove(slot)) ...[
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _startMove(slot),
              icon: Icon(Icons.swap_horiz, size: 18, color: colors.accent),
              label: Text(context.l10n.mealMove, style: typography.label.copyWith(color: colors.accent)),
            ),
          ),
        ],
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chiusa, il corpo occupa l'altezza della riga e tiene i
              // comandi in basso; aperta, li spinge in fondo a sé.
              if (_expanded) body else Expanded(child: body),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  // 4.1 interfaccia.md: l'indicatore segnala che la card
                  // è espandibile, ruotando di 180° all'apertura.
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AppSpacing.motionStateTransition,
                    child: Icon(Icons.keyboard_arrow_down, size: 16, color: colors.textTertiary),
                  ),
                  const Spacer(),
                  if (widget.canOperate) ...[
                    _CompactSpuntaButton(
                      icon: Icons.check,
                      active: slot.status == SlotStatus.consumed,
                      color: consumption.consumed,
                      onTap: () => _updateStatus(slot, SlotStatus.consumed),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    _CompactSpuntaButton(
                      icon: Icons.close,
                      active: slot.status == SlotStatus.skipped,
                      color: consumption.skipped,
                      onTap: () => _updateStatus(slot, SlotStatus.skipped),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStatus(PlanDaySlot slot, SlotStatus tapped) {
    final next = slot.status == tapped ? SlotStatus.toConsume : tapped;
    ref
        .read(planDaySlotStatusControllerProvider.notifier)
        .updateStatus(widget.date, slot.slotId, next, userId: _memberUserId);
  }

  /// MS-8, condizioni 1/3/4 applicate a questo solo slot — lo stesso
  /// criterio di `isMealSwapOriginEligible`, qui su una giornata di
  /// gruppo anziché su un `PlanDay`. La facoltà è quella di [canOperate]
  /// (VG-13, IG-1, CU-2: il Cuoco su ogni colonna; UT-12: gli altri
  /// sulla propria).
  bool _canMove(PlanDaySlot slot) =>
      widget.canOperate &&
      widget.member.coverage == PlanDayCoverage.active &&
      widget.member.planId != null &&
      slot.status != SlotStatus.consumed &&
      !dateOnly(widget.date).isBefore(dateOnly(DateTime.now()));

  /// VG-13, IG-1: l'inversione è disponibile anche in modalità
  /// affiancata. La scelta della destinazione resta però compito della
  /// vista settimanale (VS-8, 6.5 interfaccia.md), il solo contesto in
  /// cui origine e destinazione sono visibili insieme: l'avvio vi
  /// conduce, dopo aver reso corrente il membro di quella colonna —
  /// sicché la settimanale ne mostra le giornate e l'intestazione ne
  /// dichiara il nome (VG-11).
  void _startMove(PlanDaySlot slot) {
    ref.read(selectedGroupMemberProvider.notifier).select(_memberUserId);
    ref.read(sideBySideModeProvider.notifier).disable();
    ref.read(mealSwapSelectionProvider.notifier).start(MealSwapOrigin(
          planId: widget.member.planId!,
          date: dateOnly(widget.date),
          slotId: slot.slotId,
          type: slot.type,
          status: slot.status,
        ));
    ref.read(selectedPlanViewProvider.notifier).select(PlanViewMode.week);
  }

  void _openRecipeSheet(BuildContext context, PlanDaySlot slot) {
    final colors = context.colors;
    final typography = context.typography;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.6,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slot.recipeName!.trim(), style: typography.titleMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _recipeSheetText(context, slot),
                      style: typography.bodyLarge.copyWith(color: colors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Il testo integrale della ricetta (GG-18); in sua assenza il
/// contenuto dello slot, che resta l'unica cosa da leggere.
String _recipeSheetText(BuildContext context, PlanDaySlot slot) {
  if (slot.recipeText?.trim().isNotEmpty ?? false) return slot.recipeText!.trim();
  if (slot.content?.trim().isNotEmpty ?? false) return slot.content!.trim();
  return context.l10n.slotToBeDefined;
}

class _CompactSpuntaButton extends StatelessWidget {
  const _CompactSpuntaButton({required this.icon, required this.active, required this.color, required this.onTap});

  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: active ? color : context.colors.textTertiary),
        ),
      ),
    );
  }
}
