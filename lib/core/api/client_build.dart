import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_build.g.dart';

/// Numero di build installato (VR-19), letto dal pacchetto e non fornito a
/// compilazione: una build in cui la definizione fosse omessa si
/// dichiarerebbe superata da sé alla prima soglia non nulla.
///
/// Il valore è letto una sola volta, all'avvio, da [readInstalledBuild], e
/// fornito all'applicazione in `main.dart` sovrascrivendo questo provider.
/// Leggerlo qui, a ogni richiesta, ne farebbe dipendere ogni chiamata da un
/// canale di piattaforma: nei banchi di prova, dove un canale privo di
/// simulazione non risponde mai, tutte le chiamate resterebbero sospese.
///
/// `null` se non fornito o non leggibile: la dichiarazione è omessa, e il
/// client non è soggetto al build minimo (VR-16).
@Riverpod(keepAlive: true)
int? clientBuild(Ref ref) => null;

/// Legge il numero di build dal pacchetto installato, entro un limite di
/// attesa: l'avvio non deve dipendere da un canale che non risponde.
Future<int?> readInstalledBuild() async {
  try {
    final info = await PackageInfo.fromPlatform().timeout(const Duration(seconds: 2));
    return int.tryParse(info.buildNumber);
  } catch (_) {
    return null;
  }
}
