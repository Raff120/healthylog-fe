import 'file_download_stub.dart'
    if (dart.library.io) 'file_download_native.dart'
    if (dart.library.js_interop) 'file_download_web.dart' as impl;

/// Consegna all'Utente un file generato dal server (PV-12, PV-15).
///
/// MP-2: la consegna avviene su ogni piattaforma, con il mezzo che
/// ciascuna offre — il foglio di condivisione del sistema dove c'è, il
/// download del browser sul web. Ciò che l'Utente ottiene è lo stesso
/// documento.
Future<void> deliverFile({
  required String fileName,
  required List<int> bytes,
  required String mimeType,
}) =>
    impl.deliverFile(fileName: fileName, bytes: bytes, mimeType: mimeType);
