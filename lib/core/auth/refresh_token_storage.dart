import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/secure_key_value_store.dart';

part 'refresh_token_storage.g.dart';

const _refreshTokenKey = 'refresh_token';

/// Conservazione del solo token di rinnovo (TK-8, TK-9: il token di
/// accesso non è mai persistito).
class RefreshTokenStorage {
  const RefreshTokenStorage(this._store);

  final SecureKeyValueStore _store;

  Future<String?> read() => _store.read(_refreshTokenKey);

  Future<void> write(String refreshToken) => _store.write(_refreshTokenKey, refreshToken);

  Future<void> clear() => _store.delete(_refreshTokenKey);
}

@riverpod
RefreshTokenStorage refreshTokenStorage(Ref ref) =>
    RefreshTokenStorage(ref.watch(secureKeyValueStoreProvider));
