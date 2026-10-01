import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/navigation/bottom_bar_insets.dart';
import 'package:healthylog/app/theme/app_spacing.dart';

/// 3.2 interfaccia.md: lo stacco in coda agli elenchi, sopra l'ingombro
/// della barra, è ridotto dove non c'è un pulsante mobile da scavalcare.
Future<double> _paddingFor(WidgetTester tester, {required bool withFab}) async {
  late double padding;
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(padding: EdgeInsets.only(bottom: 100)),
      child: MaterialApp(
        home: Scaffold(
          floatingActionButton: withFab ? FloatingActionButton(onPressed: () {}) : null,
          body: Builder(builder: (context) {
            padding = listEndPadding(context);
            return const SizedBox.shrink();
          }),
        ),
      ),
    ),
  );
  return padding;
}

void main() {
  testWidgets('senza pulsante mobile lo stacco in coda è lg', (tester) async {
    final padding = await _paddingFor(tester, withFab: false);
    expect(padding, AppSpacing.lg + 100);
  });

  testWidgets('con il pulsante mobile lo stacco resta xxl, che non copre l\'ultimo elemento', (tester) async {
    final padding = await _paddingFor(tester, withFab: true);
    expect(padding, AppSpacing.xxl + 100);
  });
}
