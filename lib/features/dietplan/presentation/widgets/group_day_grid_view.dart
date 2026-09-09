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
import '../../data/slot_status.dart';
import '../../data/slot_type.dart';
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
/// tutti i membri, individuato dall'ordine dello slot nel piano (GG-8) —
/// lo stesso ordinamento con cui il backend materializza le giornate,
/// condiviso da chi ha uno schema con più o meno spuntini degli altri
/// (composizioni disomogenee, 6.3 interfaccia.md).
class _GroupRow {
  const _GroupRow({required this.order, required this.type, required this.label});

  final int order;
  final SlotType type;

  /// La denominazione descrittiva dello spuntino (GG-10) solo se tutti i
  /// membri che lo prevedono a questo ordine concordano; altrimenti
  /// l'etichetta generica del tipo (6.3 interfaccia.md: "la riga
  /// riporta la denominazione generica").
  final String? label;

  String displayLabel(BuildContext context) => label ?? slotTypeLabel(context, type);
}

List<_GroupRow> _buildRows(List<MemberPlanDay> members) {
  final byOrder = <int, (SlotType, Set<String?>)>{};
  for (final member in members) {
    for (final slot in member.slots) {
      final existing = byOrder[slot.order];
      if (existing == null) {
        byOrder[slot.order] = (slot.type, {slot.label});
      } else {
        existing.$2.add(slot.label);
      }
    }
  }
  final orders = byOrder.keys.toList()..sort();
  return [
    for (final order in orders)
      _GroupRow(
        order: order,
        type: byOrder[order]!.$1,
        label: byOrder[order]!.$1 == SlotType.snack && byOrder[order]!.$2.length == 1
            ? byOrder[order]!.$2.single
            : null,
      ),
  ];
}

PlanDaySlot? _slotAt(MemberPlanDay member, int order) {
  for (final slot in member.slots) {
    if (slot.order == order) return slot;
  }
  return null;
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
      child: SizedBox(
        height: _rowHeight,
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
                      slot: _slotAt(member, row.order),
                      date: date,
                      // CU-2, CU-3: sempre sulla propria colonna, o su
                      // qualunque altra se Cuoco.
                      canCheck: member.userId == currentUserId || isCook,
                      memberUserId: member.userId == currentUserId ? null : member.userId,
                    ),
                  ),
                ),
              ),
          ],
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

/// Card compatta e non espandibile (4.1, 6.3 interfaccia.md): le colonne
/// sono strette e l'espansione di una sfalserebbe le altre.
class _GroupSlotCell extends ConsumerWidget {
  const _GroupSlotCell({required this.slot, required this.date, required this.canCheck, this.memberUserId});

  final PlanDaySlot? slot;
  final DateTime date;

  /// CU-2, CU-3: il proprio piano sempre; quello di un altro membro solo
  /// se si è Cuoco del Gruppo.
  final bool canCheck;

  /// `null` per il proprio piano; altrimenti l'identificativo del
  /// membro su cui il Cuoco sta operando (CU-3, EP-2).
  final String? memberUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `ref.watch` (non solo `read`) tiene vivo il controller autoDispose
    // per la durata dell'operazione, sullo stesso criterio di MealCard.
    ref.watch(planDaySlotStatusControllerProvider);
    final colors = context.colors;
    final typography = context.typography;
    final consumption = context.consumptionColors;
    final slot = this.slot;

    if (slot == null) {
      // 6.3 interfaccia.md: "non uno spazio vuoto" — distingue "non
      // previsto" da "non ancora caricato".
      return Center(child: Container(height: 1, color: colors.textTertiary));
    }

    final hasContent = slot.content?.trim().isNotEmpty ?? false;
    final hasRecipe = slot.recipeName?.trim().isNotEmpty ?? false;
    final borderColor = switch (slot.status) {
      SlotStatus.consumed => consumption.consumed,
      SlotStatus.skipped => consumption.skipped,
      SlotStatus.toConsume => colors.dividerStrong,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: hasRecipe ? () => _openRecipeSheet(context, slot) : null,
                child: hasRecipe
                    ? Text(
                        slot.recipeName!.trim(),
                        style: typography.label.copyWith(color: colors.textPrimary),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        hasContent ? slot.content!.trim() : context.l10n.slotToBeDefined,
                        style: typography.bodyMedium.copyWith(
                          color: hasContent ? colors.textPrimary : colors.textTertiary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
            if (canCheck) ...[
              const SizedBox(height: AppSpacing.xxs),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CompactSpuntaButton(
                    icon: Icons.check,
                    active: slot.status == SlotStatus.consumed,
                    color: consumption.consumed,
                    onTap: () => _updateStatus(ref, slot, SlotStatus.consumed),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  _CompactSpuntaButton(
                    icon: Icons.close,
                    active: slot.status == SlotStatus.skipped,
                    color: consumption.skipped,
                    onTap: () => _updateStatus(ref, slot, SlotStatus.skipped),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateStatus(WidgetRef ref, PlanDaySlot slot, SlotStatus tapped) {
    final next = slot.status == tapped ? SlotStatus.toConsume : tapped;
    ref
        .read(planDaySlotStatusControllerProvider.notifier)
        .updateStatus(date, slot.slotId, next, userId: memberUserId);
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
                      (slot.content?.trim().isNotEmpty ?? false) ? slot.content!.trim() : context.l10n.slotToBeDefined,
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
