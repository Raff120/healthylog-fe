import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/l10n_context.dart';
import '../providers/email_verification_controller.dart';
import '../providers/profile_providers.dart';

const _resendCooldown = Duration(seconds: 60);

/// AU-11: lunghezza del codice, la medesima che il server emette.
const _codeLength = 6;

/// Verifica dell'indirizzo (5.3 interfaccia.md, AU-11, AU-12): il codice
/// ricevuto per posta si ricopia qui.
///
/// Il collegamento che questa schermata attendeva è stato sostituito dal
/// codice (vedi decisioni.md): la conferma si consuma dove la si è
/// chiesta, senza uscire dall'applicazione e senza dipendere da come il
/// dispositivo apra l'indirizzo ricevuto.
class EmailVerificationWaitingScreen extends ConsumerStatefulWidget {
  const EmailVerificationWaitingScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<EmailVerificationWaitingScreen> createState() => _EmailVerificationWaitingScreenState();
}

class _EmailVerificationWaitingScreenState extends ConsumerState<EmailVerificationWaitingScreen> {
  final _code = TextEditingController();

  Timer? _ticker;
  Duration _remaining = Duration.zero;
  bool _submitted = false;

  @override
  void dispose() {
    _ticker?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _remaining = _resendCooldown);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  String? get _codeError {
    if (!_submitted) return null;
    if (_code.text.trim().length != _codeLength) return context.l10n.verifyEmailCodeIncomplete;
    return null;
  }

  Future<void> _confirm() async {
    setState(() => _submitted = true);
    if (_code.text.trim().length != _codeLength) return;

    await ref.read(emailVerificationControllerProvider.notifier).confirm(widget.email, _code.text.trim());
    if (!mounted) return;

    ref.read(emailVerificationControllerProvider)?.whenOrNull(
          data: (_) {
            // PR-4: la conferma di un indirizzo modificato riguarda una
            // sessione già attiva — il profilo in memoria reca ancora
            // l'account non confermato.
            ref.invalidate(profileControllerProvider);
            // Senza sessione l'instradamento rimanda da sé all'accesso:
            // la destinazione è la stessa nei due casi, e non occorre
            // distinguerli qui.
            context.go('/home');
          },
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(context, error.asApiException?.code ?? ''))),
          ),
        );
  }

  Future<void> _resend() async {
    await ref.read(emailVerificationControllerProvider.notifier).resend(widget.email);
    if (!mounted) return;
    ref.read(emailVerificationControllerProvider)?.whenOrNull(
          data: (_) {
            _code.clear();
            setState(() => _submitted = false);
            _startCooldown();
          },
          error: (error, _) {
            final code = error.asApiException?.code ?? '';
            if (code == 'VERIFICATION_RESEND_RATE_LIMITED') {
              _startCooldown();
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeApiError(context, code))));
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final loading = ref.watch(emailVerificationControllerProvider)?.isLoading ?? false;
    final canResend = _remaining == Duration.zero && !loading;

    return Scaffold(
      backgroundColor: colors.background,
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
                  Icon(Icons.mark_email_read_outlined, size: 48, color: colors.textTertiary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.verifyEmailTitle,
                    textAlign: TextAlign.center,
                    style: typography.titleLarge.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    // L'indirizzo per esteso: è frequente accorgersi qui
                    // di un errore di digitazione (5.3).
                    context.l10n.verifyEmailSentTo(widget.email),
                    textAlign: TextAlign.center,
                    style: typography.bodyLarge.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: context.l10n.verifyEmailCode,
                    controller: _code,
                    keyboardType: TextInputType.number,
                    // Il codice si ricopia da un messaggio: il sistema
                    // operativo sa proporlo se il campo lo dichiara.
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(_codeLength),
                    ],
                    errorText: _codeError,
                    onChanged: (value) {
                      setState(() {});
                      // Sei cifre non lasciano dubbi su quando il codice
                      // sia completo: attendere un tocco in più sarebbe
                      // un passaggio senza scelta.
                      if (value.length == _codeLength && !loading) _confirm();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppPrimaryButton(
                    label: context.l10n.verifyEmailConfirm,
                    loading: loading,
                    onPressed: _code.text.trim().length == _codeLength ? _confirm : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: canResend ? _resend : null,
                    child: Text(
                      canResend
                          ? context.l10n.verifyEmailResend
                          : context.l10n.verifyEmailResendIn(_remaining.inSeconds),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(context.l10n.verifyEmailUseAnotherAddress),
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
