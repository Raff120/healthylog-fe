import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/plan_day_local_store.dart';
import '../../../core/storage/preferences_store.dart';

part 'plan_day_cache_format.g.dart';

/// Formato delle occorrenze conservate sul dispositivo (PL-11bis).
///
/// Le occorrenze locali sono JSON nella forma che il client che le ha scritte
/// conosceva. Mutato il formato — gli elementi dello slot in luogo del testo
/// libero — quanto è già sul dispositivo non è reinterpretabile: letto dalla
/// versione nuova presenterebbe slot vuoti, che è peggio che non averli. Si
/// svuota dunque all'avvio della versione che introduce il mutamento, e la
/// cache si ricostituisce alla prima lettura riuscita (PL-11).
///
/// Lo svuotamento avviene una volta sola: il formato conservato è ricordato
/// fra le preferenze, e chi lo trova già aggiornato non tocca nulla.
const planDayCacheFormat = '2';

const planDayCacheFormatKey = 'plan_day_cache_format';

/// Svuota le occorrenze locali se sono state scritte in un formato diverso da
/// quello corrente. Atteso da ogni lettura e scrittura della cache, cosicché
/// nessuna preceda la verifica quale che sia l'ordine in cui le schermate si
/// aprono.
///
/// `keepAlive`: la verifica è dell'avvio, non della schermata che per prima vi
/// incappa.
@Riverpod(keepAlive: true)
Future<void> planDayCacheFormatCheck(Ref ref) async {
  final preferences = ref.read(preferencesStoreProvider);
  try {
    if (await preferences.read(planDayCacheFormatKey) == planDayCacheFormat) return;
    await ref.read(planDayLocalStoreProvider).deleteAll();
    await preferences.write(planDayCacheFormatKey, planDayCacheFormat);
  } catch (_) {
    // Preferenze non leggibili (piattaforma priva del canale): la cache
    // resta com'è. Peggio sarebbe impedire la lettura del piano per un
    // formato che non si riesce a constatare.
  }
}
