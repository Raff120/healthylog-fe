import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import '../local_database_key_store.dart';

const _databaseName = 'healthylog';

/// Connessione web: SQLite compilato in WebAssembly (`web/sqlite3.wasm`),
/// ospitato in un web worker (`web/drift_worker.js`) per la condivisione
/// tra schede.
///
/// Non cifrata a riposo (PL-16): drift chiama la funzione di impostazione
/// (dove verrebbe eseguita la `PRAGMA key`) solo quando il database è aperto
/// nel contesto JavaScript principale, non quando — come qui, per la
/// condivisione tra schede — è ospitato nel worker. Cifrarla richiederebbe
/// compilare un worker su misura con la chiave incorporata, incompatibile
/// con una chiave generata per dispositivo (PL-15). Ci si affida quindi
/// all'isolamento per origine del browser (IndexedDB/OPFS), la protezione
/// più solida disponibile senza quel passaggio: la minore difendibilità
/// dell'ambiente web è nota e accettata dalla specifica stessa.
Future<DatabaseConnection> openConnection({required LocalDatabaseKeyStore keyStore}) async {
  final result = await WasmDatabase.open(
    databaseName: _databaseName,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
}
