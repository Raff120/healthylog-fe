import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// iOS, Android, macOS e Windows: il documento è scritto in una cartella
/// temporanea e consegnato al foglio di condivisione del sistema, che
/// lascia all'Utente dove riporlo — file, posta, stampa.
///
/// La cartella temporanea è quella che il sistema può ripulire da sé: il
/// documento non è un dato dell'applicazione da conservare, è una copia
/// che l'Utente porta altrove.
Future<void> deliverFile({
  required String fileName,
  required List<int> bytes,
  required String mimeType,
}) async {
  final directory = await getTemporaryDirectory();
  final file = File(p.join(directory.path, fileName));
  await file.writeAsBytes(bytes, flush: true);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: mimeType)]));
}
