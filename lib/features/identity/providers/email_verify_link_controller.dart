import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'identity_providers.dart';

part 'email_verify_link_controller.g.dart';

/// Apertura del collegamento di verifica (AU-11, AU-14): esito immediato,
/// senza alcuna azione dell'Utente (5.3 interfaccia.md).
@riverpod
class EmailVerifyLinkController extends _$EmailVerifyLinkController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> confirm(String token) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(identityApiProvider).verifyEmail(token));
  }
}
