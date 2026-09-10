import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../group/data/cooking_group.dart';
import '../../../group/providers/cooking_group_providers.dart';
import '../../../identity/providers/profile_providers.dart';
import '../../providers/plan_day_providers.dart';

/// Massimo di membri oltre il quale la riga di avatar lascia il posto al
/// menu a discesa (4.2 interfaccia.md: "quando i membri superano i
/// sei"). Su schermo stretto il menu compare comunque, a prescindere
/// dal numero.
const _maxInlineAvatars = 6;

/// Selettore del membro (4.2 interfaccia.md; VG-7, VG-8): compare
/// nell'intestazione di *Piano* per i soli Utenti appartenenti a un
/// Gruppo. `RESOURCE_NOT_FOUND` (404) significa assenza di Gruppo — lo
/// stesso criterio già seguito da `GroupScreen` (F19) — e non mostra
/// alcunché, senza segnalare errore.
///
/// Limitato per ora allo scambio di membro (VG-7, VG-9): l'icona della
/// modalità affiancata (VG-12) è compito del task successivo di F20, che
/// introduce quella vista.
class MemberSelector extends ConsumerWidget {
  const MemberSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(currentCookingGroupProvider);
    // RG-3: un `RESOURCE_NOT_FOUND` significa assenza di Gruppo; ogni
    // altro errore non ha comunque un'azione sensata da offrire qui —
    // in entrambi i casi nessuna traccia del selettore (8.1 interfaccia.md).
    return groupState.when(
      loading: SizedBox.shrink,
      error: (_, _) => const SizedBox.shrink(),
      data: (group) => _MemberRow(group: group),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({required this.group});

  final CookingGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedGroupMemberProvider);
    final sideBySide = ref.watch(sideBySideModeProvider);
    // GE-13: lo stesso criterio già seguito da GroupScreen (F19) per
    // riconoscere la propria voce fra i membri.
    final currentUserId = ref.watch(profileControllerProvider).value?.id;
    final compact = context.breakpoint.isCompact || group.members.length > _maxInlineAvatars;

    // VG-9: scegliere esplicitamente un membro è l'azione "torna alla
    // vista del singolo" — disattiva sempre la modalità affiancata,
    // qualunque fosse il suo stato.
    void select(String? userId) {
      ref.read(sideBySideModeProvider.notifier).disable();
      ref.read(selectedGroupMemberProvider.notifier).select(userId);
    }

    if (currentUserId == null) {
      // Profilo non ancora caricato: nessuna voce sarebbe riconoscibile
      // come "sé stesso" (VG-11 lo richiede sempre riconoscibile).
      return const SizedBox.shrink();
    }

    // 4.2 interfaccia.md: l'icona `columns` separata appartiene alla riga
    // di avatar ("dopo l'ultimo avatar"). Dove la riga lascia il posto al
    // menu a discesa, la modalità affiancata è una sua voce, "in coda
    // separata da un divisore": tenerla fuori sottraeva larghezza
    // all'intestazione, che su schermo stretto non ne ha da cedere —
    // il segmented control ne risultava compresso (vedi decisioni.md).
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: _MemberDropdown(
          group: group,
          currentUserId: currentUserId,
          selected: selected,
          sideBySide: sideBySide,
          onSelect: select,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _MemberAvatarRow(
              group: group,
              currentUserId: currentUserId,
              selected: selected,
              sideBySide: sideBySide,
              onSelect: select,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _SideBySideToggle(active: sideBySide),
        ],
      ),
    );
  }
}

/// 4.2 interfaccia.md: icona `columns`, dopo l'ultimo avatar. VG-12: la
/// modalità è accessibile a tutti i membri del Gruppo, non ai soli
/// Cuochi.
class _SideBySideToggle extends ConsumerWidget {
  const _SideBySideToggle({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? colors.accentSubtle : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.view_column_outlined, size: 20, color: active ? colors.accent : colors.textSecondary),
        tooltip: active ? context.l10n.memberSelectorSingle : context.l10n.memberSelectorSideBySide,
        onPressed: () => ref.read(sideBySideModeProvider.notifier).toggle(),
      ),
    );
  }
}

/// 4.2 interfaccia.md: "Il proprio avatar è sempre il primo della riga."
/// Vale per entrambe le forme del selettore: il menu a discesa non è una
/// composizione diversa ma la stessa riga dove non c'è larghezza per
/// distenderla, e vi elencava i membri nell'ordine del Gruppo — per
/// anzianità di appartenenza — lasciando il proprio account in mezzo
/// agli altri (segnalato dall'utente).
List<CookingGroupMember> _selfFirst(CookingGroup group, String currentUserId) => [
      ...group.members.where((member) => member.userId == currentUserId),
      ...group.members.where((member) => member.userId != currentUserId),
    ];

