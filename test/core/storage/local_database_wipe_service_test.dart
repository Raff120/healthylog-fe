import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/core/storage/app_database.dart';
import 'package:healthylog/core/storage/local_database_key_store.dart';
import 'package:healthylog/core/storage/local_database_wipe_service.dart';
import 'package:healthylog/core/storage/secure_key_value_store.dart';

class _InMemorySecureKeyValueStore extends SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Rimozione integrale della base dati locale e della chiave alla
/// disconnessione (PL-17, F14).
void main() {
  test('wipe chiude, cancella la chiave e riapre una base dati vuota alla lettura successiva', () async {
    final secureStore = _InMemorySecureKeyValueStore();
    var deleteCalls = 0;

    final container = ProviderContainer(
      overrides: [
        secureKeyValueStoreProvider.overrideWithValue(secureStore),
        appDatabaseProvider.overrideWith((ref) => AppDatabase(NativeDatabase.memory())),
        deleteDatabaseFileProvider.overrideWithValue(() async => deleteCalls++),
      ],
    );
    addTearDown(container.dispose);

    final key = await container.read(localDatabaseKeyStoreProvider).readOrCreate();
    expect(secureStore.values, isNotEmpty);

    final db = container.read(appDatabaseProvider);
    await db.into(db.localPlanDays).insert(
          LocalPlanDaysCompanion.insert(date: DateTime(2026, 1, 1), coverage: 'ACTIVE', slotsJson: '[]'),
        );

    await container.read(localDatabaseWipeServiceProvider).wipe();

    expect(deleteCalls, 1, reason: 'PL-17: il file/deposito va rimosso, non solo svuotato');

    final keyAfter = await container.read(localDatabaseKeyStoreProvider).readOrCreate();
    expect(keyAfter, isNot(key), reason: 'PL-15: una chiave nuova va generata dopo la rimozione');

    final freshDb = container.read(appDatabaseProvider);
    expect(identical(freshDb, db), isFalse, reason: 'appDatabaseProvider va invalidato');
    expect(await freshDb.select(freshDb.localPlanDays).get(), isEmpty);
  });
}
