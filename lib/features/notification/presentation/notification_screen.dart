import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Notifiche', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(
        child: notifications.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(error.asApiException?.code ?? ''),
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
                  itemBuilder: (context, index) => _NotificationTile(notification: items[index]),
                ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final presentation = describeNotification(notification);
    final unread = !notification.isRead;

    return Material(
      // NT-9: fondo in accento tenue a distinguere le non lette.
      color: unread ? colors.accentSubtle : colors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                  Text(presentation.text, style: typography.bodyMedium.copyWith(color: colors.textPrimary)),
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
