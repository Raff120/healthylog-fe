import '../../dietplan/data/plan_status.dart';

/// Stato della richiesta di collegamento (rispecchia
/// `it.healthylog.model.CareLinkRequestStatus`).
enum CareLinkRequestStatus {
  pending,
  accepted,
  rejected,
  expired,
  withdrawn;

  static CareLinkRequestStatus fromJson(String value) => switch (value) {
        'ACCEPTED' => CareLinkRequestStatus.accepted,
        'REJECTED' => CareLinkRequestStatus.rejected,
        'EXPIRED' => CareLinkRequestStatus.expired,
        'WITHDRAWN' => CareLinkRequestStatus.withdrawn,
        _ => CareLinkRequestStatus.pending,
      };
}

/// Stato del collegamento (rispecchia `it.healthylog.model.CareLinkStatus`).
enum CareLinkStatus {
  active,
  revoked;

  static CareLinkStatus fromJson(String value) =>
      value == 'REVOKED' ? CareLinkStatus.revoked : CareLinkStatus.active;
}

/// Rispecchia `CareLinkRequestResponse` sul backend (4.3 funzionale):
/// l'identità di entrambe le parti (PR-3, CP-5), il messaggio (CP-3) e
/// la scadenza (CP-7).
class CareLinkRequest {
  const CareLinkRequest({
    required this.id,
    required this.nutritionistId,
    required this.nutritionistFirstName,
    required this.nutritionistLastName,
    required this.targetUserId,
    required this.targetFirstName,
    required this.targetLastName,
    required this.message,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    required this.resolvedAt,
  });

  factory CareLinkRequest.fromJson(Map<String, dynamic> json) => CareLinkRequest(
        id: json['id'] as String,
        nutritionistId: json['nutritionistId'] as String,
        nutritionistFirstName: json['nutritionistFirstName'] as String?,
        nutritionistLastName: json['nutritionistLastName'] as String?,
        targetUserId: json['targetUserId'] as String,
        targetFirstName: json['targetFirstName'] as String?,
        targetLastName: json['targetLastName'] as String?,
        message: json['message'] as String?,
        status: CareLinkRequestStatus.fromJson(json['status'] as String),
        expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        resolvedAt: json['resolvedAt'] == null ? null : DateTime.parse(json['resolvedAt'] as String),
      );

  final String id;
  final String nutritionistId;
  final String? nutritionistFirstName;
  final String? nutritionistLastName;
  final String targetUserId;
  final String? targetFirstName;
  final String? targetLastName;
  final String? message;
  final CareLinkRequestStatus status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  String get nutritionistName => '${nutritionistFirstName ?? ''} ${nutritionistLastName ?? ''}'.trim();
  String get targetName => '${targetFirstName ?? ''} ${targetLastName ?? ''}'.trim();
}

/// Rispecchia `CareLinkResponse` sul backend (RG-4, CP-11).
class CareLink {
  const CareLink({
    required this.id,
    required this.nutritionistId,
    required this.nutritionistFirstName,
    required this.nutritionistLastName,
    required this.patientId,
    required this.patientFirstName,
    required this.patientLastName,
    required this.status,
    required this.createdAt,
    required this.revokedAt,
  });

  factory CareLink.fromJson(Map<String, dynamic> json) => CareLink(
        id: json['id'] as String,
        nutritionistId: json['nutritionistId'] as String,
        nutritionistFirstName: json['nutritionistFirstName'] as String?,
        nutritionistLastName: json['nutritionistLastName'] as String?,
        patientId: json['patientId'] as String,
        patientFirstName: json['patientFirstName'] as String?,
        patientLastName: json['patientLastName'] as String?,
        status: CareLinkStatus.fromJson(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        revokedAt: json['revokedAt'] == null ? null : DateTime.parse(json['revokedAt'] as String),
      );

  final String id;
  final String nutritionistId;
  final String? nutritionistFirstName;
  final String? nutritionistLastName;
  final String patientId;
  final String? patientFirstName;
  final String? patientLastName;
  final CareLinkStatus status;
  final DateTime createdAt;
  final DateTime? revokedAt;

  String get nutritionistName => '${nutritionistFirstName ?? ''} ${nutritionistLastName ?? ''}'.trim();
}

/// Rispecchia `UserLookupResponse` (CP-1, CP-2): la sola identità utile a
/// riconoscere la persona prima dell'invito (9.3 interfaccia.md).
class UserLookup {
  const UserLookup({required this.id, required this.username, required this.firstName, required this.lastName});

