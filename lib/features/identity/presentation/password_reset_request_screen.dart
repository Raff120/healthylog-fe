import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/l10n_context.dart';
import '../domain/registration_field_validators.dart';
import '../providers/password_reset_controller.dart';

/// Richiesta di recupero password (5.4 interfaccia.md, AC-16). L'esito è
/// sempre il medesimo, quale che sia l'esistenza dell'account (AC-17,
/// AU-18): la formulazione condizionale non va resa più rassicurante.
class PasswordResetRequestScreen extends ConsumerStatefulWidget {
  const PasswordResetRequestScreen({super.key});

  @override
  ConsumerState<PasswordResetRequestScreen> createState() => _PasswordResetRequestScreenState();
}

class _PasswordResetRequestScreenState extends ConsumerState<PasswordResetRequestScreen> {
  final _email = TextEditingController();
  String? _emailError;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = validateEmail(_email.text);
    setState(() => _emailError = error == null ? null : context.l10n.validationInvalidFormat);
    if (error != null) return;

    await ref.read(passwordResetRequestControllerProvider.notifier).submit(_email.text.trim());
    if (!mounted) return;
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final loading = ref.watch(passwordResetRequestControllerProvider)?.isLoading ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(backgroundColor: colors.background, elevation: 0, scrolledUnderElevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.passwordResetRequestTitle, style: typography.titleLarge.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.passwordResetRequestSubtitle,
                    style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_sent) ...[
                    Text(
                      context.l10n.passwordResetRequestSent,
                      style: typography.bodyMedium.copyWith(color: colors.textPrimary),
                    ),
                  ] else ...[
                    AppTextField(
                      label: context.l10n.fieldEmail,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppPrimaryButton(label: context.l10n.passwordResetRequestSubmit, loading: loading, onPressed: _submit),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
