import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylog/core/storage/secure_key_value_store.dart';
import 'package:healthylog/main.dart';

/// Evita di toccare l'archivio sicuro reale (canale di piattaforma
/// assente nell'ambiente di test): la sessione risulta sempre assente
/// al ripristino, come un primo avvio senza token conservato.
class _InMemorySecureKeyValueStore extends SecureKeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

void main() {
  testWidgets('L\'applicazione si apre sulla schermata di accesso', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureKeyValueStoreProvider.overrideWithValue(_InMemorySecureKeyValueStore()),
        ],
        child: const HealthyLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accedi'), findsOneWidget);
  });
}
