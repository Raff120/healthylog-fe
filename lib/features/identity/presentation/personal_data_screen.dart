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
  // PR-8: peso obiettivo, facoltativo. Sta nel profilo e non fra le
  // misurazioni (10.3 interfaccia.md): non è un dato rilevato ma un
  // riferimento che l'Utente si dà.
  final _targetWeight = TextEditingController();

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
    _targetWeight.dispose();
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
    _targetWeight.text = profile.targetWeightKg == null
        ? ''
        : (profile.targetWeightKg! == profile.targetWeightKg!.roundToDouble()
            ? profile.targetWeightKg!.round().toString()
            : profile.targetWeightKg!.toString());
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
      // PR-9: nessun giudizio sulla congruità del valore, solo la sua
      // leggibilità come numero.
      'targetWeightKg': _targetWeightValue() == null && _targetWeight.text.trim().isNotEmpty
          ? 'INVALID_FORMAT'
          : null,
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

  double? _targetWeightValue() {
    final text = _targetWeight.text.trim().replaceAll(',', '.');
    return text.isEmpty ? null : double.tryParse(text);
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
              // PR-10: il campo lasciato vuoto rimuove il peso obiettivo.
              targetWeightKg: _targetWeightValue(),
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
          SnackBar(content: Text(describeApiError(context, code ?? ''))),
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
        SnackBar(content: Text(context.l10n.personalDataSaved)),
      );
      context.pop();
    }
  }

  String? _errorFor(String field) => _submitted ? _describeFieldError(_fieldErrors[field]) : null;

  String? _describeFieldError(String? code) {
    return switch (code) {
      null => null,
      'REQUIRED' => context.l10n.validationRequired,
      'TOO_LONG' => context.l10n.validationTooLong,
      'INVALID_FORMAT' => context.l10n.validationInvalidFormat,
      'EMAIL_ALREADY_USED' => context.l10n.validationEmailAlreadyRegistered,
      'USERNAME_ALREADY_USED' => context.l10n.validationUsernameAlreadyTaken,
      _ => context.l10n.validationInvalidValue,
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
        title: Text(context.l10n.personalDataTitle, style: typography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: SafeArea(
        child: profileState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              describeApiError(context, error.asApiException?.code ?? ''),
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
                        profile.role == AccountRole.nutritionist ? context.l10n.roleNutritionist : context.l10n.roleUser,
                        style: typography.caption.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        context.l10n.personalDataRoleNotChangeable,
                        style: typography.caption.copyWith(color: colors.textTertiary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(label: context.l10n.fieldFirstName, controller: _firstName, errorText: _errorFor('firstName')),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(label: context.l10n.fieldLastName, controller: _lastName, errorText: _errorFor('lastName')),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: context.l10n.fieldUsername,
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
                            context.l10n.usernameHint,
                            style: typography.caption.copyWith(color: colors.textSecondary),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: context.l10n.fieldEmail,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _errorFor('email'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      BirthDateField(value: _birthDate, errorText: _errorFor('birthDate'), onTap: _pickBirthDate),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: context.l10n.fieldBirthPlace,
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
                        label: context.l10n.personalDataTargetWeightKg,
                        controller: _targetWeight,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        errorText: _errorFor('targetWeightKg'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: context.l10n.fieldHeightCm,
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
