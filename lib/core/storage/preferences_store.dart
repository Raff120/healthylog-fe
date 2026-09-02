import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_store.g.dart';

/// Archivio locale non cifrato per preferenze prive di sensibilità (12.2
/// interfaccia.md: tema, fuso orario mostrato). Distinto da
/// [SecureKeyValueStore] (PL-16), riservato ai dati che richiedono
/// cifratura: nessuna delle preferenze qui conservate lo richiede.
class PreferencesStore {
  const PreferencesStore();

  Future<String?> read(String key) async => (await SharedPreferences.getInstance()).getString(key);

  Future<void> write(String key, String value) async => (await SharedPreferences.getInstance()).setString(key, value);
}

@riverpod
PreferencesStore preferencesStore(Ref ref) => const PreferencesStore();
