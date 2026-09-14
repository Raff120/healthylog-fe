import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_build.g.dart';

/// Numero di build installato (VR-19), letto dal pacchetto e non fornito a
/// compilazione: una build in cui la definizione fosse omessa si
/// dichiarerebbe superata da sé alla prima soglia non nulla.
///
/// `null` quando il pacchetto non è leggibile (ambiente di test, piattaforma
/// priva del canale) o il numero non è un intero: la dichiarazione è
/// omessa, e il client non è soggetto al build minimo (VR-16).
@Riverpod(keepAlive: true)
Future<int?> clientBuild(Ref ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber);
  } catch (_) {
    return null;
  }
}
