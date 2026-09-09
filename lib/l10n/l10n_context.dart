import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart' show L10n;

/// Accesso alle traduzioni (LO-1), sul modello già in uso per il tema
/// (`context.colors`, `context.typography`): i widget leggono sempre
/// `context.l10n`, mai `L10n.of(context)`.
extension L10nContext on BuildContext {
  L10n get l10n => L10n.of(this);
}
