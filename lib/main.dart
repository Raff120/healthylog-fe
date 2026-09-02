import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_mode_controller.dart';

void main() {
  // FE-3, CT-17: indirizzi senza `#`, come richiede il routing della
  // PWA in produzione (nginx restituisce il documento principale per
  // ogni percorso privo di corrispondenza — un fallback pensato per
  // questa strategia, non per quella con hash). Innocuo sulle
  // piattaforme non web (no-op).
  usePathUrlStrategy();
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
      // Comunicazione: l'applicazione è scritta in italiano fin da qui
      // (CN-1, CN-2) — questo fissa la sola lingua dei widget di
      // sistema (selettore data e simili) a quella già in uso ovunque
      // nel codice. La selezione della lingua da parte dell'Utente
      // (LO-1, LO-2) resta compito di F29, non anticipato qui.
      locale: const Locale('it'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it')],
    );
  }
}
