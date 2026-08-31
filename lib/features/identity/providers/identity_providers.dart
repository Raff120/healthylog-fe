import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/identity_api.dart';

part 'identity_providers.g.dart';

/// Usa [publicApiClientProvider], non [apiClientProvider]: tutti gli
/// endpoint della feature identity sono pubblici (4.4 tecnica), e
/// [apiClientProvider] dipende dalla sessione — usarlo qui produrrebbe
/// una dipendenza circolare, dato che il ripristino della sessione
/// (TK-8) chiama `/auth/refresh` attraverso questo stesso provider.
@riverpod
IdentityApi identityApi(Ref ref) => IdentityApi(ref.watch(publicApiClientProvider));
