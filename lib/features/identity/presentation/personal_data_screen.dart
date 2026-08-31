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
import '../data/profile_models.dart';
import '../domain/registration_field_validators.dart';
import '../providers/profile_providers.dart';
import '../providers/username_availability_controller.dart';
import 'widgets/date_and_sex_fields.dart';

/// Modifica dei dati personali (12.1 interfaccia.md, PR-1, PR-4, PR-6).
class PersonalDataScreen extends ConsumerStatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  ConsumerState<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends ConsumerState<PersonalDataScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _birthPlace = TextEditingController();
  final _height = TextEditingController();

  DateTime? _birthDate;
  BiologicalSex? _sex;
  bool _submitted = false;
  bool _initialized = false;
  String _originalUsername = '';
  String _originalEmail = '';

  final Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _birthPlace.dispose();
    _height.dispose();
    super.dispose();
  }

  void _initializeFrom(Profile profile) {
    if (_initialized) return;
    _initialized = true;
    _firstName.text = profile.firstName;
    _lastName.text = profile.lastName;
    _username.text = profile.username;
    _email.text = profile.email;
    _birthPlace.text = profile.birthPlace;
    _height.text = profile.height?.toString() ?? '';
    _birthDate = profile.birthDate;
    _sex = profile.sex;
    _originalUsername = profile.username;
    _originalEmail = profile.email;
  }

  void _onUsernameChanged(String value) {
    ref.read(usernameAvailabilityControllerProvider.notifier).reset();
    // Il proprio nome utente attuale risulterebbe "non disponibile"
    // interrogando lo stesso endpoint della registrazione, che non
    // esclude sé stessi: la verifica ha senso solo per un valore diverso.
    if (value.trim().isEmpty || value.trim() == _originalUsername) return;
    ref.read(usernameAvailabilityControllerProvider.notifier).check(value);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  bool _validate() {
    final heightText = _height.text.trim();
    final errors = <String, String?>{
      'firstName': validateName(_firstName.text),
      'lastName': validateName(_lastName.text),
      'username': validateUsername(_username.text),
      'email': validateEmail(_email.text),
      'birthPlace': validateName(_birthPlace.text),
      'birthDate': _birthDate == null ? 'REQUIRED' : null,
      'sex': _sex == null ? 'REQUIRED' : null,
      'height': heightText.isEmpty ? null : (int.tryParse(heightText) == null ? 'INVALID_FORMAT' : null),
    };
    final availability = ref.read(usernameAvailabilityControllerProvider);
    if (errors['username'] == null &&
        _username.text.trim() != _originalUsername &&
        availability?.value == false) {
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

    final emailChanged = _email.text.trim() != _originalEmail;
    try {
      await ref.read(profileControllerProvider.notifier).save(
            UpdateProfileRequest(
              email: _email.text.trim(),
              username: _username.text.trim(),
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              birthDate: _birthDate!,
              birthPlace: _birthPlace.text.trim(),
              sex: _sex!,
              height: _height.text.trim().isEmpty ? null : int.parse(_height.text.trim()),
            ),
          );
    } catch (error) {
      if (!mounted) return;
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
      return;
    }

    if (!mounted) return;
    if (emailChanged) {
      // AC-5, AC-7, PR-4: la modifica dell'indirizzo riporta l'account
      // non confermato, con la stessa procedura della registrazione.
      context.push('/verify-email', extra: _email.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dati aggiornati.')),
      );
      context.pop();
    }
  }

  String? _errorFor(String field) => _submitted ? _describeFieldError(_fieldErrors[field]) : null;

  String? _describeFieldError(String? code) {
    return switch (code) {
      null => null,
      'REQUIRED' => 'Campo obbligatorio',
      'TOO_LONG' => 'Troppo lungo',
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
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Dati personali', style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(
        child: profileState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(error.asApiException?.code ?? ''),
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          data: (profile) {
            _initializeFrom(profile);
            final loading = ref.watch(profileControllerProvider.select((s) => s.isLoading)) && _initialized;
            final availability = ref.watch(usernameAvailabilityControllerProvider);

            ref.listen(usernameAvailabilityControllerProvider, (previous, next) {
              if (_submitted) _validate();
            });

            Widget? usernameSuffix;
            final usernameChanged = _username.text.trim() != _originalUsername && _username.text.trim().isNotEmpty;
            if (usernameChanged) {
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

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        profile.role == AccountRole.nutritionist ? 'Nutrizionista' : 'Utente',
                        style: typography.caption.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Il ruolo non è modificabile',
                        style: typography.caption.copyWith(color: colors.textTertiary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(label: 'Nome', controller: _firstName, errorText: _errorFor('firstName')),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(label: 'Cognome', controller: _lastName, errorText: _errorFor('lastName')),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: 'Nome utente',
                        controller: _username,
                        errorText: _errorFor('username'),
                        onChanged: (value) {
                          setState(() {});
                          _onUsernameChanged(value);
                        },
                        suffixIcon: usernameSuffix,
                      ),
                      if (profile.role == AccountRole.user) ...[
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
                      BirthDateField(value: _birthDate, errorText: _errorFor('birthDate'), onTap: _pickBirthDate),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: 'Luogo di nascita',
                        controller: _birthPlace,
                        errorText: _errorFor('birthPlace'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SexSelector(
                        value: _sex,
                        onChanged: (value) => setState(() => _sex = value),
                        errorText: _errorFor('sex'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: 'Altezza (cm)',
                        controller: _height,
                        keyboardType: TextInputType.number,
                        errorText: _errorFor('height'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppPrimaryButton(label: 'Salva', loading: loading, onPressed: _submit),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
