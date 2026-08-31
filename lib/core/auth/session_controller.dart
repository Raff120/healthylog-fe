import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'session.dart';

part 'session_controller.g.dart';

/// Stato della sessione (5.2 interfaccia.md: l'accesso è richiesto una
/// sola volta per dispositivo, AC-11, TK-15). La sola tenuta in memoria è
/// provvisoria: la conservazione del token di rinnovo nell'archivio
/// sicuro del dispositivo (TK-8) e il ripristino all'avvio sono compiti
/// del prossimo task di F06 — qui la sessione esiste solo per la durata
/// del processo.
@riverpod
class SessionController extends _$SessionController {
  @override
  AuthSession? build() => null;

  void set(AuthSession session) => state = session;

  void updateAccessToken(String accessToken) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(accessToken: accessToken);
  }

  void clear() => state = null;
}
