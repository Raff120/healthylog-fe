import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/theme/app_theme.dart';
import 'package:healthylog/core/api/connectivity_status.dart';
import 'package:healthylog/core/widgets/offline_bar.dart';

/// Barra di assenza di connessione (4.6, 2.6 interfaccia.md; OF-6, F14).
void main() {
  testWidgets('compare offline, scompare al ripristino, senza colori né icone di errore', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: OfflineBar())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sei offline. Puoi consultare il piano già scaricato.'), findsNothing);
    expect(find.byIcon(Icons.wifi_off), findsNothing);

    container.read(connectivityStatusProvider.notifier).markOffline();
    await tester.pumpAndSettle();
    expect(find.text('Sei offline. Puoi consultare il piano già scaricato.'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);

    container.read(connectivityStatusProvider.notifier).markOnline();
    await tester.pumpAndSettle();
    expect(find.text('Sei offline. Puoi consultare il piano già scaricato.'), findsNothing);
  });
}
