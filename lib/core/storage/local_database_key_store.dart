import 'dart:convert';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'secure_key_value_store.dart';

part 'local_database_key_store.g.dart';

const _storageKey = 'local_database_encryption_key';

/// Chiave di cifratura della base dati locale (PL-15): generata al primo
/// avvio e conservata nell'archivio sicuro del sistema operativo, mai
/// derivata dalla password dell'Utente né conservata nella base dati
/// stessa.
class LocalDatabaseKeyStore {
  const LocalDatabaseKeyStore(this._store);

  final SecureKeyValueStore _store;

  Future<String> readOrCreate() async {
    final existing = await _store.read(_storageKey);
    if (existing != null) return existing;

    final generated = _generate();
    await _store.write(_storageKey, generated);
    return generated;
  }

  Future<void> clear() => _store.delete(_storageKey);

  static String _generate() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }
}

@riverpod
LocalDatabaseKeyStore localDatabaseKeyStore(Ref ref) =>
    LocalDatabaseKeyStore(ref.watch(secureKeyValueStoreProvider));
