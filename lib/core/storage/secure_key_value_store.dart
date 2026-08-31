import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_key_value_store.g.dart';

/// Archivio sicuro del sistema operativo (TK-8, PL-15): portachiavi su
/// Apple, archivio credenziali su Android e Windows, la soluzione più
/// protetta disponibile sul web (PL-16). Astrazione minima affinché
/// nessuna feature dipenda direttamente da `flutter_secure_storage`
/// (PL-5): oggi il solo token di rinnovo (`core/auth`), in seguito
/// anche la chiave di cifratura della base dati locale (PL-15, F14).
class SecureKeyValueStore {
  const SecureKeyValueStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);
}

@riverpod
SecureKeyValueStore secureKeyValueStore(Ref ref) => const SecureKeyValueStore();
