import 'package:drift/drift.dart';

import '../local_database_key_store.dart';

Future<DatabaseConnection> openConnection({required LocalDatabaseKeyStore keyStore}) {
  throw UnsupportedError('Nessuna implementazione della connessione per questa piattaforma.');
}
