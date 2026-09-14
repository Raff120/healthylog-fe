import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Piattaforma dichiarata al backend a ogni richiesta (VR-13), nella forma
/// che questo attende. `null` dove nessun valore di VR-13 corrisponde —
/// Linux, estraneo alle piattaforme di MP-1: la dichiarazione è omessa, e
/// il client non è soggetto al build minimo (VR-16).
String? currentClientPlatform() {
  if (kIsWeb) return 'web';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  return null;
}
