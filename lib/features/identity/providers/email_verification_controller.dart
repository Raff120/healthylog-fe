import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'identity_providers.dart';

part 'email_verification_controller.g.dart';

/// Reinvio del collegamento di verifica (AU-15). Il conto alla rovescia
/// prima della riattivazione (AU-22, 5.3 interfaccia.md) è gestito dalla
/// schermata; qui c'è solo la chiamata e il suo esito.
@riverpod
class EmailVerificationController extends _$EmailVerificationController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> resend(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(identityApiProvider).resendVerification(email));
  }
}
