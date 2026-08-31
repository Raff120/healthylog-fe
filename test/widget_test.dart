import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylog/main.dart';

void main() {
  testWidgets('L\'applicazione si apre sulla schermata di accesso', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HealthyLogApp()));
    await tester.pumpAndSettle();

    expect(find.text('HealthyLog'), findsOneWidget);
    expect(find.text('Accedi'), findsOneWidget);
  });
}
