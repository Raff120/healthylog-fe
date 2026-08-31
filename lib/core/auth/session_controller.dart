import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/identity/providers/identity_providers.dart';
import 'refresh_token_storage.dart';
import 'session.dart';

part 'session_controller.g.dart';

/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). All'avvio tenta il
/// ripristino dal token di rinnovo conservato nell'archivio sicuro
/// (TK-8): un token presente ma non più valido (revocato, scaduto) è
/// trattato come sessione assente, non come errore da mostrare.
@riverpod
class SessionController extends _$SessionController {
  @override
  Future<AuthSession?> build() async {
    final storage = ref.watch(refreshTokenStorageProvider);
    String? refreshToken;
    try {
      refreshToken = await storage.read();
    } catch (_) {
      // Archivio sicuro non disponibile (piattaforma priva del canale,
      // ambiente di test): equivale a nessuna sessione da ripristinare.
      return null;
    }
    if (refreshToken == null) return null;

    try {
      final tokens = await ref.read(identityApiProvider).refresh(refreshToken);
      await storage.write(tokens.refreshToken);
      return AuthSession(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
    } catch (_) {
      await storage.clear();
      return null;
    }
  }

  Future<void> set(AuthSession session) async {
    await ref.read(refreshTokenStorageProvider).write(session.refreshToken);
    state = AsyncValue.data(session);
  }

  void updateAccessToken(String accessToken) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(accessToken: accessToken));
  }

  Future<void> clear() async {
    await ref.read(refreshTokenStorageProvider).clear();
    state = const AsyncValue.data(null);
  }
}
