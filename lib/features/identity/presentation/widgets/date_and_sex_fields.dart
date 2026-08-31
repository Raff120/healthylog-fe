import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';
import '../../data/account_role.dart';

/// Campo data di nascita (PR-1), condiviso da registrazione (5.1
/// interfaccia.md) e profilo (12.1): stesso componente, stesso
/// comportamento nei due punti in cui il dato è raccolto.
class BirthDateField extends StatelessWidget {
  const BirthDateField({super.key, required this.value, required this.errorText, required this.onTap});

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

/// Selettore del sesso (PR-1), condiviso da registrazione e profilo.
class SexSelector extends StatelessWidget {
  const SexSelector({super.key, required this.value, required this.onChanged, required this.errorText});

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
