import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/api/api_error_messages.dart';
import '../../../../core/api/api_exception.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../data/care_models.dart';
import '../../providers/care_providers.dart';

/// CP-5, 9.3 interfaccia.md: prima della scelta, all'Utente sono
/// presentati l'identità del richiedente e le conseguenze del
/// collegamento — compreso cosa il Nutrizionista conserverà dopo
/// un'eventuale revoca (CP-18). L'accettazione costituisce il consenso di
/// 9.4 funzionale (CP-13). Due azioni: Accetta e Rifiuta (CP-4, CP-6).
///
/// Restituisce `true` se la richiesta è stata accettata.
Future<bool> showCareLinkRequestSheet(BuildContext context, CareLinkRequest request) async {
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _CareLinkRequestSheet(request: request),
  );
  return accepted ?? false;
}

class _CareLinkRequestSheet extends ConsumerWidget {
  const _CareLinkRequestSheet({required this.request});

  final CareLinkRequest request;

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    await ref.read(careLinkRequestActionControllerProvider.notifier).accept(request.id);
    if (!context.mounted) return;
    final state = ref.read(careLinkRequestActionControllerProvider);
    state?.whenOrNull(
      data: (_) => Navigator.of(context).pop(true),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
      ),
    );
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    await ref.read(careLinkRequestActionControllerProvider.notifier).reject(request.id);
    if (!context.mounted) return;
    final state = ref.read(careLinkRequestActionControllerProvider);
    state?.whenOrNull(
      data: (_) => Navigator.of(context).pop(false),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final acting = ref.watch(careLinkRequestActionControllerProvider)?.isLoading ?? false;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Richiesta di collegamento', style: typography.overline.copyWith(color: colors.textTertiary)),
            const SizedBox(height: AppSpacing.xxs),
            Text(request.nutritionistName, style: typography.titleLarge.copyWith(color: colors.textPrimary)),
            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('“${request.message}”', style: typography.bodyMedium.copyWith(color: colors.textSecondary)),
            ],
            const SizedBox(height: AppSpacing.md),
            Text('Accettando, il nutrizionista:', style: typography.label.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.xxs),
            _Consequence(text: 'redigerà il tuo piano alimentare'),
            _Consequence(text: 'accederà in lettura ai tuoi dati nei periodi coperti dai suoi piani'),
            _Consequence(text: 'potrà registrare misurazioni per tuo conto'),
            _Consequence(text: 'e tu non potrai più modificare il contenuto del piano che ti assegna'),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Potrai revocare il collegamento in qualsiasi momento. Dopo la revoca conserverà solo gli schemi '
              'dei piani che ha redatto e le misurazioni che ha registrato personalmente.',
              style: typography.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(label: 'Accetta', loading: acting, onPressed: () => _accept(context, ref)),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: TextButton(
                onPressed: acting ? null : () => _reject(context, ref),
                child: Text('Rifiuta', style: TextStyle(color: colors.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Consequence extends StatelessWidget {
  const _Consequence({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 18, color: colors.accent),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: typography.bodyMedium.copyWith(color: colors.textPrimary))),
        ],
      ),
    );
  }
}
