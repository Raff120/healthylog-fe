import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_colors.dart';
import 'package:healthylog/app/theme/app_consumption_colors.dart';
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

    test('lo stato "da consumare" non ha colore proprio (FE-19)', () {
      expect(AppTheme.light.extension<AppConsumptionColors>()!.toConsume, isNull);
      expect(AppTheme.dark.extension<AppConsumptionColors>()!.toConsume, isNull);
    });

    test('errore e stato "saltato" condividono la tonalità ma restano voci separate (FE-19)', () {
      final colors = AppTheme.light.extension<AppColors>()!;
      final consumption = AppTheme.light.extension<AppConsumptionColors>()!;
      // Stesso valore cromatico (2.2), ma letto da due estensioni del tema
      // distinte: una modifica a una non incide sull'altra.
      expect(colors.error.toARGB32(), consumption.skipped.toARGB32());
    });
  });
}
