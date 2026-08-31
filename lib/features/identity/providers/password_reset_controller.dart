import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'identity_providers.dart';

part 'password_reset_controller.g.dart';

/// Richiesta di recupero password (AC-16, AU-18): l'esito è sempre il
/// medesimo, qui come sul server — la schermata non riceve nulla su cui
/// distinguere l'esistenza dell'account.
@riverpod
class PasswordResetRequestController extends _$PasswordResetRequestController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> submit(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(identityApiProvider).requestPasswordReset(email));
  }
}

/// Reimpostazione della password (AC-16, AC-18, AU-19: invalida tutte le
/// sessioni, quindi non aggiorna la sessione corrente qui — l'Utente
/// rientra dall'accesso).
@riverpod
class PasswordResetConfirmController extends _$PasswordResetConfirmController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> submit(String token, String newPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(identityApiProvider).confirmPasswordReset(token, newPassword),
    );
  }
}
