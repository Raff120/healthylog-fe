import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/theme_context.dart';

/// Pulsante primario a piena larghezza (5.1, 5.2 interfaccia.md). Durante
/// l'attesa mostra l'indicatore di caricamento e resta disabilitato (2.6):
/// un solo widget per l'intera applicazione evita che ciascuna schermata
/// reinventi lo stato.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = loading || onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.heightButton,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.surface,
          disabledBackgroundColor: colors.surfaceAlt,
          disabledForegroundColor: colors.textTertiary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.surface,
                ),
              )
            : Text(label, style: context.typography.label),
      ),
    );
  }
}
