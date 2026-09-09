import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../l10n/l10n_context.dart';
import '../../data/invite_code.dart';
import '../../providers/cooking_group_providers.dart';
import 'generate_invite_code_sheet.dart';

/// GE-5: sezione inviti, visibile al solo Proprietario, all'interno del
/// dettaglio del gruppo (8.3 interfaccia.md).
class InviteCodeSection extends ConsumerWidget {
  const InviteCodeSection({super.key, required this.groupId, required this.groupName});

  final String groupId;
  final String groupName;

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  Future<void> _generate(BuildContext context, WidgetRef ref) async {
    final request = await showGenerateInviteCodeSheet(context);
    if (request == null || !context.mounted) return;
    await ref.read(generateInviteCodeControllerProvider.notifier).generate(groupId, request);
    if (!context.mounted) return;
    final state = ref.read(generateInviteCodeControllerProvider);
    state?.whenOrNull(
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
      ),
    );
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref, String inviteCodeId) async {
    await ref.read(revokeInviteCodeControllerProvider.notifier).revoke(groupId, inviteCodeId);
  }

  Future<void> _copy(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.inviteCodeCopied)));
  }

  Future<void> _share(BuildContext context, String code) {
    return SharePlus.instance.share(
      ShareParams(text: context.l10n.inviteShareMessage(groupName, code)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final codesState = ref.watch(groupInviteCodesProvider(groupId));
    final generating = ref.watch(generateInviteCodeControllerProvider)?.isLoading ?? false;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: codesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text(
          describeApiError(context, error.asApiException?.code ?? ''),
          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        data: (codes) {
          if (codes.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.inviteNoActiveCode, style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  label: context.l10n.inviteGenerate,
                  loading: generating,
                  onPressed: () => _generate(context, ref),
                ),
              ],
            );
          }
          final code = codes.first;
          return _ActiveInviteCode(
            code: code,
            expiresAtLabel: code.expiresAt == null ? null : _formatDate(code.expiresAt!),
            remainingUses: code.maxUses == null ? null : code.maxUses! - code.usedCount,
            onShare: () => _share(context, code.code),
            onCopy: () => _copy(context, code.code),
            onRegenerate: () => _generate(context, ref),
            onRevoke: () => _revoke(context, ref, code.id),
          );
        },
      ),
    );
  }
}

class _ActiveInviteCode extends StatelessWidget {
  const _ActiveInviteCode({
    required this.code,
    required this.expiresAtLabel,
    required this.remainingUses,
    required this.onShare,
    required this.onCopy,
    required this.onRegenerate,
    required this.onRevoke,
  });

  final InviteCode code;
  final String? expiresAtLabel;
  final int? remainingUses;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacedCode = code.code.split('').join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          spacedCode,
          style: typography.displayLarge.copyWith(color: colors.textPrimary),
        ),
        if (expiresAtLabel != null)
          Text(context.l10n.inviteExpiresOn(expiresAtLabel!), style: typography.caption.copyWith(color: colors.textSecondary)),
        if (remainingUses != null)
          Text(
            context.l10n.inviteRemainingUses(remainingUses!),
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        const SizedBox(height: AppSpacing.md),
        AppPrimaryButton(label: context.l10n.commonShare, onPressed: onShare),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: onCopy, child: Text(context.l10n.commonCopy)),
            TextButton(onPressed: onRegenerate, child: Text(context.l10n.commonRegenerate)),
            TextButton(onPressed: onRevoke, child: Text(context.l10n.commonRevoke, style: TextStyle(color: colors.error))),
          ],
        ),
      ],
    );
  }
}
