import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';
import 'local_database_key_store.dart';
import 'wipe/database_wipe_stub.dart'
    if (dart.library.io) 'wipe/database_wipe_native.dart'
    if (dart.library.js_interop) 'wipe/database_wipe_web.dart' as impl;

part 'local_database_wipe_service.g.dart';

typedef DeleteDatabaseFile = Future<void> Function();

/// Provider dedicato per lo stesso motivo di [appDatabaseProvider]: un
/// confine di I/O reale (file su nativo, IndexedDB/OPFS sul web) che i
/// banchi di prova devono poter sostituire, non solo la base dati che
/// vi si appoggia.
@riverpod
DeleteDatabaseFile deleteDatabaseFile(Ref ref) => impl.deleteDatabaseFile;

/// Rimozione integrale della base dati locale e della chiave di
/// cifratura (PL-17): alla disconnessione esplicita (OF-22) e, con lo
/// stesso effetto, quando la sessione risulta revocata altrove (PL-19,
/// AC-14) — diversa causa, medesima conseguenza sui dati locali.
///
/// Nella v1 non c'è alcuna operazione pendente da segnalare prima della
/// rimozione (PL-18, OF-22: non esiste una coda di scrittura offline):
/// la rimozione procede sempre, senza avvertimento.
class LocalDatabaseWipeService {
  const LocalDatabaseWipeService(this._ref, this._keyStore, this._deleteDatabaseFile);

  final Ref _ref;
  final LocalDatabaseKeyStore _keyStore;
  final DeleteDatabaseFile _deleteDatabaseFile;

  Future<void> wipe() async {
    await _ref.read(appDatabaseProvider).close();
    await _deleteDatabaseFile();
    await _keyStore.clear();
    // Una lettura successiva ne aprirà una nuova, vuota, con una nuova
    // chiave generata al bisogno (PL-15) — non diversamente da un primo
    // avvio.
    _ref.invalidate(appDatabaseProvider);
  }
}

@Riverpod(keepAlive: true)
LocalDatabaseWipeService localDatabaseWipeService(Ref ref) => LocalDatabaseWipeService(
  ref,
  ref.watch(localDatabaseKeyStoreProvider),
  ref.watch(deleteDatabaseFileProvider),
);
