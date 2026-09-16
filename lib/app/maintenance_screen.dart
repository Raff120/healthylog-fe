import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/maintenance/maintenance_controller.dart';
import '../core/widgets/app_secondary_button.dart';
import '../l10n/l10n_context.dart';
import 'branding/app_mark.dart';
import 'theme/app_spacing.dart';
import 'theme/theme_context.dart';

/// Manutenzione del servizio (5.6 interfaccia.md, MN-2, MM-7).
///
/// Come la schermata di aggiornamento non è un errore e non ne ha l'aspetto,
/// e non offre uscite: vi conduce e vi trattiene il `redirect` del router
/// finché il servizio dichiara la manutenzione. Il messaggio è fisso e non
/// promette orari (MN-3).
///
/// La fine è riconosciuta da sé a intervalli regolari da
/// [MaintenanceController] (MM-9): il pulsante non fa che chiedere subito la
/// medesima verifica (MN-5).
class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  /// L'attesa riguarda questa sola schermata — l'indicatore in luogo del
  /// testo — e non lo stato della manutenzione, che è del servizio.
  bool _verifying = false;

  Future<void> _verify() async {
    setState(() => _verifying = true);
    try {
      await ref.read(maintenanceControllerProvider.notifier).check();
    } finally {
      // La verifica riuscita porta via la schermata: il widget potrebbe non
      // essere più montato quando l'attesa si conclude.
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppMarkWithName()),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.maintenanceTitle,
                      textAlign: TextAlign.center,
                      style: typography.titleLarge.copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.maintenanceBody,
                      textAlign: TextAlign.center,
                      style: typography.bodyLarge.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppSecondaryButton(
                      label: l10n.maintenanceAction,
                      loading: _verifying,
                      onPressed: _verify,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
