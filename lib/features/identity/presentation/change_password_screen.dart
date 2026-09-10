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
import '../providers/change_password_controller.dart';

/// Modifica della password (12.1 interfaccia.md, AC-19, AU-20): schermata
/// propria, raggiunta dai *Dati personali*.
///
/// Non è un campo di quel modulo: la password non si salva insieme al
/// luogo di nascita, richiede quella corrente e ha un esito proprio.
/// Tenerla lì avrebbe reso il pulsante di salvataggio ambiguo — quali
/// campi stia inviando, e cosa accada se uno solo dei due gruppi è
/// valido.
///
/// AU-20: le sessioni attive restano aperte, a differenza del recupero
/// (AC-18) — non ricorre il sospetto di compromissione. Nessun avviso
/// promette il contrario.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _obscure = true;
  bool _submitted = false;
  String? _currentError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);

    final currentError = validateRequired(_current.text);
    final passwordError = validatePassword(_password.text);
    // La password nuova identica alla corrente è un modulo compilato per
    // errore, non una modifica: il server la accetterebbe senza dire
    // nulla, e l'Utente crederebbe di averla cambiata.
    final sameAsCurrent = currentError == null && passwordError == null && _password.text == _current.text;
    final confirmError = _confirmPassword.text != _password.text ? 'MISMATCH' : null;
    setState(() {
      _currentError = currentError;
      _passwordError = sameAsCurrent ? 'SAME_AS_CURRENT' : passwordError;
      _confirmError = confirmError;
    });
    if (currentError != null || passwordError != null || confirmError != null || sameAsCurrent) return;

    await ref.read(changePasswordControllerProvider.notifier).submit(_current.text, _password.text);
    if (!mounted) return;

    ref.read(changePasswordControllerProvider)?.whenOrNull(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.changePasswordDone)),
            );
            context.pop();
          },
          error: (error, _) {
            final code = error.asApiException?.code ?? '';
            // AU-20, AU-23: la password corrente errata torna come
            // credenziali non valide; è l'unico campo cui possa
            // riferirsi, e mostrarla lì evita di far ricontrollare
            // all'Utente i due campi che erano giusti.
            if (code == 'INVALID_CREDENTIALS') {
              setState(() => _currentError = 'INVALID_CREDENTIALS');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(describeApiError(context, code))),
              );
            }
          },
        );
  }

  String? _describeCurrentError() {
    if (!_submitted) return null;
    return switch (_currentError) {
      null => null,
      'INVALID_CREDENTIALS' => context.l10n.changePasswordCurrentWrong,
      _ => context.l10n.validationRequired,
    };
  }

  String? _describePasswordError() {
    if (!_submitted) return null;
    return switch (_passwordError) {
      null => null,
      'SAME_AS_CURRENT' => context.l10n.changePasswordSameAsCurrent,
      'REQUIRED' => context.l10n.validationRequired,
      _ => context.l10n.passwordRequirementHint,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final loading = ref.watch(changePasswordControllerProvider)?.isLoading ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          context.l10n.changePasswordTitle,
          style: typography.titleMedium.copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: context.l10n.changePasswordCurrent,
                    controller: _current,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    errorText: _describeCurrentError(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: context.l10n.changePasswordNew,
                    controller: _password,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.newPassword],
                    errorText: _describePasswordError(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xxs),
                    child: Text(
                      // AU-6, AC-4: il requisito è dichiarato prima
                      // dell'invio, non solo quando è disatteso.
                      context.l10n.passwordRequirementHint,
                      style: typography.caption.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: context.l10n.fieldConfirmPassword,
                    controller: _confirmPassword,
                    obscureText: _obscure,
                    errorText: _submitted && _confirmError != null
                        ? context.l10n.validationPasswordsDoNotMatch
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    label: context.l10n.commonSave,
                    loading: loading,
                    onPressed: _submit,
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
