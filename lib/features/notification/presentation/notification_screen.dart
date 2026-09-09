import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../data/app_notification.dart';
import '../domain/notification_presentation.dart';
import '../providers/notification_providers.dart';

/// Centro notifiche (12.3 interfaccia.md, NT-7). Elenco cronologico
/// decrescente a schermata piena, raggiungibile dall'intestazione di ogni
/// destinazione principale.
///
/// NT-10: l'apertura di questa schermata e lo scorrimento dell'elenco NON
/// marcano alcuna notifica come letta. La marcatura consegue al solo tocco
/// su una voce.
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  /// NT-10, NT-3: il tocco marca la notifica come letta e conduce
  /// all'elemento a cui si riferisce, ove ve ne sia uno.
  Future<void> _open(BuildContext context, WidgetRef ref, AppNotification notification) async {
    final destination = describeNotification(notification).destination;
    if (!notification.isRead) {
      await ref.read(notificationControllerProvider.notifier).markRead(notification.id);
    }
    if (!context.mounted || destination == null) return;
    context.push(destination);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final notifications = ref.watch(notificationsProvider);
    // Osservato, non solo letto: il controller deve restare in vita per
    // tutta la permanenza sulla schermata, anche quando il tocco su una
    // notifica marca e naviga insieme (NT-10, NT-3).
    final operating = ref.watch(notificationControllerProvider)?.isLoading ?? false;
    final hasUnread = (notifications.value ?? []).any((notification) => !notification.isRead);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Notifiche', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
        actions: [
          // NT-11: la marcatura di tutte in un'unica operazione. Compare
          // solo quando vi sia qualcosa da marcare.
          if (hasUnread)
            TextButton(
              // 2.6: durante l'attesa l'azione resta disabilitata.
              onPressed: operating
                  ? null
                  : () => ref.read(notificationControllerProvider.notifier).markAllRead(),
              child: const Text('Segna tutte come lette'),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(context, error.asApiException?.code ?? ''),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          data: (items) => items.isEmpty
              // 4.4, 12.3: stato vuoto senza azione — è condizione che si
              // risolve con il tempo.
              ? const EmptyStateView(icon: Icons.notifications_none, title: 'Nessuna notifica')
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: colors.dividerLight),
                  itemBuilder: (context, index) => _NotificationTile(
                    notification: items[index],
                    onTap: () => _open(context, ref, items[index]),
                    onDelete: () =>
                        ref.read(notificationControllerProvider.notifier).delete(items[index].id),
                  ),
                ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap, required this.onDelete});

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final presentation = describeNotification(notification);
    final unread = !notification.isRead;

    // NT-12: scorrimento laterale con conferma implicita, ammesso su
    // notifiche lette e non lette.
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: colors.errorBackground,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Icon(Icons.delete_outline, size: 20, color: colors.error),
      ),
      child: Material(
        // NT-9: fondo in accento tenue a distinguere le non lette.
        color: unread ? colors.accentSubtle : colors.background,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppSpacing.xs,
                  child: unread
                      ? Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xxs),
                          child: Container(
                            width: AppSpacing.xs,
                            height: AppSpacing.xs,
                            decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(presentation.icon, size: 20, color: colors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        presentation.text,
                        style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                      ),
                      // NT-2: l'identità di chi ha determinato l'evento, ove
                      // pertinente — assente per le transizioni automatiche
                      // del sistema (NT-6).
                      if (notification.actorName != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          notification.actorName!,
                          style: typography.caption.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatOccurredAt(notification.occurredAt),
                  style: typography.caption.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// NT-2: data e ora dell'evento. LO-9: formato italiano; F29 lo renderà
  /// dipendente dalla lingua selezionata.
  String _formatOccurredAt(DateTime value) {
    final date = '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
    final time = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date, $time';
  }
}
