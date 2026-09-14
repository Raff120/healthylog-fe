import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';

part 'store_link.g.dart';

/// VR-18: pagina da cui installare la versione aggiornata, per piattaforma.
/// Configurazione del client: il backend non la conosce.
///
/// - Android: l'indirizzo configurato per le versioni distribuite fuori dallo
///   store (l'APK della release di GitHub), altrimenti la scheda su Google
///   Play, ricavata dal nome del pacchetto;
/// - iOS e macOS: la scheda su App Store, se ne è configurato l'identificativo;
/// - Windows: la scheda su Microsoft Store, se ne è configurato l'identificativo.
///
/// `null` dove nessuna pagina è nota — il web, che non è soggetto
/// all'aggiornamento obbligatorio (MP-17), o un identificativo non ancora
/// configurato: la schermata ne omette l'azione.
@Riverpod(keepAlive: true)
Future<Uri?> storeLink(Ref ref) async {
  if (kIsWeb) return null;
  try {
    if (Platform.isAndroid) {
      if (AppConfig.androidUpdateUrl.isNotEmpty) return Uri.parse(AppConfig.androidUpdateUrl);
      final info = await PackageInfo.fromPlatform();
      return Uri.https('play.google.com', '/store/apps/details', {'id': info.packageName});
    }
    if ((Platform.isIOS || Platform.isMacOS) && AppConfig.appleStoreId.isNotEmpty) {
      return Uri.https('apps.apple.com', '/app/id${AppConfig.appleStoreId}');
    }
    if (Platform.isWindows && AppConfig.microsoftStoreProductId.isNotEmpty) {
      return Uri.parse('ms-windows-store://pdp/?productid=${AppConfig.microsoftStoreProductId}');
    }
  } catch (_) {
    // Pacchetto non leggibile: nessuna pagina nota.
  }
  return null;
}
