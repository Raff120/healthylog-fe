import 'package:dio/dio.dart';

import 'cooking_group.dart';
import 'cooking_group_requests.dart';
import 'invite_code.dart';

/// Chiamate HTTP del Gruppo (4.4 tecnica, 3.4 e 4.4 funzionale).
class CookingGroupApi {
  const CookingGroupApi(this._dio);

  final Dio _dio;

  Future<CookingGroup> create(CookingGroupNameRequest request) async {
    final response = await _dio.post('/cooking-groups', data: request.toJson());
    return CookingGroup.fromJson(response.data as Map<String, dynamic>);
  }

  /// RG-3: il Gruppo dell'Utente autenticato. Restituisce `RESOURCE_NOT_FOUND`
  /// (404) quando non ne fa parte — la schermata lo intercetta per mostrare
  /// lo stato vuoto (8.1 interfaccia.md), non un errore.
  Future<CookingGroup> getCurrent() async {
    final response = await _dio.get('/cooking-groups/current');
    return CookingGroup.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CookingGroup> rename(String groupId, CookingGroupNameRequest request) async {
    final response = await _dio.patch('/cooking-groups/$groupId', data: request.toJson());
    return CookingGroup.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> dissolve(String groupId) => _dio.delete('/cooking-groups/$groupId');

  Future<void> leave(String groupId) => _dio.post('/cooking-groups/$groupId/leave');

  Future<CookingGroup> removeMember(String groupId, String userId) async {
    final response = await _dio.delete('/cooking-groups/$groupId/members/$userId');
    return CookingGroup.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CookingGroup> updateMember(String groupId, String userId, UpdateGroupMemberRequest request) async {
    final response = await _dio.patch('/cooking-groups/$groupId/members/$userId', data: request.toJson());
    return CookingGroup.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CookingGroup> transferOwnership(String groupId, TransferGroupOwnershipRequest request) async {
    final response = await _dio.post('/cooking-groups/$groupId/transfer-ownership', data: request.toJson());
    return CookingGroup.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InviteCode> generateInviteCode(String groupId, GenerateInviteCodeRequest request) async {
    final response = await _dio.post('/cooking-groups/$groupId/invite-codes', data: request.toJson());
    return InviteCode.fromJson(response.data as Map<String, dynamic>);
  }

  /// GE-5: i soli codici ancora vigenti.
  Future<List<InviteCode>> listInviteCodes(String groupId) async {
    final response = await _dio.get('/cooking-groups/$groupId/invite-codes');
    return (response.data as List).map((e) => InviteCode.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> revokeInviteCode(String inviteCodeId) => _dio.delete('/invite-codes/$inviteCodeId');

  /// GR-9: anteprima presentata prima della conferma, senza consumo di utilizzo.
  Future<InviteCodePreview> previewInviteCode(InviteCodeRequest request) async {
    final response = await _dio.post('/invite-codes/preview', data: request.toJson());
    return InviteCodePreview.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CookingGroup> join(InviteCodeRequest request) async {
    final response = await _dio.post('/cooking-groups/join', data: request.toJson());
    return CookingGroup.fromJson(response.data as Map<String, dynamic>);
  }
}
