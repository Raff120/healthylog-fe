import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/theme_context.dart';

/// Pulsante secondario a piena larghezza, gemello di `AppPrimaryButton`:
/// stessa misura e stesso comportamento in attesa — l'indicatore in luogo
/// del testo, e il pulsante disabilitato (2.6 interfaccia.md) — con il rilievo
/// proprio dell'azione che accompagna, non di quella principale.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
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
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.accent,
          disabledForegroundColor: colors.textTertiary,
          side: BorderSide(color: disabled ? colors.dividerLight : colors.dividerStrong),
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
                  color: colors.accent,
                ),
              )
            : Text(label, style: context.typography.label),
      ),
    );
  }
}
