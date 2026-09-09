import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import '../local_database_key_store.dart';

const _fileName = 'healthylog.sqlite';

/// Connessione nativa (Android, iOS, macOS, Windows, Linux): file SQLite
/// cifrato con SQLite3MultipleCiphers (PL-13), aperto in un isolate di
/// sfondo. La chiave (PL-15) è impostata con `PRAGMA key` prima di
/// qualunque altro accesso al file.
Future<DatabaseConnection> openConnection({required LocalDatabaseKeyStore keyStore}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(p.join(directory.path, _fileName));
  final key = await keyStore.readOrCreate();

  return NativeDatabase.createBackgroundConnection(
    file,
    setup: (rawDb) {
      rawDb.execute("PRAGMA key = '${_escape(key)}';");
      assert(_hasCipher(rawDb));
    },
  );
}

String _escape(String value) => value.replaceAll("'", "''");

bool _hasCipher(Database database) => database.select('PRAGMA cipher;').isNotEmpty;
