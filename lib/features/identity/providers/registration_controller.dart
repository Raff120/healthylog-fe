import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_models.dart';
import 'identity_providers.dart';

part 'registration_controller.g.dart';

/// Invio del modulo di registrazione (AC-1, AC-2). L'esito favorevole
/// conduce alla verifica dell'indirizzo (5.3 interfaccia.md), senza
/// accesso automatico: la registrazione non restituisce token.
@riverpod
class RegistrationController extends _$RegistrationController {
  @override
  AsyncValue<RegisterResult>? build() => null;

  Future<void> submit(RegisterRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(identityApiProvider).register(request));
  }
}
