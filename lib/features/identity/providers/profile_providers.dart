import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/session_controller.dart';
import '../../../l10n/locale_controller.dart';
import '../../../l10n/unit_system.dart';
import '../data/profile_api.dart';
import '../data/profile_models.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileApi profileApi(Ref ref) => ProfileApi(ref.watch(apiClientProvider));

/// Profilo dell'Utente autenticato (PR-1, PR-4, PR-6). Caricato al primo
/// accesso alla schermata e aggiornato dopo ogni modifica riuscita, così
/// che l'intestazione (12.1 interfaccia.md) rifletta subito il nuovo
/// valore senza un'ulteriore lettura.
@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<Profile> build() async {
    final profile = await ref.read(profileApiProvider).getProfile();
    // LO-2, MP-11: un dispositivo che non abbia ancora una lingua propria
    // adotta quella del profilo, così che il primo accesso da un
    // dispositivo nuovo ritrovi la scelta fatta altrove. Una preferenza
    // locale già presente non è toccata: è la fonte della presentazione.
    unawaited(ref.read(localeControllerProvider.notifier).adoptFromProfile(profile.locale));
    return profile;
  }

  Future<Profile> save(UpdateProfileRequest request) async {
    final profile = await ref.read(profileApiProvider).updateProfile(request);
    state = AsyncValue.data(profile);
    return profile;
  }

  /// LO-2, LO-4: lingua e unità di misura (12.2 interfaccia.md).
  Future<Profile> savePreferences(UpdatePreferencesRequest request) async {
    final profile = await ref.read(profileApiProvider).updatePreferences(request);
    state = AsyncValue.data(profile);
    return profile;
  }

  /// PV-7, PV-8: accettazione dell'informativa vigente.
  Future<Profile> acceptPrivacyPolicy() async {
    final profile = await ref.read(profileApiProvider).acceptPrivacyPolicy();
    state = AsyncValue.data(profile);
    return profile;
  }

  /// PV-16: la richiesta apre il periodo di ripensamento.
  Future<Profile> requestDeletion() async {
    final profile = await ref.read(profileApiProvider).requestDeletion();
    state = AsyncValue.data(profile);
    return profile;
  }

  /// PV-17: la revoca della richiesta, con integrale ripristino.
  Future<Profile> cancelDeletion() async {
    final profile = await ref.read(profileApiProvider).cancelDeletion();
    state = AsyncValue.data(profile);
    return profile;
  }

  /// LO-13 (F11, deroga: vedi decisioni.md).
  Future<Profile> saveTimezone(String timezone) async {
    final profile = await ref.read(profileApiProvider).updateTimezone(UpdateTimezoneRequest(timezone));
    state = AsyncValue.data(profile);
    return profile;
  }
}

/// Il profilo quando — e solo quando — una sessione è attiva.
///
/// Osservarlo non fa partire il caricamento del profilo a chi non ha
/// ancora effettuato l'accesso: `profileControllerProvider` è raggiunto
/// solo dopo la verifica della sessione. Serve all'instradamento, che
/// deve reagire agli sbarramenti di PV-8 e PV-17 senza per questo
/// interrogare il server prima dell'accesso.
@Riverpod(keepAlive: true)
Profile? currentProfileOrNull(Ref ref) {
  if (ref.watch(sessionControllerProvider).value == null) return null;
  return ref.watch(profileControllerProvider).value;
}

/// LO-4: il sistema di unità di misura scelto dall'Utente, che ogni
/// schermata consulta per convertire la presentazione (LO-7). Degrada al
/// metrico durante il caricamento del profilo — LO-6 lo vuole comunque
/// predefinito — invece di lasciare la schermata senza unità.
@riverpod
UnitSystem unitSystem(Ref ref) =>
    ref.watch(profileControllerProvider).value?.unitSystem ?? UnitSystem.fallback;
