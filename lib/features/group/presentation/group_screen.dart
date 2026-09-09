import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/l10n_context.dart';
import '../../identity/providers/profile_providers.dart';
import '../data/cooking_group.dart';
import '../providers/cooking_group_providers.dart';
import 'widgets/create_group_sheet.dart';
import 'widgets/group_confirmations.dart';
import 'widgets/group_member_tile.dart';
import 'widgets/invite_code_section.dart';
import 'widgets/join_group_sheet.dart';

/// Gruppo (8.1, 8.2 interfaccia.md; 3.4, 4.4 funzionale): raggiunta da
/// Profilo → Gruppo. Mostra lo stato vuoto con le due azioni di GE-18
/// quando l'Utente non appartiene ad alcun Gruppo, altrimenti il
/// dettaglio completo.
class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await showCreateGroupSheet(context);
    if (name == null || !context.mounted) return;
    await ref.read(createCookingGroupControllerProvider.notifier).create(name);
    if (!context.mounted) return;
    ref.read(createCookingGroupControllerProvider)?.whenOrNull(
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
          ),
        );
  }

  Future<void> _join(BuildContext context) => showJoinGroupSheet(context);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final groupState = ref.watch(currentCookingGroupProvider);
    final creating = ref.watch(createCookingGroupControllerProvider)?.isLoading ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Gruppo', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(
        child: groupState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) {
            final code = error.asApiException?.code;
            if (code == 'RESOURCE_NOT_FOUND') {
              return _NoGroupView(
                creating: creating,
                onCreate: () => _create(context, ref),
                onJoin: () => _join(context),
              );
            }
            return Center(
              child: Text(describeApiError(context, code ?? ''), style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
            );
          },
          data: (group) => _GroupDetailView(group: group),
        ),
      ),
    );
  }
}

/// GE-18: l'assenza di Gruppo non è presentata come una condizione
/// incompleta — entrambe le possibilità (creare, aderire) sono offerte
/// con pari evidenza (8.1 interfaccia.md).
class _NoGroupView extends StatelessWidget {
  const _NoGroupView({required this.creating, required this.onCreate, required this.onJoin});

  final bool creating;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EmptyStateView(
          icon: Icons.groups_outlined,
          title: context.l10n.groupNone,
          text: context.l10n.groupNoneDescription,
          actionLabel: context.l10n.groupCreate,
          onAction: onCreate,
          actionLoading: creating,
        ),
        TextButton(onPressed: onJoin, child: Text(context.l10n.groupJoinWithCode)),
      ],
    );
  }
}

class _GroupDetailView extends ConsumerWidget {
  const _GroupDetailView({required this.group});

  final CookingGroup group;

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final name = await showCreateGroupSheet(context);
    if (name == null || !context.mounted) return;
    await ref.read(renameCookingGroupControllerProvider.notifier).rename(group.id, name);
    if (!context.mounted) return;
    ref.read(renameCookingGroupControllerProvider)?.whenOrNull(
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
          ),
        );
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, bool isOwner) async {
    if (isOwner) {
      await explainOwnerMustTransferBeforeLeaving(context);
      return;
    }
    final confirmed = await confirmLeaveGroup(context);
    if (!confirmed || !context.mounted) return;
    await ref.read(leaveCookingGroupControllerProvider.notifier).leave(group.id);
    if (!context.mounted) return;
    ref.read(leaveCookingGroupControllerProvider)?.whenOrNull(
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
          ),
        );
  }

  Future<void> _dissolve(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDissolveGroup(context);
    if (!confirmed || !context.mounted) return;
    await ref.read(dissolveCookingGroupControllerProvider.notifier).dissolve(group.id);
    if (!context.mounted) return;
    ref.read(dissolveCookingGroupControllerProvider)?.whenOrNull(
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
          ),
        );
  }

  Future<void> _handleMemberAction(
    BuildContext context,
    WidgetRef ref,
    CookingGroupMember member,
    GroupMemberAction action,
  ) async {
    final memberName = '${member.firstName} ${member.lastName}';
    switch (action) {
      case GroupMemberAction.promote:
        await ref.read(updateGroupMemberControllerProvider.notifier).update(group.id, member.userId, true);
      case GroupMemberAction.revokeCook:
        await ref.read(updateGroupMemberControllerProvider.notifier).update(group.id, member.userId, false);
      case GroupMemberAction.remove:
        final confirmed = await confirmRemoveMember(context, memberName);
        if (!confirmed) return;
        await ref.read(removeGroupMemberControllerProvider.notifier).remove(group.id, member.userId);
      case GroupMemberAction.transferOwnership:
        final confirmed = await confirmTransferOwnership(context, memberName);
        if (!confirmed) return;
        await ref.read(transferGroupOwnershipControllerProvider.notifier).transfer(group.id, member.userId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final currentUserId = ref.watch(profileControllerProvider).value?.id;
    final isOwner = currentUserId != null && group.ownerId == currentUserId;
    final isSoleMember = group.members.length == 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
      children: [
        Text(group.name, style: typography.titleLarge.copyWith(color: colors.textPrimary)),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          context.l10n.groupMemberCount(group.members.length),
          style: typography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final member in group.members)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: GroupMemberTile(
              member: member,
              isSelf: member.userId == currentUserId,
              onAction: (isOwner && member.userId != currentUserId)
                  ? (action) => _handleMemberAction(context, ref, member, action)
                  : null,
            ),
          ),
        if (isSoleMember) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.groupOnlyMember,
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (isOwner) InviteCodeSection(groupId: group.id, groupName: group.name),
        const SizedBox(height: AppSpacing.lg),
        if (isOwner)
          Center(
            child: TextButton(onPressed: () => _rename(context, ref), child: Text(context.l10n.groupRename)),
          ),
        if (!isOwner || !isSoleMember)
          Center(
            child: TextButton(
              onPressed: () => _leave(context, ref, isOwner),
              child: Text(context.l10n.groupLeave, style: TextStyle(color: colors.error)),
            ),
          ),
        if (isOwner)
          Center(
            child: TextButton(
              onPressed: () => _dissolve(context, ref),
              child: Text(context.l10n.groupDissolve, style: TextStyle(color: colors.error)),
            ),
          ),
      ],
    );
  }
}
