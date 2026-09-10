import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_mode_controller.dart';
import 'core/device/keyboard_insets.dart';
import 'core/device/page_chrome.dart';
import 'l10n/app_locale.dart';
import 'l10n/generated/app_localizations.dart';
import 'l10n/locale_controller.dart';

void main() async {
  // FE-3, CT-17: indirizzi senza `#`, come richiede il routing della
  // PWA in produzione (nginx restituisce il documento principale per
  // ogni percorso privo di corrispondenza — un fallback pensato per
  // questa strategia, non per quella con hash). Innocuo sulle
  // piattaforme non web (no-op).
  usePathUrlStrategy();
  // LO-9: carica i simboli di data delle lingue di LO-1, che `DateFormat`
  // richiede per formattare in una lingua diversa da quella predefinita.
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const ProviderScope(child: HealthyLogApp()));
}

class HealthyLogApp extends ConsumerWidget {
  const HealthyLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'HealthyLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // 12.2 interfaccia.md: predefinito Sistema finché l'Utente non
      // sceglie diversamente dalle Impostazioni. `.value` degrada al
      // predefinito durante il breve caricamento della preferenza (mai
      // un errore mostrato, sul modello di SessionController).
      themeMode: ref.watch(themeModeControllerProvider).value ?? ThemeMode.system,
      routerConfig: ref.watch(goRouterProvider),
      // Due correzioni del solo web, trasparenti altrove: la pagina che
      // ospita l'applicazione prende il tema in uso e non quello del
      // sistema operativo (`page_chrome.dart`), e la tastiera di sistema
      // — che il motore non riferisce — è misurata e immessa in
      // `MediaQuery` (`keyboard_insets.dart`). MP-2, MP-5, MP-9.
      builder: (context, child) => PageChromeSync(
        child: withKeyboardInsets(child: child ?? const SizedBox.shrink()),
      ),
      // LO-1, LO-2: la lingua scelta dall'Utente, indipendente da quella
      // del sistema operativo. Governa insieme le traduzioni
      // dell'applicazione e i widget di sistema (selettore della data e
      // simili), e con esse i formati di data e numero (LO-9, LO-10).
      locale: ref.watch(appLocaleProvider),
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [for (final locale in supportedAppLocales) locale.flutterLocale],
      // LO-2: la risoluzione entra in gioco per i soli widget di sistema —
      // `locale` sopra è sempre una delle due lingue previste.
      localeResolutionCallback: resolveAppLocale,
    );
  }
}
