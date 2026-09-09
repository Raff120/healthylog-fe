import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/session_controller.dart';
import '../data/device_session.dart';
import '../data/sessions_api.dart';

part 'sessions_providers.g.dart';

@riverpod
SessionsApi sessionsApi(Ref ref) => SessionsApi(ref.watch(apiClientProvider));

/// Elenco dei dispositivi attivi (AC-14, TK-18).
@riverpod
class DevicesController extends _$DevicesController {
  @override
  Future<List<DeviceSession>> build() {
    final currentRefreshToken = ref.watch(sessionControllerProvider).value?.refreshToken;
    return ref.read(sessionsApiProvider).getSessions(currentRefreshToken);
  }

  Future<void> revoke(String id) async {
    await ref.read(sessionsApiProvider).revokeSession(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> revokeAllExceptCurrent() async {
    final currentRefreshToken = ref.read(sessionControllerProvider).value?.refreshToken;
    await ref.read(sessionsApiProvider).revokeAllExceptCurrent(currentRefreshToken);
    ref.invalidateSelf();
    await future;
  }
}
