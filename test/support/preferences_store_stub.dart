import 'package:healthylog/core/storage/preferences_store.dart';

/// [PreferencesStore] in memoria per i banchi di prova che montano
/// l'applicazione reale: `SharedPreferences` richiede il canale della
/// piattaforma, assente nella VM di test, e la lettura fallita lascerebbe
/// in sospeso il ritentativo che Riverpod pianifica.
class InMemoryPreferencesStore implements PreferencesStore {
  InMemoryPreferencesStore([Map<String, String>? initial])
      : values = {...?initial};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
