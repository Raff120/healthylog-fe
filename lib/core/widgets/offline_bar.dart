import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/theme_context.dart';
import '../api/connectivity_status.dart';

/// Barra di assenza di connessione (4.6, 2.6 interfaccia.md; OF-6,
/// OF-22): compare sotto l'intestazione quando la connettività risulta
/// assente, scompare senza messaggio al ripristino. Non presentata come
/// errore (OF-6): nessun colore né icona di avviso, nessuna azione.
///
/// Il testo è quello proprio della v1 (9.2bis funzionale): la stesura
/// originaria dell'interfaccia ("Le modifiche verranno salvate")
/// presuppone la coda di scrittura offline, fuori dall'ambito della v1
/// — vedi decisioni.md.
class OfflineBar extends ConsumerWidget {
  const OfflineBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityStatusProvider);
    final colors = context.colors;
    final typography = context.typography;

    return AnimatedSize(
      duration: AppSpacing.motionStateTransition,
      curve: AppSpacing.motionSoftCurve,
      alignment: Alignment.topCenter,
      child: online
          ? const SizedBox(width: double.infinity)
          : DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                border: Border(bottom: BorderSide(color: colors.dividerLight)),
              ),
              child: SizedBox(
                height: AppSpacing.heightOfflineBar,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 16, color: colors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Sei offline. Puoi consultare il piano già scaricato.',
                      style: typography.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
