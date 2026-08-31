import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../data/device_session.dart';
import '../providers/sessions_providers.dart';

/// Dispositivi collegati (12.2 interfaccia.md, AC-14, TK-18). Il
/// dispositivo corrente è indicato come tale e non è revocabile da qui:
/// per esso si usa la disconnessione (nel profilo).
class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  Future<void> _confirmRevoke(BuildContext context, WidgetRef ref, DeviceSession session) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('Revoca'),
        content: Text('Disconnettere "${session.deviceLabel}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Revoca', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(devicesControllerProvider.notifier).revoke(session.id);
  }

  Future<void> _confirmRevokeAllOthers(BuildContext context, WidgetRef ref) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('Disconnetti tutti gli altri dispositivi'),
        content: const Text('Le altre sessioni attive verranno chiuse.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Disconnetti', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(devicesControllerProvider.notifier).revokeAllExceptCurrent();
  }

  String _formatLastUsed(DateTime value) {
    final local = value.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$date, $time';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final devicesState = ref.watch(devicesControllerProvider);
    final hasOtherDevices = (devicesState.value ?? []).any((session) => !session.current);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Dispositivi collegati', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(
        child: devicesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(error.asApiException?.code ?? ''),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          data: (sessions) => Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return _DeviceTile(
                      session: session,
                      lastUsedLabel: _formatLastUsed(session.lastUsedAt),
                      onRevoke: session.current ? null : () => _confirmRevoke(context, ref, session),
                    );
                  },
                ),
              ),
              if (hasOtherDevices)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TextButton(
                    onPressed: () => _confirmRevokeAllOthers(context, ref),
                    child: Text(
                      'Disconnetti tutti gli altri dispositivi',
                      style: TextStyle(color: colors.error),
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

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.session, required this.lastUsedLabel, required this.onRevoke});

  final DeviceSession session;
  final String lastUsedLabel;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.devices_outlined, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(session.deviceLabel, style: typography.bodyLarge.copyWith(color: colors.textPrimary)),
                    if (session.current) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '(questo dispositivo)',
                        style: typography.caption.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ],
                ),
                Text('Ultimo utilizzo: $lastUsedLabel', style: typography.caption.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          if (onRevoke != null)
            TextButton(onPressed: onRevoke, child: Text('Revoca', style: TextStyle(color: colors.error))),
        ],
      ),
    );
  }
}
