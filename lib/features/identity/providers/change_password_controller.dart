import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'profile_providers.dart';

part 'change_password_controller.g.dart';

/// Modifica della password dell'Utente autenticato (AC-19, AU-20).
///
/// Non passa da `ProfileController`: la password non fa parte del
/// profilo che quello espone, e l'esito non ne muta alcun campo. Le
/// sessioni attive restano aperte (AU-20) — non ricorre il sospetto di
/// compromissione che AC-18 presume nel recupero.
@riverpod
class ChangePasswordController extends _$ChangePasswordController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> submit(String currentPassword, String newPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(profileApiProvider).changePassword(currentPassword, newPassword),
    );
  }
}
