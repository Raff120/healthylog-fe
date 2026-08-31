import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
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
  Future<Profile> build() => ref.read(profileApiProvider).getProfile();

  Future<Profile> save(UpdateProfileRequest request) async {
    final profile = await ref.read(profileApiProvider).updateProfile(request);
    state = AsyncValue.data(profile);
    return profile;
  }
}
