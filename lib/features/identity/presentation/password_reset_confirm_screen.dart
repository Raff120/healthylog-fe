import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/l10n_context.dart';
import '../domain/registration_field_validators.dart';
import '../providers/password_reset_controller.dart';

/// Reimpostazione della password dal collegamento ricevuto (5.4
/// interfaccia.md, AC-16, AC-18). Alla conferma tutte le sessioni sono
/// state chiuse (AU-19): si torna sempre all'accesso.
class PasswordResetConfirmScreen extends ConsumerStatefulWidget {
  const PasswordResetConfirmScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<PasswordResetConfirmScreen> createState() => _PasswordResetConfirmScreenState();
}

class _PasswordResetConfirmScreenState extends ConsumerState<PasswordResetConfirmScreen> {
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscure = true;
  bool _submitted = false;
  String? _passwordError;
  String? _confirmError;
  bool _expired = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final passwordError = validatePassword(_password.text);
    final confirmError = _confirmPassword.text != _password.text ? 'MISMATCH' : null;
    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
    });
    if (passwordError != null || confirmError != null) return;

    await ref
        .read(passwordResetConfirmControllerProvider.notifier)
        .submit(widget.token, _password.text);
    if (!mounted) return;

    final state = ref.read(passwordResetConfirmControllerProvider);
    state?.whenOrNull(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.passwordResetDone)),
        );
        context.go('/login');
      },
      error: (error, _) {
        final code = error.asApiException?.code ?? '';
        if (code == 'PASSWORD_RESET_TOKEN_INVALID') {
          setState(() => _expired = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeApiError(context, code))));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final loading = ref.watch(passwordResetConfirmControllerProvider)?.isLoading ?? false;

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
                children: _expired
                    ? [
                        Text(
                          context.l10n.passwordResetLinkExpiredTitle,
                          style: typography.titleLarge.copyWith(color: colors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.l10n.passwordResetLinkExpiredBody,
                          style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppPrimaryButton(
                          label: context.l10n.passwordResetRequestNewLink,
                          onPressed: () => context.go('/password-reset'),
                        ),
                      ]
                    : [
                        Text(context.l10n.passwordResetConfirmTitle, style: typography.titleLarge.copyWith(color: colors.textPrimary)),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: context.l10n.passwordResetNewPassword,
                          controller: _password,
                          obscureText: _obscure,
                          errorText: _submitted && _passwordError == 'TOO_SHORT' ? context.l10n.passwordRequirementHint : null,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          label: context.l10n.fieldConfirmPassword,
                          controller: _confirmPassword,
                          obscureText: _obscure,
                          errorText: _submitted && _confirmError != null ? context.l10n.validationPasswordsDoNotMatch : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppPrimaryButton(label: context.l10n.passwordResetSubmit, loading: loading, onPressed: _submit),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
