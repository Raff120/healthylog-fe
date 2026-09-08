import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/cooking_group.dart';
import '../data/cooking_group_api.dart';
import '../data/cooking_group_requests.dart';
import '../data/invite_code.dart';

part 'cooking_group_providers.g.dart';

@riverpod
CookingGroupApi cookingGroupApi(Ref ref) => CookingGroupApi(ref.watch(apiClientProvider));

/// RG-3: il Gruppo dell'Utente autenticato. Un `RESOURCE_NOT_FOUND` (404)
/// significa assenza di Gruppo (8.1 interfaccia.md), non un errore da
/// segnalare — la schermata lo distingue leggendo il codice dell'errore.
/// Ricaricato dopo ogni azione che modifica composizione o denominazione
/// (`ref.invalidateSelf`, tramite `ref.invalidate` dai controller sotto).
@riverpod
class CurrentCookingGroup extends _$CurrentCookingGroup {
  @override
  Future<CookingGroup> build() => ref.read(cookingGroupApiProvider).getCurrent();
}

/// GE-5: i codici di invito vigenti del Gruppo, consultabili dal solo
/// Proprietario — la schermata non invoca questo provider per un
/// richiedente diverso, coerente con la verifica lato server.
@riverpod
class GroupInviteCodes extends _$GroupInviteCodes {
  @override
  Future<List<InviteCode>> build(String groupId) => ref.read(cookingGroupApiProvider).listInviteCodes(groupId);
}

/// GR-9: anteprima del codice inserito, senza consumarne l'utilizzo —
/// `autoDispose` di default: non ha senso conservarla oltre il foglio di
/// adesione che la richiede.
@riverpod
Future<InviteCodePreview> inviteCodePreview(Ref ref, String code) =>
    ref.read(cookingGroupApiProvider).previewInviteCode(InviteCodeRequest(code));

/// GE-1, GE-2: creazione del Gruppo.
@riverpod
class CreateCookingGroupController extends _$CreateCookingGroupController {
  @override
  AsyncValue<CookingGroup>? build() => null;

  Future<void> create(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(cookingGroupApiProvider).create(CookingGroupNameRequest(name)));
    if (state?.hasError == false) ref.invalidate(currentCookingGroupProvider);
  }
}

/// GR-9, GR-10, GR-11: adesione tramite codice, dopo la conferma esplicita
/// raccolta dal foglio di adesione (l'anteprima l'ha già mostrata).
@riverpod
class JoinCookingGroupController extends _$JoinCookingGroupController {
  @override
  AsyncValue<CookingGroup>? build() => null;

  Future<void> join(String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(cookingGroupApiProvider).join(InviteCodeRequest(code)));
    if (state?.hasError == false) ref.invalidate(currentCookingGroupProvider);
  }
}

/// GE-12, GR-1: modifica della denominazione.
@riverpod
class RenameCookingGroupController extends _$RenameCookingGroupController {
  @override
  AsyncValue<CookingGroup>? build() => null;

  Future<void> rename(String groupId, String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(cookingGroupApiProvider).rename(groupId, CookingGroupNameRequest(name)),
    );
    if (state?.hasError == false) ref.invalidate(currentCookingGroupProvider);
  }
}

/// GE-12, UT-14: uscita volontaria — a scioglimento avvenuto o meno, il
/// Gruppo dell'Utente non è più quello di prima (`invalidate`).
@riverpod
class LeaveCookingGroupController extends _$LeaveCookingGroupController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> leave(String groupId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(cookingGroupApiProvider).leave(groupId));
    if (state?.hasError == false) ref.invalidate(currentCookingGroupProvider);
  }
}

/// GE-12: scioglimento esplicito, riservato al Proprietario.
@riverpod
class DissolveCookingGroupController extends _$DissolveCookingGroupController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> dissolve(String groupId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(cookingGroupApiProvider).dissolve(groupId));
    if (state?.hasError == false) ref.invalidate(currentCookingGroupProvider);
  }
}

/// GE-6: rimozione di un membro, riservata al Proprietario.
@riverpod
class RemoveGroupMemberController extends _$RemoveGroupMemberController {
  @override
  AsyncValue<CookingGroup>? build() => null;

  Future<void> remove(String groupId, String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(cookingGroupApiProvider).removeMember(groupId, userId));
    if (state?.hasError == false) ref.invalidate(currentCookingGroupProvider);
  }
}

/// GE-7, GE-8: promozione a Cuoco o revoca del privilegio.
@riverpod
class UpdateGroupMemberController extends _$UpdateGroupMemberController {
  @override
  AsyncValue<CookingGroup>? build() => null;

  Future<void> update(String groupId, String userId, bool cook) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(cookingGroupApiProvider).updateMember(groupId, userId, UpdateGroupMemberRequest(cook: cook)),
    );
    if (state?.hasError == false) ref.invalidate(currentCookingGroupProvider);
  }
}

/// GE-9, GR-15: trasferimento volontario della proprietà.
@riverpod
class TransferGroupOwnershipController extends _$TransferGroupOwnershipController {
  @override
  AsyncValue<CookingGroup>? build() => null;

  Future<void> transfer(String groupId, String newOwnerId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(cookingGroupApiProvider).transferOwnership(groupId, TransferGroupOwnershipRequest(newOwnerId)),
    );
    if (state?.hasError == false) ref.invalidate(currentCookingGroupProvider);
  }
}

/// GR-7, GR-8: generazione di un nuovo codice — la stessa chiamata serve
/// sia la prima generazione sia la rigenerazione (invalida quello
/// precedente lato server).
@riverpod
class GenerateInviteCodeController extends _$GenerateInviteCodeController {
  @override
  AsyncValue<InviteCode>? build() => null;

  Future<void> generate(String groupId, GenerateInviteCodeRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(cookingGroupApiProvider).generateInviteCode(groupId, request));
    if (state?.hasError == false) ref.invalidate(groupInviteCodesProvider(groupId));
  }
}

/// GR-7: revoca esplicita, senza generarne uno nuovo.
@riverpod
class RevokeInviteCodeController extends _$RevokeInviteCodeController {
  @override
  AsyncValue<void>? build() => null;

  Future<void> revoke(String groupId, String inviteCodeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(cookingGroupApiProvider).revokeInviteCode(inviteCodeId));
    if (state?.hasError == false) ref.invalidate(groupInviteCodesProvider(groupId));
  }
}
