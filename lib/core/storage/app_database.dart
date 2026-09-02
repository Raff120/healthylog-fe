import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connection/connection_stub.dart'
    if (dart.library.io) 'connection/connection_native.dart'
    if (dart.library.js_interop) 'connection/connection_web.dart' as impl;
import 'local_database_key_store.dart';

part 'app_database.g.dart';

/// Base dati locale (6.1 tecnica): il solo livello di connessione e
/// cifratura (PL-1, PL-13, PL-15) è definito qui. Lo schema delle tabelle e
/// il livello di astrazione dei repository (PL-5, PL-6) sono compito del
/// task successivo di F14: nessuna feature DEVE dipendere direttamente
/// dalle interfacce di Drift (PL-5), questa classe e i repository che la
/// useranno sono l'unico punto di accesso.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.connection);

  factory AppDatabase.defaults(LocalDatabaseKeyStore keyStore) {
    return AppDatabase(DatabaseConnection.delayed(impl.openConnection(keyStore: keyStore)));
  }

  @override
  int get schemaVersion => 1;
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase.defaults(ref.watch(localDatabaseKeyStoreProvider));
  ref.onDispose(database.close);
  return database;
}
