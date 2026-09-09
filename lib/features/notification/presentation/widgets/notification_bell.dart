import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/l10n_context.dart';
import '../../providers/notification_providers.dart';

/// Icona delle notifiche dell'intestazione (12.3, 3.2 interfaccia.md),
/// presente in ogni destinazione principale (3.1).
///
/// NT-8: reca l'indicatore numerico delle non lette. È l'unico elemento
/// permanente dell'interfaccia che possa richiamare l'attenzione (2.1) e
/// per questo compare **solo** in presenza di non lette: un contatore a
/// zero sarebbe un richiamo privo di oggetto.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final unread = ref.watch(unreadNotificationCountProvider).value ?? 0;

    return IconButton(
      tooltip: context.l10n.notificationsTitle,
      onPressed: () => context.push('/notifications'),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_none, size: 24, color: colors.textSecondary),
          if (unread > 0)
            Positioned(
              right: -AppSpacing.xxs,
              top: -AppSpacing.xxs,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                constraints: const BoxConstraints(minWidth: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  // Oltre il centinaio il numero esatto non aggiunge nulla
                  // e allargherebbe l'indicatore oltre l'icona.
                  unread > 99 ? '99+' : '$unread',
                  textAlign: TextAlign.center,
                  style: typography.caption.copyWith(color: colors.surface),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
