import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/branding/app_mark.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/device/device_label.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/l10n_context.dart';
import '../data/auth_models.dart';
import '../providers/login_controller.dart';

/// Accesso (5.2 interfaccia.md, AC-8). Nessun testo di benvenuto: chi
/// arriva qui sa dove si trova.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    await ref.read(loginControllerProvider.notifier).submit(
          LoginRequest(
            email: _email.text.trim(),
            password: _password.text,
            deviceLabel: currentDeviceLabel(),
          ),
        );

    final state = ref.read(loginControllerProvider);
    if (!mounted || state == null) return;
    final l10n = context.l10n;
    state.whenOrNull(
      data: (_) => context.go('/home'),
      error: (error, _) {
        final code = error.asApiException?.code;
        if (code == 'ACCOUNT_NOT_VERIFIED') {
          context.push('/verify-email', extra: _email.text.trim());
          return;
        }
        // AU-23: credenziali errate e blocco temporaneo (AU-21)
        // condividono deliberatamente lo stesso codice indistinto sul
        // backend — qualunque altro codice (rete, errore del server)
        // NON DEVE essere presentato come se fosse una password
        // sbagliata.
        setState(() {
          _errorMessage = code == 'INVALID_CREDENTIALS'
              ? l10n.errorInvalidCredentials
              : describeApiError(context, code ?? '');
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final loading = ref.watch(loginControllerProvider)?.isLoading ?? false;

    return Scaffold(
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
                  // 5.2: il marchio in alto, unico punto dell'applicazione
                  // in cui compare oltre al caricamento iniziale (2.5).
                  const Center(child: AppMarkWithName()),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: context.l10n.fieldEmail,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: context.l10n.fieldPassword,
                    controller: _password,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/password-reset'),
                      child: Text(context.l10n.loginForgotPassword),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    Text(_errorMessage!, style: typography.caption.copyWith(color: colors.error)),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  AppPrimaryButton(label: context.l10n.loginSubmit, loading: loading, onPressed: _submit),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(context.l10n.loginToRegister),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