  factory UserLookup.fromJson(Map<String, dynamic> json) => UserLookup(
        id: json['id'] as String,
        username: json['username'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
      );

  final String id;
  final String username;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';
}

/// Rispecchia `PatientPlanSummaryResponse` (VA-2, ST-16).
class PatientPlanSummary {
  const PatientPlanSummary({
    required this.id,
    required this.name,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory PatientPlanSummary.fromJson(Map<String, dynamic> json) => PatientPlanSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        status: PlanStatus.fromJson(json['status'] as String),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
      );

  final String id;
  final String name;
  final PlanStatus status;
  final DateTime startDate;
  final DateTime? endDate;
}

/// Voce dell'elenco dei Pazienti (VA-1, VA-2). VA-3: gli indicatori sono
/// assenti quando il Paziente segue un piano non redatto dal
/// Nutrizionista, senza rivelare l'esistenza di quel piano. `adherence` è
/// il valore del periodo recente, percentuale non arrotondata (AD-1ter);
/// VA-5: criterio di ordinamento, mai graduatoria di merito.
class PatientSummary {
  const PatientSummary({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.careLinkId,
    required this.linkedAt,
    required this.currentPlan,
    required this.adherence,
    required this.lastActivityAt,
  });

  factory PatientSummary.fromJson(Map<String, dynamic> json) => PatientSummary(
        userId: json['userId'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        username: json['username'] as String?,
        careLinkId: json['careLinkId'] as String,
        linkedAt: DateTime.parse(json['linkedAt'] as String),
        currentPlan: json['currentPlan'] == null
            ? null
            : PatientPlanSummary.fromJson(json['currentPlan'] as Map<String, dynamic>),
        adherence: (json['adherence'] as num?)?.toDouble(),
        lastActivityAt: json['lastActivityAt'] == null ? null : DateTime.parse(json['lastActivityAt'] as String),
      );

  final String userId;
  final String firstName;
  final String lastName;
  final String? username;
  final String careLinkId;
  final DateTime linkedAt;
  final PatientPlanSummary? currentPlan;
  final double? adherence;
  final DateTime? lastActivityAt;

  String get fullName => '$firstName $lastName';
}

/// Rispecchia `PatientDetailResponse` (VA-7, 9.2 interfaccia.md): i soli
/// piani redatti dal Nutrizionista (ST-16).
class PatientDetail {
  const PatientDetail({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.careLinkId,
    required this.linkedAt,
    required this.plans,
    required this.lastActivityAt,
  });

  factory PatientDetail.fromJson(Map<String, dynamic> json) => PatientDetail(
        userId: json['userId'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        username: json['username'] as String?,
        careLinkId: json['careLinkId'] as String,
        linkedAt: DateTime.parse(json['linkedAt'] as String),
        plans: (json['plans'] as List).map((e) => PatientPlanSummary.fromJson(e as Map<String, dynamic>)).toList(),
        lastActivityAt: json['lastActivityAt'] == null ? null : DateTime.parse(json['lastActivityAt'] as String),
      );

  final String userId;
  final String firstName;
  final String lastName;
  final String? username;
  final String careLinkId;
  final DateTime linkedAt;
  final List<PatientPlanSummary> plans;
  final DateTime? lastActivityAt;

  String get fullName => '$firstName $lastName';
}

/// VA-4: i tre criteri di ordinamento dell'elenco dei Pazienti, nella
/// forma del parametro `sort` di `GET /patients`.
enum PatientSort {
  name('name', 'Alfabetico'),
  adherence('adherence', 'Aderenza'),
  activity('activity', 'Attività recente');

  const PatientSort(this.param, this.label);

  final String param;
  final String label;
}
