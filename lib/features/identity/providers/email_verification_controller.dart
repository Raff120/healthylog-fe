import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'identity_providers.dart';

part 'email_verification_controller.g.dart';

/// Conferma dell'indirizzo per codice (AU-11) e reinvio del codice
/// (AU-15). Il conto alla rovescia prima della riattivazione del reinvio
/// (AU-22, 5.3 interfaccia.md) è gestito dalla schermata; qui ci sono
/// solo le chiamate e il loro esito.
///
/// Un solo controllore per le due azioni, che appartengono alla medesima
/// schermata e non possono essere in corso insieme: il suo stato è la
/// sua attesa, e distinguerne due obbligherebbe la schermata a comporli.
@riverpod
class EmailVerificationController extends _$EmailVerificationController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> confirm(String email, String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(identityApiProvider).verifyEmail(email, code));
  }

  Future<void> resend(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(identityApiProvider).resendVerification(email));
  }
}