class _MemberAvatarRow extends StatelessWidget {
  const _MemberAvatarRow({
    required this.group,
    required this.currentUserId,
    required this.selected,
    required this.sideBySide,
    required this.onSelect,
  });

  final CookingGroup group;
  final String currentUserId;

  /// `null`: il proprio piano.
  final String? selected;

  /// VG-12: nessun avatar è selezionato mentre la modalità affiancata è
  /// attiva — "li si sta guardando tutti" (4.2 interfaccia.md).
  final bool sideBySide;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final ordered = _selfFirst(group, currentUserId);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < ordered.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            _MemberAvatar(
              member: ordered[i],
              isSelected: !sideBySide &&
                  (ordered[i].userId == currentUserId ? selected == null : selected == ordered[i].userId),
              onTap: () => onSelect(ordered[i].userId == currentUserId ? null : ordered[i].userId),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, required this.isSelected, required this.onTap});

  final CookingGroupMember member;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: '${member.firstName} ${member.lastName}',
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: colors.accent, width: 2) : null,
          ),
          child: Opacity(
            opacity: isSelected ? 1 : 0.6,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colors.surfaceAlt,
              child: Icon(Icons.person_outline, size: 18, color: colors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Schermo stretto o gruppo numeroso (4.2 interfaccia.md): avatar del
/// membro corrente, nome e `chevron-down`, che apre l'elenco completo.
/// Valore riservato alla voce della modalità affiancata nel menu (4.2):
/// non è l'identificativo di alcun membro, e non è `null` per la stessa
/// ragione per cui non lo è il ritorno al proprio piano (vedi sotto).
const _sideBySideMenuValue = '__side-by-side__';

class _MemberDropdown extends ConsumerWidget {
  const _MemberDropdown({
    required this.group,
    required this.currentUserId,
    required this.selected,
    required this.sideBySide,
    required this.onSelect,
  });

  final CookingGroup group;
  final String currentUserId;
  final String? selected;

  /// VG-12: nessun membro è "il corrente" mentre la modalità affiancata
  /// è attiva.
  final bool sideBySide;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final current = group.members.firstWhere((member) => member.userId == (selected ?? currentUserId));
    final label = sideBySide ? context.l10n.commonAll : current.firstName;

    return PopupMenuButton<String>(
      color: colors.surface,
      // `PopupMenuButton` tratta un valore `null` restituito dal menu
      // come "chiuso senza selezione" (chiama `onCanceled`, non
      // `onSelected`), indistinguibile dal tocco fuori dal menu: il
      // valore dell'item non può quindi mai essere `null`. Il ritorno
      // al proprio piano usa perciò sempre `member.userId`, tradotto in
      // `null` solo qui, dopo che la selezione è già avvenuta.
      onSelected: (value) {
        if (value == _sideBySideMenuValue) {
          ref.read(sideBySideModeProvider.notifier).toggle();
          return;
        }
        onSelect(value == currentUserId ? null : value);
      },
      itemBuilder: (menuContext) => [
        for (final member in _selfFirst(group, currentUserId))
          PopupMenuItem(
            value: member.userId,
            child: Text('${member.firstName} ${member.lastName}'),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _sideBySideMenuValue,
          child: Row(
            children: [
              Icon(
                Icons.view_column_outlined,
                size: 20,
                color: sideBySide ? colors.accent : colors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(sideBySide ? context.l10n.memberSelectorSingle : context.l10n.memberSelectorSideBySide),
            ],
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colors.surfaceAlt,
            child: Icon(Icons.person_outline, size: 16, color: colors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              style: typography.label.copyWith(color: colors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 18, color: colors.textSecondary),
        ],
      ),
    );
  }
}

/// VG-11: riga di contesto discreta, per prevenire operazioni compiute
/// per errore sul piano di un'altra persona.
class MemberContextBanner extends ConsumerWidget {
  const MemberContextBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedGroupMemberProvider);
    if (selected == null) return const SizedBox.shrink();
    final members = ref.watch(currentCookingGroupProvider).value?.members ?? const <CookingGroupMember>[];
    CookingGroupMember? member;
    for (final candidate in members) {
      if (candidate.userId == selected) {
        member = candidate;
        break;
      }
    }
    if (member == null) return const SizedBox.shrink();

    final colors = context.colors;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xxs, AppSpacing.md, 0),
      child: Text(
        context.l10n.memberViewingPlanOf(member.firstName),
        style: typography.caption.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
