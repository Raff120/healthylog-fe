import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_spacing.dart';
import 'theme/theme_context.dart';

/// Destinazione temporanea dopo l'accesso, in attesa di *Piano* (F12,
/// Fase 3): serve solo a rendere verificabile la protezione delle rotte
/// (F06) prima che esista una destinazione reale. Da sostituire
/// integralmente, non da ampliare. Il profilo (12.1 interfaccia.md,
/// dove risiede la disconnessione) è già raggiungibile da qui, in
/// assenza della barra di navigazione reale (compito di un task
/// successivo).
class PlaceholderHomeScreen extends ConsumerWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Accesso effettuato', style: typography.titleLarge.copyWith(color: colors.textPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Piano sarà disponibile a partire dalla Fase 3.',
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  onPressed: () => context.push('/profile'),
                  child: const Text('Profilo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
