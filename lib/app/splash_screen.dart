import 'package:flutter/material.dart';

import 'theme/theme_context.dart';

/// Verifica della sessione all'avvio (5.2 interfaccia.md): il solo
/// marchio, per un tempo che deve restare impercettibile. Puramente
/// visiva: l'instradamento verso l'accesso o verso la destinazione
/// autenticata, una volta risolta la sessione, è compito del `redirect`
/// centralizzato del router (`app/router.dart`), non di questa
/// schermata — un solo punto in cui la protezione delle rotte è
/// decisa, non duplicato qui.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Text('HealthyLog', style: typography.titleLarge.copyWith(color: colors.textPrimary)),
      ),
    );
  }
}
