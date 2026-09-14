import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/update/store_link.dart';
import '../core/widgets/app_primary_button.dart';
import '../l10n/l10n_context.dart';
import 'branding/app_mark.dart';
import 'theme/app_spacing.dart';
import 'theme/theme_context.dart';

/// Aggiornamento obbligatorio (5.5 interfaccia.md, MP-15, VR-17).
///
/// Non è un errore e non ne ha l'aspetto: nessun colore di errore, nessuna
/// icona di avviso. Non offre uscite — né azioni secondarie né ritorno: vi
/// conduce e vi trattiene il `redirect` del router finché la versione
/// installata resta superata, e l'unica via è installare quella nuova.
class UpdateRequiredScreen extends ConsumerWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;
    final link = ref.watch(storeLinkProvider).value;

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
                      l10n.updateRequiredTitle,
                      textAlign: TextAlign.center,
                      style: typography.titleLarge.copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.updateRequiredBody,
                      textAlign: TextAlign.center,
                      style: typography.bodyLarge.copyWith(color: colors.textSecondary),
                    ),
                    // VR-18: senza una pagina nota l'azione è omessa, e il testo
                    // basta a dire che cosa fare.
                    if (link != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppPrimaryButton(
                        label: l10n.updateRequiredAction,
                        onPressed: () => launchUrl(link, mode: LaunchMode.externalApplication),
                      ),
                    ],
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
