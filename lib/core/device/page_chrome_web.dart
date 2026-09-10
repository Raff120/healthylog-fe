import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Dichiarazione che il sistema legge per tingere le proprie sovrapposizioni
/// — su iOS la barra di stato dell'applicazione installata (MP-9), di cui
/// sceglie anche il colore del testo secondo la luminosità di questo valore.
const _themeColorName = 'theme-color';

web.HTMLMetaElement? _themeColor;

void syncPageChrome({required Color background}) {
  final value = _cssColor(background);
  (web.document.documentElement as web.HTMLElement?)?.style.backgroundColor = value;
  web.document.body?.style.backgroundColor = value;
  _themeColorMeta().content = value;
}

/// La dichiarazione governata dall'applicazione, creata alla prima
/// occorrenza.
///
/// Quelle di `index.html` sono prima rimosse: seguono `prefers-color-scheme`
/// e varrebbero il tema del sistema operativo. Aggiungerne una non
/// basterebbe — il browser onora la prima che corrisponde, non l'ultima.
web.HTMLMetaElement _themeColorMeta() {
  final existing = _themeColor;
  if (existing != null) return existing;

  final declared = web.document.querySelectorAll('meta[name="$_themeColorName"]');
  for (var i = declared.length - 1; i >= 0; i--) {
    (declared.item(i) as web.Element?)?.remove();
  }

  final meta = web.HTMLMetaElement()..name = _themeColorName;
  web.document.head?.appendChild(meta);
  return _themeColor = meta;
}

String _cssColor(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0')}';
}
