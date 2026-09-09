import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/branding/app_mark.dart';
import 'package:healthylog/app/theme/app_theme.dart';

/// MP-9, 2.5: il marchio dentro l'applicazione è la stessa risorsa da cui
/// sono generate le icone di piattaforma — lo stesso segno che compare
/// sulla schermata iniziale del dispositivo — e non muta con il tema.
void main() {
  testWidgets('presenta la risorsa del marchio in entrambi i temi (MP-9)', (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(
        MaterialApp(theme: theme, home: const Scaffold(body: Center(child: AppMark()))),
      );
      await tester.pump();

      final image = tester.widget<Image>(find.descendant(
        of: find.byType(AppMark),
        matching: find.byType(Image),
      ));
      expect((image.image as AssetImage).assetName, AppMark.asset);
      // 2.5: nessun colore proprio applicato sopra la risorsa.
      expect(image.color, isNull);
    }
  });
}
