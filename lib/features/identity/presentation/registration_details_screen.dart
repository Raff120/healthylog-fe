import 'dart:async';

import 'package:flutter/cupertino.dart';
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
  final _birthPlace = TextEditingController();

  DateTime? _birthDate;
  BiologicalSex? _sex;
  bool _obscurePassword = true;
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
    DateTime picked = _birthDate ?? DateTime(now.year - 25, now.month, now.day);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      builder: (sheetContext) {
        return SizedBox(
          height: 280,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: picked,
                  maximumDate: now,
                  minimumDate: DateTime(now.year - 120),
                  onDateTimeChanged: (value) => picked = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: AppPrimaryButton(
                  label: 'Conferma',
                  onPressed: () {
                    setState(() => _birthDate = picked);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _validate() {
    final errors = <String, String?>{
      'firstName': validateName(_firstName.text),
      'lastName': validateName(_lastName.text),
      'username': validateUsername(_username.text),
      'email': validateEmail(_email.text),
      'password': validatePassword(_password.text),
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
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs, left: AppSpacing.xxs),
                    child: Text(
                      'Servirà al tuo nutrizionista per trovarti',
                      style: typography.caption.copyWith(color: colors.textSecondary),
                    ),
                  ),
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
                  _DateField(
                    value: _birthDate,
                    errorText: _errorFor('birthDate'),
                    onTap: _pickBirthDate,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(label: 'Luogo di nascita', controller: _birthPlace, errorText: _errorFor('birthPlace')),
                  const SizedBox(height: AppSpacing.sm),
                  _SexSelector(
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

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.errorText, required this.onTap});

  final DateTime? value;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final hasError = errorText != null;
    final label = value == null
        ? 'Data di nascita'
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            height: AppSpacing.heightTextField,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: hasError ? colors.error : colors.dividerStrong),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: typography.bodyLarge.copyWith(
                color: value == null ? colors.textSecondary : colors.textPrimary,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(errorText!, style: typography.caption.copyWith(color: colors.error)),
        ],
      ],
    );
  }
}

class _SexSelector extends StatelessWidget {
  const _SexSelector({required this.value, required this.onChanged, required this.errorText});

  final BiologicalSex? value;
  final ValueChanged<BiologicalSex> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<BiologicalSex>(
          segments: const [
            ButtonSegment(value: BiologicalSex.female, label: Text('Femmina')),
            ButtonSegment(value: BiologicalSex.male, label: Text('Maschio')),
          ],
          selected: value == null ? {} : {value!},
          emptySelectionAllowed: true,
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) onChanged(selection.first);
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: colors.surface,
            selectedBackgroundColor: colors.accentSubtle,
            selectedForegroundColor: colors.accent,
            textStyle: typography.label,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(errorText!, style: typography.caption.copyWith(color: colors.error)),
        ],
      ],
    );
  }
}
