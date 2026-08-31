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
///
/// `keepAlive`: letto con `ref.read` (non `ref.watch`) dagli
/// intercettori HTTP, che altrimenti non lo terrebbero in vita — la
/// sessione andrebbe perduta ogni volta che nessuna schermata la osserva.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  Future<AuthSession?>? _refreshInFlight;

  // Incrementato da `set`/`clear`: se cambia mentre `build` è ancora in
  // corso, un accesso o una disconnessione espliciti sono intervenuti
  // nel frattempo e il ripristino, quando infine risolve, NON DEVE
  // sovrascriverli — altrimenti un accesso appena eseguito potrebbe
  // essere rimpiazzato dall'esito, tardivo, del tentativo di ripristino
  // di un token diverso e più vecchio ancora conservato sul dispositivo.
  int _generation = 0;

  @override
  Future<AuthSession?> build() async {
    final myGeneration = ++_generation;
    final storage = ref.watch(refreshTokenStorageProvider);
    String? refreshToken;
    try {
      refreshToken = await storage.read();
    } catch (_) {
      // Archivio sicuro non disponibile (piattaforma priva del canale,
      // ambiente di test): equivale a nessuna sessione da ripristinare.
      return myGeneration == _generation ? null : state.value;
    }
    if (refreshToken == null) return myGeneration == _generation ? null : state.value;

    final restored = await _refreshWith(refreshToken);
    return myGeneration == _generation ? restored : state.value;
  }

  Future<void> set(AuthSession session) async {
    _generation++;
    await ref.read(refreshTokenStorageProvider).write(session.refreshToken);
    state = AsyncValue.data(session);
  }

  Future<void> clear() async {
    _generation++;
    await ref.read(refreshTokenStorageProvider).clear();
    state = const AsyncValue.data(null);
  }

  /// TK-13, TK-14: chiamato da [TokenRefreshInterceptor] quando una
  /// richiesta incontra `TOKEN_EXPIRED`. Le richieste concorrenti che
  /// invocano questo metodo mentre un rinnovo è già in corso ne
  /// condividono l'esito invece di avviarne ciascuna uno proprio —
  /// altrimenti la rotazione (TK-11) scatterebbe più volte e la seconda
  /// risulterebbe un riuso (TK-12), revocando l'intera catena.
  Future<AuthSession?> refreshSession() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final current = state.value;
    if (current == null) return Future.value(null);

    final future = _refreshWith(current.refreshToken).then((session) {
      state = AsyncValue.data(session);
      return session;
    });
    _refreshInFlight = future;
    future.whenComplete(() => _refreshInFlight = null);
    return future;
  }

  Future<AuthSession?> _refreshWith(String refreshToken) async {
    try {
      final tokens = await ref.read(identityApiProvider).refresh(refreshToken);
      await ref.read(refreshTokenStorageProvider).write(tokens.refreshToken);
      return AuthSession(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
    } catch (_) {
      await ref.read(refreshTokenStorageProvider).clear();
      return null;
    }
  }
}
