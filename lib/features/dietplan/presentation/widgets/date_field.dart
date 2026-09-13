import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_context.dart';

/// Campo data generico, sul modello di `BirthDateField`
/// (identity/presentation/widgets): condiviso dalla creazione del piano
/// (7.2 interfaccia.md) e dalla modifica del suo periodo di validità.
/// [onTap] assente rende il campo di sola lettura, come l'inizio di un
/// piano già in vigore.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.errorText,
    required this.onTap,
    required this.formatter,
  });

  final String label;
  final DateTime? value;
  final String? errorText;
  final VoidCallback? onTap;
  final String Function(DateTime) formatter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final hasError = errorText != null;

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
              value == null ? label : formatter(value!),
              style: typography.bodyLarge.copyWith(
                color: value == null || onTap == null ? colors.textSecondary : colors.textPrimary,
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
