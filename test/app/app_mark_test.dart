import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/branding/app_mark.dart';
import 'package:healthylog/app/theme/app_colors.dart';

/// MP-9, 2.5: il marchio dentro l'applicazione è lo stesso segno
/// dell'icona sulla schermata iniziale del dispositivo — bianco su
/// accento — e non si inverte con il tema.
void main() {
  test('i colori del marchio sono i medesimi nel chiaro e nello scuro (MP-9)', () {
    expect(AppColors.dark.markBackground, AppColors.light.markBackground);
    expect(AppColors.dark.markForeground, AppColors.light.markForeground);
  });

  testWidgets('il marchio si disegna in entrambi i temi (2.5)', (tester) async {
    for (final theme in [ThemeData.light(), ThemeData.dark()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme.copyWith(
            extensions: [theme.brightness == Brightness.dark ? AppColors.dark : AppColors.light],
          ),
          home: const Scaffold(body: Center(child: AppMark())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppMark), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
