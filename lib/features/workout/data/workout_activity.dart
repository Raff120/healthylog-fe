/// Sport o attività di un allenamento (AL-2), speculare a
/// `it.healthylog.model.WorkoutActivity`.
///
/// L'elenco è chiuso, con [other] a raccoglierne le eccezioni: l'attività
/// che non vi figura si registra sotto quella voce e prende il nome che
/// l'Utente le dà, conservato nel campo `activityType`.
///
/// La denominazione e l'icona non sono qui ma in
/// `presentation/workout_activity_presentation.dart`: la prima dipende
/// dalla lingua selezionata (LO-1) e l'enumerativo non deve conoscerla, la
/// seconda è materia d'interfaccia (2.5 interfaccia.md).
enum WorkoutActivity {
  basketball('BASKETBALL'),
  boxing('BOXING'),
  calisthenics('CALISTHENICS'),
  climbing('CLIMBING'),
  crossfit('CROSSFIT'),
  cycling('CYCLING'),
  dance('DANCE'),
  golf('GOLF'),
  gym('GYM'),
  hockey('HOCKEY'),
  horseRiding('HORSE_RIDING'),
  martialArts('MARTIAL_ARTS'),
  padel('PADEL'),
  pilates('PILATES'),
  rowing('ROWING'),
  rugby('RUGBY'),
  running('RUNNING'),
  skating('SKATING'),
  skiing('SKIING'),
  snowboard('SNOWBOARD'),
  soccer('SOCCER'),
  spinning('SPINNING'),
  surfing('SURFING'),
  swimming('SWIMMING'),
  tennis('TENNIS'),
  treadmill('TREADMILL'),
  trekking('TREKKING'),
  volleyball('VOLLEYBALL'),
  walking('WALKING'),
  yoga('YOGA'),

  /// AL-2: l'attività che l'elenco non prevede, denominata dall'Utente.
  other('OTHER');

  const WorkoutActivity(this.param);

  final String param;

  /// VR-10: il valore non riconosciuto — uno sport aggiunto all'elenco da
  /// una versione successiva del backend — ricade su [other], che è pur
  /// sempre l'attività cui l'etichetta registrata dà nome. Vi ricadono
  /// anche gli allenamenti anteriori all'elenco, privi del campo.
  static WorkoutActivity fromJson(Object? value) {
    for (final activity in WorkoutActivity.values) {
      if (activity.param == value) return activity;
    }
    return WorkoutActivity.other;
  }

  bool get isOther => this == WorkoutActivity.other;
}

/// Sport già impiegato dall'Utente, con quante volte lo è stato (AL-2,
/// RA-12), come lo restituisce `GET /workouts/activities`.
///
/// Il selettore vi porta in cima gli sport che l'Utente pratica davvero e
/// il filtro ne ricava le voci (10.2 interfaccia.md). [customName] è
/// valorizzato per [WorkoutActivity.other], dove la denominazione è tutto
/// ciò che distingue un'attività dall'altra.
class WorkoutActivityUsage {
  const WorkoutActivityUsage({required this.activity, required this.customName, required this.count});

  factory WorkoutActivityUsage.fromJson(Map<String, dynamic> json) {
    final activity = WorkoutActivity.fromJson(json['activityCode']);
    final label = json['activityType'] as String?;
    return WorkoutActivityUsage(
      activity: activity,
      customName: activity.isOther ? label : null,
      count: json['count'] as int? ?? 0,
    );
  }

  final WorkoutActivity activity;
  final String? customName;
  final int count;
}
