import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Denominazione del dispositivo (TK-18) inviata all'accesso perché compaia
/// nell'elenco delle sessioni attive (AC-14). Approssimata dalla sola
/// piattaforma di esecuzione: non richiede pacchetti aggiuntivi (TS-9) e
/// resta sufficiente allo scopo — distinguere un dispositivo dall'altro
/// nell'elenco, non identificarlo univocamente.
String currentDeviceLabel() {
  if (kIsWeb) return 'Browser web';
  if (Platform.isIOS) return 'iPhone o iPad';
  if (Platform.isAndroid) return 'Android';
  if (Platform.isMacOS) return 'Mac';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Dispositivo';
}
