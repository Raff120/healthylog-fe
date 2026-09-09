import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/cooking_group.dart';

enum GroupMemberAction { promote, revokeCook, remove, transferOwnership }

/// Voce dell'elenco dei membri (8.2 interfaccia.md, GE-13): avatar,
/// nome e cognome, privilegio in `caption`. Il menu delle azioni compare
/// solo per chi il Proprietario può operare — mai sulla propria voce,
/// mai per un richiedente che non sia Proprietario (GE-8, GE-6, GE-7,
/// GE-9).
class GroupMemberTile extends StatelessWidget {
  const GroupMemberTile({
    super.key,
    required this.member,
    required this.isSelf,
    required this.onAction,
  });

  final CookingGroupMember member;
  final bool isSelf;

  /// `null` quando nessuna azione è disponibile su questa voce (GE-15).
  final ValueChanged<GroupMemberAction>? onAction;

  String _privilegeLabel(BuildContext context) {
    if (member.owner) return context.l10n.groupRoleOwner;
    if (member.cook) return context.l10n.groupRoleCook;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final privilege = _privilegeLabel(context);

    return SizedBox(
      height: AppSpacing.heightListItemTwoLines,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.surfaceAlt,
            child: Icon(Icons.person_outline, color: colors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${member.firstName} ${member.lastName}',
                        style: typography.titleMedium.copyWith(color: colors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: AppSpacing.xxs),
                      Text('(tu)', style: typography.caption.copyWith(color: colors.textSecondary)),
                    ],
                  ],
                ),
                if (privilege.isNotEmpty)
                  Text(privilege, style: typography.caption.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          if (onAction != null)
            PopupMenuButton<GroupMemberAction>(
              icon: Icon(Icons.more_vert, color: colors.textSecondary),
              color: colors.surface,
              onSelected: onAction,
              itemBuilder: (menuContext) => [
                PopupMenuItem(
                  value: member.cook ? GroupMemberAction.revokeCook : GroupMemberAction.promote,
                  child: Text(member.cook ? context.l10n.groupRevokeCook : context.l10n.groupPromoteCook),
                ),
                PopupMenuItem(value: GroupMemberAction.transferOwnership, child: Text(context.l10n.groupTransferOwnership)),
                PopupMenuItem(
                  value: GroupMemberAction.remove,
                  child: Text(context.l10n.groupRemoveMember, style: TextStyle(color: colors.error)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
