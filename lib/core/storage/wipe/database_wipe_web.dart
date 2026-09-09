import 'package:drift/wasm.dart';

const _databaseName = 'healthylog';

/// Rimozione della base dati dal deposito scelto dal browser
/// (IndexedDB/OPFS, PL-17): richiede di individuarla tra quelle
/// esistenti, non un semplice percorso di file come su nativo.
Future<void> deleteDatabaseFile() async {
  final probed = await WasmDatabase.probe(
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
    databaseName: _databaseName,
  );
  for (final existing in probed.existingDatabases) {
    if (existing.$2 == _databaseName) {
      await probed.deleteDatabase(existing);
    }
  }
}
