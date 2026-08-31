import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/router.dart';
import 'app/theme/app_theme.dart';

void main() {
  // FE-3, CT-17: indirizzi senza `#`, come richiede il routing della
  // PWA in produzione (nginx restituisce il documento principale per
  // ogni percorso privo di corrispondenza — un fallback pensato per
  // questa strategia, non per quella con hash). Innocuo sulle
  // piattaforme non web (no-op).
  usePathUrlStrategy();
  runApp(const ProviderScope(child: HealthyLogApp()));
}

class HealthyLogApp extends StatelessWidget {
  const HealthyLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HealthyLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
