import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../providers/email_verify_link_controller.dart';

/// Apertura del collegamento ricevuto per posta (5.3 interfaccia.md,
/// "Conferma avvenuta" / "Collegamento scaduto"): tenta la conferma non
/// appena la schermata compare, senza alcuna azione da parte dell'Utente.
class EmailVerificationLinkScreen extends ConsumerStatefulWidget {
  const EmailVerificationLinkScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<EmailVerificationLinkScreen> createState() => _EmailVerificationLinkScreenState();
}

class _EmailVerificationLinkScreenState extends ConsumerState<EmailVerificationLinkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emailVerifyLinkControllerProvider.notifier).confirm(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final state = ref.watch(emailVerifyLinkControllerProvider);

    ref.listen(emailVerifyLinkControllerProvider, (previous, next) {
      next?.whenOrNull(data: (_) => context.go('/home'));
    });

    final expired = state?.hasError ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: expired
                    ? [
                        Icon(Icons.error_outline, size: 48, color: colors.textTertiary),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Il collegamento non è più valido',
                          textAlign: TextAlign.center,
                          style: typography.titleLarge.copyWith(color: colors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Torna all\'accesso per richiederne uno nuovo.',
                          textAlign: TextAlign.center,
                          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppPrimaryButton(label: 'Torna all\'accesso', onPressed: () => context.go('/login')),
                      ]
                    : const [
                        Center(child: CircularProgressIndicator()),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
