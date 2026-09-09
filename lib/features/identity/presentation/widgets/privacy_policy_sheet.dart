import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/app_locale.dart';
import '../../../../l10n/l10n_context.dart';
import '../../../../l10n/locale_controller.dart';
import '../../domain/privacy_policy.dart';

/// PV-6, PV-9: il testo integrale dell'informativa, in un foglio modale
/// scorribile — dalla registrazione (5.1) e in qualsiasi momento dal
/// profilo (12.2).
Future<void> showPrivacyPolicySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _PrivacyPolicySheet(),
  );
}

class _PrivacyPolicySheet extends ConsumerWidget {
  const _PrivacyPolicySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final locale = ref.watch(localeControllerProvider).value ?? AppLocale.fallback;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.privacyPolicyTitle,
                        style: typography.titleMedium.copyWith(color: colors.textPrimary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.l10n.commonClose),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<String>(
                  future: loadPrivacyPolicy(locale),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
                      // Il testo è presentato così com'è: le sole
                      // marcature del sorgente sono i titoli e gli
                      // elenchi, che si leggono anche non rese.
                      child: Text(
                        snapshot.data!,
                        style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
