import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../providers/email_verification_controller.dart';

const _resendCooldown = Duration(seconds: 60);

/// Attesa della verifica dell'indirizzo (5.3 interfaccia.md, AU-11, AU-12).
class EmailVerificationWaitingScreen extends ConsumerStatefulWidget {
  const EmailVerificationWaitingScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<EmailVerificationWaitingScreen> createState() => _EmailVerificationWaitingScreenState();
}

class _EmailVerificationWaitingScreenState extends ConsumerState<EmailVerificationWaitingScreen> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void dispose() {
    _ticker?.cancel();
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

  Future<void> _resend() async {
    await ref.read(emailVerificationControllerProvider.notifier).resend(widget.email);
    if (!mounted) return;
    final state = ref.read(emailVerificationControllerProvider);
    state?.whenOrNull(
      data: (_) => _startCooldown(),
      error: (error, _) {
        final code = error.asApiException?.code ?? '';
        if (code == 'VERIFICATION_RESEND_RATE_LIMITED') {
          _startCooldown();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeApiError(code))));
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
                    'Controlla la tua posta',
                    textAlign: TextAlign.center,
                    style: typography.titleLarge.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Abbiamo inviato un collegamento di conferma a ${widget.email}',
                    textAlign: TextAlign.center,
                    style: typography.bodyLarge.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    label: canResend ? 'Invia di nuovo' : 'Invia di nuovo (${_remaining.inSeconds}s)',
                    loading: loading,
                    onPressed: canResend ? _resend : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Usa un altro indirizzo'),
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
