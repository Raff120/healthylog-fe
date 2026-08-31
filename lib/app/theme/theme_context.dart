import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Accesso al livello semantico del tema (FE-17): i widget leggono sempre
/// `context.colors` e `context.typography`, mai le primitive.
extension ThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  AppTypography get typography => Theme.of(this).extension<AppTypography>()!;
}
