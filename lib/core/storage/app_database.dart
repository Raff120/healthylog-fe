import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connection/connection_stub.dart'
    if (dart.library.io) 'connection/connection_native.dart'
    if (dart.library.js_interop) 'connection/connection_web.dart' as impl;
import 'local_database_key_store.dart';
import 'tables/local_plan_day_table.dart';

part 'app_database.g.dart';

/// Base dati locale (6.1 tecnica): connessione e cifratura (PL-1, PL-13,
/// PL-15), schema e accesso (PL-5, PL-6). Nessuna feature DEVE dipendere
/// direttamente dalle interfacce di Drift (PL-5): il repository di
/// `core/storage` (`PlanDayLocalStore`) è l'unico punto di accesso, con
/// tipi propri (`records/`) al posto delle righe generate da Drift.
///
/// Solo ciò che serve alla consultazione offline della v1 (6.1bis,
/// OF-19): le occorrenze della settimana corrente — è quanto legge
/// davvero la vista giornaliera già costruita (F12/F13), l'unico punto
/// in cui l'Utente consulta il contenuto dei pasti. Nessuna tabella per
/// il piano stesso: nessuna schermata ne legge lo schema settimanale
/// offline (la redazione è un contesto di scrittura, esclusa da OF-20;
/// la card di gestione mostra nome/stato/azioni, mai lo schema). Nessuna
/// scrittura offline, nessuna coda: ambizione a lungo termine, fuori
/// ambito (vedi decisioni.md).
@DriftDatabase(tables: [LocalPlanDays])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.connection);

  factory AppDatabase.defaults(LocalDatabaseKeyStore keyStore) {
    return AppDatabase(DatabaseConnection.delayed(impl.openConnection(keyStore: keyStore)));
  }

  /// La versione sale quando muta la **forma** di ciò che è conservato, non
  /// solo la struttura delle tabelle: la 2 introduce gli elementi dello slot
  /// in luogo del contenuto testuale (PL-11bis).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // PL-11bis: le occorrenze conservate sono JSON nella forma che
          // conosceva la versione che le ha scritte, e reinterpretarle
          // presenterebbe slot vuoti — peggio che non averle. Si svuotano, e
          // la cache si ricostituisce alla prima lettura riuscita (PL-11).
          // Nessuna perdita: è una cache di sola lettura (PL-6), non la sede
          // di alcun dato.
          await delete(localPlanDays).go();
        },
      );
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase.defaults(ref.watch(localDatabaseKeyStoreProvider));
  ref.onDispose(database.close);
  return database;
}
