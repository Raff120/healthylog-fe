import 'package:flutter/widgets.dart';

import '../../app/theme/theme_context.dart';
import 'page_chrome_stub.dart'
    if (dart.library.js_interop) 'page_chrome_web.dart' as impl;

/// Accorda alla pagina che ospita l'applicazione il tema in uso.
///
/// Sul web le zone riservate del dispositivo restano fuori dall'elemento
/// ospite (`index.html`), e vi si vede lo sfondo della pagina: dietro la
/// barra di stato e sotto l'indicatore di Home. Quello sfondo è dichiarato
/// in CSS su `prefers-color-scheme`, cioè sul tema del sistema operativo,
/// che è cosa diversa dal tema dell'applicazione — l'Utente lo sceglie
/// dalle Impostazioni, indipendentemente (12.2 interfaccia.md). Divergendo
/// i due, l'applicazione scura si trovava incorniciata di chiaro.
///
/// La dichiarazione CSS resta per il primo disegno, prima che
/// l'applicazione sia caricata; da lì in avanti governa il tema in uso.
///
/// Trasparente sulle piattaforme native, dove non c'è pagina attorno.
class PageChromeSync extends StatefulWidget {
  const PageChromeSync({super.key, required this.child});

  final Widget child;

  @override
  State<PageChromeSync> createState() => _PageChromeSyncState();
}

class _PageChromeSyncState extends State<PageChromeSync> {
  Color? _synced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final background = context.colors.background;
    if (background == _synced) return;
    _synced = background;
    syncPageChrome(background: background);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Porta lo sfondo della pagina — e con esso il colore che il sistema usa
/// per la barra di stato (MP-9) — al colore di fondo del tema in uso.
void syncPageChrome({required Color background}) =>
    impl.syncPageChrome(background: background);
