import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web: il documento è consegnato come scaricamento del browser, che è il
/// modo in cui il web mette un file nelle mani di chi naviga.
///
/// L'indirizzo temporaneo dell'oggetto è revocato subito dopo: senza,
/// resterebbe a occupare memoria per l'intera vita della scheda.
Future<void> deliverFile({
  required String fileName,
  required List<int> bytes,
  required String mimeType,
}) async {
  final blob = web.Blob(
    [Uint8List.fromList(bytes).toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
