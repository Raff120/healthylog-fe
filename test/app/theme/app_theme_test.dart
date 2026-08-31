import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_colors.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/app/theme/app_typography.dart';

void main() {
  group('AppTheme', () {
    test('la variante chiara espone le estensioni semantiche', () {
      final theme = AppTheme.light;
      expect(theme.extension<AppColors>(), AppColors.light);
      expect(theme.extension<AppTypography>(), AppTypography.standard);
    });

    test('la variante scura espone le estensioni semantiche', () {
      final theme = AppTheme.dark;
      expect(theme.extension<AppColors>(), AppColors.dark);
      expect(theme.extension<AppTypography>(), AppTypography.standard);
    });

    test('chiaro e scuro condividono le medesime primitive tipografiche (FE-18)', () {
      expect(
        AppTheme.light.extension<AppTypography>(),
        AppTheme.dark.extension<AppTypography>(),
      );
    });
  });
}
