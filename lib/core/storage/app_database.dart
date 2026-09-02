import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connection/connection_stub.dart'
    if (dart.library.io) 'connection/connection_native.dart'
    if (dart.library.js_interop) 'connection/connection_web.dart' as impl;
import 'local_database_key_store.dart';
import 'tables/local_diet_plan_table.dart';
import 'tables/local_plan_day_table.dart';

part 'app_database.g.dart';

/// Base dati locale (6.1 tecnica): connessione e cifratura (PL-1, PL-13,
/// PL-15), schema e accesso (PL-5, PL-6). Nessuna feature DEVE dipendere
/// direttamente dalle interfacce di Drift (PL-5): i repository di
/// `core/storage` (`DietPlanLocalStore`, `PlanDayLocalStore`) sono
/// l'unico punto di accesso, con tipi propri (`records/`) al posto
/// delle righe generate da Drift.
///
/// Solo ciò che serve alla consultazione offline della v1 (6.1bis,
/// OF-19): il piano attivo con schema settimanale e le occorrenze della
/// settimana corrente. Nessuna scrittura offline, nessuna coda: sono
/// ambizione a lungo termine, fuori ambito (vedi decisioni.md).
@DriftDatabase(tables: [LocalDietPlans, LocalPlanDays])
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
