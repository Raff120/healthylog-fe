import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/theme_context.dart';

/// Campo di testo comune ai moduli (5.1, 5.2, 5.4 interfaccia.md): bordo in
/// colore errore e messaggio in `caption` sotto il campo quando non valido
/// (2.6), nessun valore visivo dichiarato dal chiamante (FE-15).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.focusNode,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  /// > 1 per un'area di testo estesa (GG-12: "andata a capo ed elenchi
  /// puntati"), es. il contenuto di uno slot o il testo di una ricetta.
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError ? colors.error : colors.dividerStrong;
    final isMultiline = maxLines > 1;

    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      style: typography.bodyLarge.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: typography.bodyMedium.copyWith(
          color: colors.textSecondary,
        ),
        filled: true,
        fillColor: colors.surface,
        suffixIcon: suffixIcon,
        contentPadding: isMultiline
            ? const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm)
            : const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: hasError ? colors.error : colors.accent,
            width: 2,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMultiline ? field : SizedBox(height: AppSpacing.heightTextField, child: field),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            errorText!,
            style: typography.caption.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}
