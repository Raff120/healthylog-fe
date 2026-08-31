import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/identity_api.dart';

part 'identity_providers.g.dart';

@riverpod
IdentityApi identityApi(Ref ref) => IdentityApi(ref.watch(apiClientProvider));
