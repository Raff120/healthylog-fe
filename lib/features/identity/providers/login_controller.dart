import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session.dart';
import '../../../core/auth/session_controller.dart';
import '../data/auth_models.dart';
import 'identity_providers.dart';

part 'login_controller.g.dart';

/// Invio del modulo di accesso (AC-8). Le credenziali errate e il blocco
/// temporaneo (AU-21, AU-23) producono lo stesso codice indistinto
/// `INVALID_CREDENTIALS`, tradotto dalla schermata (5.2 interfaccia.md);
/// `ACCOUNT_NOT_VERIFIED` è gestito a parte, per condurre alla verifica
/// invece che a un messaggio d'errore.
@riverpod
class LoginController extends _$LoginController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> submit(LoginRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final tokens = await ref.read(identityApiProvider).login(request);
      await ref
          .read(sessionControllerProvider.notifier)
          .set(AuthSession(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken));
    });
  }
}
