/// Corpo di `POST /care-link-requests` (CP-1, CP-3): l'Utente individuato
/// dalla ricerca e il messaggio facoltativo di presentazione.
class CreateCareLinkRequest {
  const CreateCareLinkRequest({required this.targetUserId, this.message});

  final String targetUserId;
  final String? message;

  Map<String, dynamic> toJson() => {'targetUserId': targetUserId, 'message': message};
}
