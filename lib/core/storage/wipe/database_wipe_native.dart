import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _fileName = 'healthylog.sqlite';

/// Rimozione del file cifrato (PL-17) e dei suoi file ausiliari SQLite
/// (WAL, shared-memory, journal), presenti secondo la modalità con cui
/// il file è stato aperto l'ultima volta.
Future<void> deleteDatabaseFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final base = p.join(directory.path, _fileName);
  for (final path in [base, '$base-wal', '$base-shm', '$base-journal']) {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
