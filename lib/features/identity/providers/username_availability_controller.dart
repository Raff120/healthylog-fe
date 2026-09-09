import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'identity_providers.dart';

part 'username_availability_controller.g.dart';

/// Verifica di disponibilità del nome utente (5.1 interfaccia.md), invocata
/// dopo una breve pausa dalla digitazione — il rinvio (debounce) è gestito
/// dalla schermata, non qui.
@riverpod
class UsernameAvailabilityController extends _$UsernameAvailabilityController {
  @override
  AsyncValue<bool>? build() => null;

  Future<void> check(String username) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(identityApiProvider).isUsernameAvailable(username),
    );
  }

  void reset() => state = null;
}
