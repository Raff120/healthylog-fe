import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/api/connectivity_status.dart';
import '../../data/plan_day.dart';
import '../../data/slot_status.dart';
import '../../data/slot_type.dart';
import '../../domain/plan_day_date.dart';
import '../../providers/meal_swap_providers.dart';
import '../../providers/plan_day_providers.dart';
import '../slot_type_presentation.dart';

/// Card di uno slot della giornata (4.1 interfaccia.md, VG-3, VG-4), con
/// la spunta (SP-1, F13) e, da espansa, l'avvio dell'inversione (6.5
/// interfaccia.md: "Vista giornaliera → Azione 'Sposta' nella card
/// espansa"), che conduce comunque alla settimanale per la scelta della
/// destinazione. A differenza di [SlotCard] (7.3, redazione) non
/// consente di modificarne il contenuto.
class MealCard extends ConsumerStatefulWidget {
  const MealCard({
    super.key,
    required this.slot,
    required this.date,
    required this.canCheck,
    required this.planId,
  });

  final PlanDaySlot slot;

  /// Giornata a cui appartiene lo slot (SP-8, SP-10): determina se la
  /// spunta va preceduta dall'avviso di data futura.
  final DateTime date;

  /// SP-11: false quando la giornata non è coperta da un piano Attivo —
  /// i pulsanti restano visibili ma disabilitati (4.1 interfaccia.md).
  final bool canCheck;

  /// Piano che copre la giornata, `null` se [canCheck] è `false`
  /// (nessuna inversione possibile senza un piano Attivo, IN-16).
  final String? planId;

  @override
  ConsumerState<MealCard> createState() => _MealCardState();
}

