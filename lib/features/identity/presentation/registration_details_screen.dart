import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/api/api_error_messages.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/account_role.dart';
import '../data/auth_models.dart';
import '../domain/registration_field_validators.dart';
import '../providers/registration_controller.dart';
import '../providers/username_availability_controller.dart';
import 'widgets/date_and_sex_fields.dart';

/// Dati anagrafici e password (5.1 interfaccia.md, PR-1): schermata unica
/// scorribile, campi impilati dal più familiare al più burocratico.
class RegistrationDetailsScreen extends ConsumerStatefulWidget {
  const RegistrationDetailsScreen({super.key, required this.role});

  final AccountRole role;

  @override
  ConsumerState<RegistrationDetailsScreen> createState() => _RegistrationDetailsScreenState();
}

class _RegistrationDetailsScreenState extends ConsumerState<RegistrationDetailsScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _birthPlace = TextEditingController();

  DateTime? _birthDate;
  BiologicalSex? _sex;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitted = false;
  Timer? _usernameDebounce;
  String? _lastCheckedUsername;

  final Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _birthPlace.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    ref.read(usernameAvailabilityControllerProvider.notifier).reset();
    if (value.trim().isEmpty) return;
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
      _lastCheckedUsername = value;
      ref.read(usernameAvailabilityControllerProvider.notifier).check(value);
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    // FE-11: l'adattamento dipende dalla larghezza della finestra, mai
    // dalla piattaforma — un selettore a calendario, non a rotelle,
    // uguale su telefono, tablet e desktop.
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  bool _validate() {
    final errors = <String, String?>{
      'firstName': validateName(_firstName.text),
      'lastName': validateName(_lastName.text),
      'username': validateUsername(_username.text),
      'email': validateEmail(_email.text),
      'password': validatePassword(_password.text),
      'confirmPassword': _confirmPassword.text != _password.text ? 'MISMATCH' : null,
      'birthPlace': validateName(_birthPlace.text),
      'birthDate': _birthDate == null ? 'REQUIRED' : null,
      'sex': _sex == null ? 'REQUIRED' : null,
    };
    final availability = ref.read(usernameAvailabilityControllerProvider);
    if (errors['username'] == null && availability?.value == false) {
      errors['username'] = 'USERNAME_ALREADY_USED';
    }
    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
    });
    return errors.values.every((error) => error == null);
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_validate()) return;

    await ref.read(registrationControllerProvider.notifier).submit(
          RegisterRequest(
            email: _email.text.trim(),
            username: _username.text.trim(),
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            birthDate: _birthDate!,
            birthPlace: _birthPlace.text.trim(),
            sex: _sex!,
            password: _password.text,
            role: widget.role,
          ),
        );

    final state = ref.read(registrationControllerProvider);
    if (!mounted || state == null) return;
    state.whenOrNull(
      data: (result) => context.push('/verify-email', extra: result.email),
      error: (error, _) {
        final code = error.asApiException?.code;
        if (code == 'EMAIL_ALREADY_USED') {
          setState(() => _fieldErrors['email'] = code);
        } else if (code == 'USERNAME_ALREADY_USED') {
          setState(() => _fieldErrors['username'] = code);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(describeApiError(code ?? ''))),
          );
        }
      },
    );
  }

  String? _errorFor(String field) => _submitted ? _describeFieldError(_fieldErrors[field]) : null;

  String? _describeFieldError(String? code) {
    return switch (code) {
      null => null,
      'REQUIRED' => 'Campo obbligatorio',
      'TOO_LONG' => 'Troppo lungo',
      'TOO_SHORT' => 'Almeno 12 caratteri',
      'INVALID_FORMAT' => 'Formato non valido',
      'MISMATCH' => 'Le password non coincidono',
      'EMAIL_ALREADY_USED' => 'Questo indirizzo è già registrato',
      'USERNAME_ALREADY_USED' => 'Questo nome utente è già in uso',
      _ => 'Valore non valido',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final loading = ref.watch(registrationControllerProvider)?.isLoading ?? false;
    final availability = ref.watch(usernameAvailabilityControllerProvider);

    ref.listen(usernameAvailabilityControllerProvider, (previous, next) {
      if (_submitted && _username.text.trim() == (_lastCheckedUsername?.trim() ?? '')) {
        _validate();
      }
    });

    Widget? usernameSuffix;
    if (_username.text.trim().isNotEmpty) {
      if (availability?.isLoading ?? false) {
        usernameSuffix = const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      } else if (availability?.value == true) {
        usernameSuffix = Icon(Icons.check, color: context.consumptionColors.consumed);
      } else if (availability?.value == false) {
        usernameSuffix = Icon(Icons.close, color: colors.error);
      }
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(backgroundColor: colors.background, elevation: 0, scrolledUnderElevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(label: 'Nome', controller: _firstName, errorText: _errorFor('firstName')),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(label: 'Cognome', controller: _lastName, errorText: _errorFor('lastName')),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Nome utente',
                    controller: _username,
                    errorText: _errorFor('username'),
                    onChanged: _onUsernameChanged,
                    suffixIcon: usernameSuffix,
                  ),
                  // La ragione dell'univocità (PR-2) riguarda solo l'Utente,
                  // che viene cercato dal proprio Nutrizionista (CP-1): un
                  // Nutrizionista non ha un proprio Nutrizionista che lo cerchi.
                  if (widget.role == AccountRole.user) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs, left: AppSpacing.xxs),
                      child: Text(
                        'Servirà al tuo nutrizionista per trovarti',
                        style: typography.caption.copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Indirizzo e-mail',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _errorFor('email'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Password',
                    controller: _password,
                    obscureText: _obscurePassword,
                    errorText: _errorFor('password'),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs, left: AppSpacing.xxs),
                    child: Text(
                      'Almeno 12 caratteri',
                      style: typography.caption.copyWith(
                        color: _password.text.length >= passwordMinLength
                            ? context.consumptionColors.consumed
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Conferma password',
                    controller: _confirmPassword,
                    obscureText: _obscureConfirmPassword,
                    errorText: _errorFor('confirmPassword'),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  BirthDateField(
                    value: _birthDate,
                    errorText: _errorFor('birthDate'),
                    onTap: _pickBirthDate,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(label: 'Luogo di nascita', controller: _birthPlace, errorText: _errorFor('birthPlace')),
                  const SizedBox(height: AppSpacing.sm),
                  SexSelector(
                    value: _sex,
                    onChanged: (value) => setState(() => _sex = value),
                    errorText: _errorFor('sex'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(label: 'Crea account', loading: loading, onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
