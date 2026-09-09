import 'package:flutter/services.dart';

import '../../../l10n/app_locale.dart';

/// Versione vigente dell'informativa (PV-7). Deve corrispondere a
/// `healthylog.privacy.policy-version` sul server, che sull'accettazione
/// di questa versione si fonda: cambiarla di là senza cambiarla di qua
/// comporta una richiesta di accettazione che il client non saprebbe
/// soddisfare (PV-8).
const String kPrivacyPolicyVersion = '2026-09-09';

/// PV-6, PV-9: il testo integrale, nella lingua selezionata (LO-1).
Future<String> loadPrivacyPolicy(AppLocale locale) => rootBundle.loadString(
      switch (locale) {
        AppLocale.it => 'assets/privacy/informativa_it.md',
        AppLocale.en => 'assets/privacy/informativa_en.md',
      },
    );