class _MealCardState extends ConsumerState<MealCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // Tiene in vita il controller (autoDispose) per la durata della
    // richiesta: senza un ascoltatore, verrebbe eliminato non appena il
    // gestore del tocco restituisce il controllo, prima che la risposta
    // asincrona possa scriverne lo stato (`UnmountedRefException`).
    ref.watch(planDaySlotStatusControllerProvider);

    // OF-20: nessuna scrittura è disponibile offline nella v1.
    final offline = !ref.watch(connectivityStatusProvider);

    final colors = context.colors;
    final typography = context.typography;
    final consumption = context.consumptionColors;
    final slot = widget.slot;

    final hasContent = slot.content?.trim().isNotEmpty ?? false;
    final hasRecipe = slot.recipeName?.trim().isNotEmpty ?? false;
    final hasNote = slot.note?.trim().isNotEmpty ?? false;

    // "Da consumare" non ha colore proprio (2.2): il bordo resta nel
    // divisore forte, non in un accento di stato.
    final statusColor = switch (slot.status) {
      SlotStatus.consumed => consumption.consumed,
      SlotStatus.skipped => consumption.skipped,
      SlotStatus.toConsume => colors.dividerStrong,
    };

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(slot.type.icon, size: 20, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _headerLabel(slot),
                      style: typography.overline.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (hasRecipe) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.soup_kitchen_outlined,
                            size: 16,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              slot.recipeName!.trim(),
                              style: typography.titleMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      hasContent ? slot.content!.trim() : 'Da definire',
                      style: typography.bodyLarge.copyWith(
                        color: hasContent
                            ? colors.textPrimary
                            : colors.textTertiary,
                      ),
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (_expanded && hasRecipe) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _openRecipeSheet(context, slot),
                          icon: Icon(
                            Icons.soup_kitchen_outlined,
                            size: 18,
                            color: colors.accent,
                          ),
                          label: Text(
                            'Vedi ricetta',
                            style: typography.label.copyWith(
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_expanded && _canMove) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _startMove(context),
                          icon: Icon(Icons.swap_horiz, size: 18, color: colors.accent),
                          label: Text('Sposta', style: typography.label.copyWith(color: colors.accent)),
                        ),
                      ),
                    ],
                    if (_expanded && hasNote) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              slot.note!.trim(),
                              style: typography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (hasContent) ...[
                const SizedBox(width: AppSpacing.xs),
                _SpuntaButtons(
                  status: slot.status,
                  enabled: widget.canCheck && !offline,
                  // SP-11 (piano non Attivo) resta silenzioso al tocco,
                  // come già: solo l'assenza di connessione, che
                  // altrimenti non avrebbe alcuna spiegazione visibile
                  // finché l'Utente non tenta la spunta (OF-21).
                  onDisabledTap: widget.canCheck && offline
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Non disponibile offline.')),
                          )
                      : null,
                  onSelect: (status) => _updateStatus(context, status),
                ),
              ],
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: AppSpacing.motionStateTransition,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// MS-8, condizioni 1/3/4 applicate a questo solo slot (stesso
  /// criterio di `isMealSwapOriginEligible`, qui senza un `PlanDay`
  /// completo a disposizione): [MealCard.canCheck] già vale "coverage
  /// Attivo" (SP-11).
  bool get _canMove =>
      widget.canCheck &&
      widget.planId != null &&
      widget.slot.status != SlotStatus.consumed &&
      !dateOnly(widget.date).isBefore(dateOnly(DateTime.now()));

  /// 6.5, 4.1 interfaccia.md: l'inversione si avvia anche dalla card
  /// espansa della vista giornaliera, ma la scelta della destinazione
  /// resta compito della vista settimanale, il solo contesto in cui
  /// origine e destinazione sono visibili insieme (VS-8).
  void _startMove(BuildContext context) {
    ref.read(mealSwapSelectionProvider.notifier).start(MealSwapOrigin(
          planId: widget.planId!,
          date: dateOnly(widget.date),
          slotId: widget.slot.slotId,
          type: widget.slot.type,
          status: widget.slot.status,
        ));
    ref.read(selectedPlanViewProvider.notifier).select(PlanViewMode.week);
  }

  /// SP-1: ciascun pulsante alterna fra il proprio stato e *Da consumare*
  /// (4.1 interfaccia.md) — non un ciclo fra i tre stati.
  SlotStatus _nextStatus(SlotStatus target) => widget.slot.status == target ? SlotStatus.toConsume : target;

  /// SP-10: la spunta su una giornata futura è una conferma semplice
  /// (4.5 interfaccia.md), non un vincolo — SP-8 lascia invece il passato
  /// senza alcuna limitazione.
  Future<void> _updateStatus(BuildContext context, SlotStatus target) async {
    final status = _nextStatus(target);
    if (dateOnly(widget.date).isAfter(dateOnly(DateTime.now()))) {
      final confirmed = await _confirmFutureDay(context);
      if (confirmed != true) return;
      if (!context.mounted) return;
    }
    await ref
        .read(planDaySlotStatusControllerProvider.notifier)
        .updateStatus(widget.date, widget.slot.slotId, status);
    if (!context.mounted) return;
    final state = ref.read(planDaySlotStatusControllerProvider);
    state?.whenOrNull(
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(error.asApiException?.code ?? ''))),
      ),
    );
  }

  /// "Spuntare un pasto su una data futura" — conferma semplice (4.5
  /// interfaccia.md, SP-10).
  Future<bool?> _confirmFutureDay(BuildContext context) {
    final colors = context.colors;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('Registrare un pasto futuro?'),
        content: const Text('Questo giorno non è ancora arrivato.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Spunta'),
          ),
        ],
      ),
    );
  }

  /// GG-10: lo spuntino usa la denominazione descrittiva assegnata nel
  /// piano quando presente, non l'etichetta generica del tipo.
  String _headerLabel(PlanDaySlot slot) {
    if (slot.type == SlotType.snack &&
        (slot.label?.trim().isNotEmpty ?? false)) {
      return slot.label!.trim();
    }
    return slot.type.displayName;
  }

  /// GG-15, GG-18: foglio modale a tre quarti di schermo. Il testo è
  /// libero e non strutturato: reso così com'è scritto (andate a capo ed
  /// elenchi puntati eventualmente già presenti), senza dedurne sezioni
  /// né alcuna interattività.
  void _openRecipeSheet(BuildContext context, PlanDaySlot slot) {
    final colors = context.colors;
    final typography = context.typography;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.75,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.recipeName!.trim(),
                  style: typography.titleLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      slot.recipeText?.trim().isNotEmpty == true
                          ? slot.recipeText!.trim()
                          : '',
                      style: typography.bodyLarge.copyWith(
                        color: colors.textPrimary,
                      ),
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

/// SP-1, SP-5: due pulsanti distinti, non un controllo ciclico — ogni
/// stato dista un tocco (4.1 interfaccia.md).
class _SpuntaButtons extends StatelessWidget {
  const _SpuntaButtons({
    required this.status,
    required this.enabled,
    this.onDisabledTap,
    required this.onSelect,
  });

  final SlotStatus status;
  final bool enabled;

  /// OF-21: spiega la ragione al tocco quando disabilitato per assenza
  /// di connessione — `null` per le altre ragioni (SP-11), che restano
  /// silenziose al tocco come già.
  final VoidCallback? onDisabledTap;
  final ValueChanged<SlotStatus> onSelect;

  @override
  Widget build(BuildContext context) {
    final consumption = context.consumptionColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SpuntaButton(
          icon: Icons.check,
          active: status == SlotStatus.consumed,
          enabled: enabled,
          color: consumption.consumed,
          background: consumption.consumedBackground,
          onTap: () => onSelect(SlotStatus.consumed),
          onDisabledTap: onDisabledTap,
        ),
        const SizedBox(height: AppSpacing.xxs),
        _SpuntaButton(
          icon: Icons.close,
          active: status == SlotStatus.skipped,
          enabled: enabled,
          color: consumption.skipped,
          background: consumption.skippedBackground,
          onTap: () => onSelect(SlotStatus.skipped),
          onDisabledTap: onDisabledTap,
        ),
      ],
    );
  }
}

/// Riscontro immediato al tocco (2.6 interfaccia.md: 120 ms). Disabilitato
/// e in colore terziario quando la spunta non è consentita (SP-11) o
/// non disponibile offline (OF-20).
class _SpuntaButton extends StatelessWidget {
  const _SpuntaButton({
    required this.icon,
    required this.active,
    required this.enabled,
    required this.color,
    required this.background,
    required this.onTap,
    this.onDisabledTap,
  });

  final IconData icon;
  final bool active;
  final bool enabled;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final VoidCallback? onDisabledTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: enabled ? onTap : onDisabledTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: AnimatedContainer(
          duration: AppSpacing.motionImmediate,
          curve: AppSpacing.motionImmediateCurve,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: active && enabled ? background : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: active && enabled ? color : colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
