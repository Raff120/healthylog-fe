// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalDietPlansTable extends LocalDietPlans
    with TableInfo<$LocalDietPlansTable, LocalDietPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDietPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorRoleMeta = const VerificationMeta(
    'authorRole',
  );
  @override
  late final GeneratedColumn<String> authorRole = GeneratedColumn<String>(
    'author_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weeklyScheduleJsonMeta =
      const VerificationMeta('weeklyScheduleJson');
  @override
  late final GeneratedColumn<String> weeklyScheduleJson =
      GeneratedColumn<String>(
        'weekly_schedule_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    authorId,
    authorRole,
    name,
    status,
    startDate,
    endDate,
    weeklyScheduleJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_diet_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDietPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('author_role')) {
      context.handle(
        _authorRoleMeta,
        authorRole.isAcceptableOrUnknown(data['author_role']!, _authorRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_authorRoleMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('weekly_schedule_json')) {
      context.handle(
        _weeklyScheduleJsonMeta,
        weeklyScheduleJson.isAcceptableOrUnknown(
          data['weekly_schedule_json']!,
          _weeklyScheduleJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weeklyScheduleJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDietPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDietPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      authorRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_role'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      weeklyScheduleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekly_schedule_json'],
      )!,
    );
  }

  @override
  $LocalDietPlansTable createAlias(String alias) {
    return $LocalDietPlansTable(attachedDatabase, alias);
  }
}

class LocalDietPlan extends DataClass implements Insertable<LocalDietPlan> {
  final String id;
  final String ownerId;
  final String authorId;
  final String authorRole;
  final String name;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String weeklyScheduleJson;
  const LocalDietPlan({
    required this.id,
    required this.ownerId,
    required this.authorId,
    required this.authorRole,
    required this.name,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.weeklyScheduleJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['author_id'] = Variable<String>(authorId);
    map['author_role'] = Variable<String>(authorRole);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['weekly_schedule_json'] = Variable<String>(weeklyScheduleJson);
    return map;
  }

  LocalDietPlansCompanion toCompanion(bool nullToAbsent) {
    return LocalDietPlansCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      authorId: Value(authorId),
      authorRole: Value(authorRole),
      name: Value(name),
      status: Value(status),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      weeklyScheduleJson: Value(weeklyScheduleJson),
    );
  }

  factory LocalDietPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDietPlan(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      authorRole: serializer.fromJson<String>(json['authorRole']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      weeklyScheduleJson: serializer.fromJson<String>(
        json['weeklyScheduleJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'authorId': serializer.toJson<String>(authorId),
      'authorRole': serializer.toJson<String>(authorRole),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'weeklyScheduleJson': serializer.toJson<String>(weeklyScheduleJson),
    };
  }

  LocalDietPlan copyWith({
    String? id,
    String? ownerId,
    String? authorId,
    String? authorRole,
    String? name,
    String? status,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    String? weeklyScheduleJson,
  }) => LocalDietPlan(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    authorId: authorId ?? this.authorId,
    authorRole: authorRole ?? this.authorRole,
    name: name ?? this.name,
    status: status ?? this.status,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    weeklyScheduleJson: weeklyScheduleJson ?? this.weeklyScheduleJson,
  );
  LocalDietPlan copyWithCompanion(LocalDietPlansCompanion data) {
    return LocalDietPlan(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      authorRole: data.authorRole.present
          ? data.authorRole.value
          : this.authorRole,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      weeklyScheduleJson: data.weeklyScheduleJson.present
          ? data.weeklyScheduleJson.value
          : this.weeklyScheduleJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDietPlan(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('authorId: $authorId, ')
          ..write('authorRole: $authorRole, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('weeklyScheduleJson: $weeklyScheduleJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    authorId,
    authorRole,
    name,
    status,
    startDate,
    endDate,
    weeklyScheduleJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDietPlan &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.authorId == this.authorId &&
          other.authorRole == this.authorRole &&
          other.name == this.name &&
          other.status == this.status &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.weeklyScheduleJson == this.weeklyScheduleJson);
}

class LocalDietPlansCompanion extends UpdateCompanion<LocalDietPlan> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> authorId;
  final Value<String> authorRole;
  final Value<String> name;
  final Value<String> status;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<String> weeklyScheduleJson;
  final Value<int> rowid;
  const LocalDietPlansCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.authorRole = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.weeklyScheduleJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDietPlansCompanion.insert({
    required String id,
    required String ownerId,
    required String authorId,
    required String authorRole,
    required String name,
    required String status,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    required String weeklyScheduleJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       authorId = Value(authorId),
       authorRole = Value(authorRole),
       name = Value(name),
       status = Value(status),
       startDate = Value(startDate),
       weeklyScheduleJson = Value(weeklyScheduleJson);
  static Insertable<LocalDietPlan> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? authorId,
    Expression<String>? authorRole,
    Expression<String>? name,
    Expression<String>? status,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? weeklyScheduleJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (authorId != null) 'author_id': authorId,
      if (authorRole != null) 'author_role': authorRole,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (weeklyScheduleJson != null)
        'weekly_schedule_json': weeklyScheduleJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDietPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? authorId,
    Value<String>? authorRole,
    Value<String>? name,
    Value<String>? status,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<String>? weeklyScheduleJson,
    Value<int>? rowid,
  }) {
    return LocalDietPlansCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      authorId: authorId ?? this.authorId,
      authorRole: authorRole ?? this.authorRole,
      name: name ?? this.name,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weeklyScheduleJson: weeklyScheduleJson ?? this.weeklyScheduleJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (authorRole.present) {
      map['author_role'] = Variable<String>(authorRole.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (weeklyScheduleJson.present) {
      map['weekly_schedule_json'] = Variable<String>(weeklyScheduleJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDietPlansCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('authorId: $authorId, ')
          ..write('authorRole: $authorRole, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('weeklyScheduleJson: $weeklyScheduleJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPlanDaysTable extends LocalPlanDays
    with TableInfo<$LocalPlanDaysTable, LocalPlanDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPlanDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverageMeta = const VerificationMeta(
    'coverage',
  );
  @override
  late final GeneratedColumn<String> coverage = GeneratedColumn<String>(
    'coverage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planNameMeta = const VerificationMeta(
    'planName',
  );
  @override
  late final GeneratedColumn<String> planName = GeneratedColumn<String>(
    'plan_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planStartDateMeta = const VerificationMeta(
    'planStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> planStartDate =
      GeneratedColumn<DateTime>(
        'plan_start_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _planEndDateMeta = const VerificationMeta(
    'planEndDate',
  );
  @override
  late final GeneratedColumn<DateTime> planEndDate = GeneratedColumn<DateTime>(
    'plan_end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slotsJsonMeta = const VerificationMeta(
    'slotsJson',
  );
  @override
  late final GeneratedColumn<String> slotsJson = GeneratedColumn<String>(
    'slots_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    coverage,
    planId,
    planName,
    planStartDate,
    planEndDate,
    slotsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_plan_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPlanDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('coverage')) {
      context.handle(
        _coverageMeta,
        coverage.isAcceptableOrUnknown(data['coverage']!, _coverageMeta),
      );
    } else if (isInserting) {
      context.missing(_coverageMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('plan_name')) {
      context.handle(
        _planNameMeta,
        planName.isAcceptableOrUnknown(data['plan_name']!, _planNameMeta),
      );
    }
    if (data.containsKey('plan_start_date')) {
      context.handle(
        _planStartDateMeta,
        planStartDate.isAcceptableOrUnknown(
          data['plan_start_date']!,
          _planStartDateMeta,
        ),
      );
    }
    if (data.containsKey('plan_end_date')) {
      context.handle(
        _planEndDateMeta,
        planEndDate.isAcceptableOrUnknown(
          data['plan_end_date']!,
          _planEndDateMeta,
        ),
      );
    }
    if (data.containsKey('slots_json')) {
      context.handle(
        _slotsJsonMeta,
        slotsJson.isAcceptableOrUnknown(data['slots_json']!, _slotsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_slotsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  LocalPlanDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPlanDay(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      coverage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coverage'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      ),
      planName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_name'],
      ),
      planStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}plan_start_date'],
      ),
      planEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}plan_end_date'],
      ),
      slotsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slots_json'],
      )!,
    );
  }

  @override
  $LocalPlanDaysTable createAlias(String alias) {
    return $LocalPlanDaysTable(attachedDatabase, alias);
  }
}

class LocalPlanDay extends DataClass implements Insertable<LocalPlanDay> {
  final DateTime date;
  final String coverage;
  final String? planId;
  final String? planName;
  final DateTime? planStartDate;
  final DateTime? planEndDate;
  final String slotsJson;
  const LocalPlanDay({
    required this.date,
    required this.coverage,
    this.planId,
    this.planName,
    this.planStartDate,
    this.planEndDate,
    required this.slotsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['coverage'] = Variable<String>(coverage);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<String>(planId);
    }
    if (!nullToAbsent || planName != null) {
      map['plan_name'] = Variable<String>(planName);
    }
    if (!nullToAbsent || planStartDate != null) {
      map['plan_start_date'] = Variable<DateTime>(planStartDate);
    }
    if (!nullToAbsent || planEndDate != null) {
      map['plan_end_date'] = Variable<DateTime>(planEndDate);
    }
    map['slots_json'] = Variable<String>(slotsJson);
    return map;
  }

  LocalPlanDaysCompanion toCompanion(bool nullToAbsent) {
    return LocalPlanDaysCompanion(
      date: Value(date),
      coverage: Value(coverage),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      planName: planName == null && nullToAbsent
          ? const Value.absent()
          : Value(planName),
      planStartDate: planStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(planStartDate),
      planEndDate: planEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(planEndDate),
      slotsJson: Value(slotsJson),
    );
  }

  factory LocalPlanDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPlanDay(
      date: serializer.fromJson<DateTime>(json['date']),
      coverage: serializer.fromJson<String>(json['coverage']),
      planId: serializer.fromJson<String?>(json['planId']),
      planName: serializer.fromJson<String?>(json['planName']),
      planStartDate: serializer.fromJson<DateTime?>(json['planStartDate']),
      planEndDate: serializer.fromJson<DateTime?>(json['planEndDate']),
      slotsJson: serializer.fromJson<String>(json['slotsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'coverage': serializer.toJson<String>(coverage),
      'planId': serializer.toJson<String?>(planId),
      'planName': serializer.toJson<String?>(planName),
      'planStartDate': serializer.toJson<DateTime?>(planStartDate),
      'planEndDate': serializer.toJson<DateTime?>(planEndDate),
      'slotsJson': serializer.toJson<String>(slotsJson),
    };
  }

  LocalPlanDay copyWith({
    DateTime? date,
    String? coverage,
    Value<String?> planId = const Value.absent(),
    Value<String?> planName = const Value.absent(),
    Value<DateTime?> planStartDate = const Value.absent(),
    Value<DateTime?> planEndDate = const Value.absent(),
    String? slotsJson,
  }) => LocalPlanDay(
    date: date ?? this.date,
    coverage: coverage ?? this.coverage,
    planId: planId.present ? planId.value : this.planId,
    planName: planName.present ? planName.value : this.planName,
    planStartDate: planStartDate.present
        ? planStartDate.value
        : this.planStartDate,
    planEndDate: planEndDate.present ? planEndDate.value : this.planEndDate,
    slotsJson: slotsJson ?? this.slotsJson,
  );
  LocalPlanDay copyWithCompanion(LocalPlanDaysCompanion data) {
    return LocalPlanDay(
      date: data.date.present ? data.date.value : this.date,
      coverage: data.coverage.present ? data.coverage.value : this.coverage,
      planId: data.planId.present ? data.planId.value : this.planId,
      planName: data.planName.present ? data.planName.value : this.planName,
      planStartDate: data.planStartDate.present
          ? data.planStartDate.value
          : this.planStartDate,
      planEndDate: data.planEndDate.present
          ? data.planEndDate.value
          : this.planEndDate,
      slotsJson: data.slotsJson.present ? data.slotsJson.value : this.slotsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlanDay(')
          ..write('date: $date, ')
          ..write('coverage: $coverage, ')
          ..write('planId: $planId, ')
          ..write('planName: $planName, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('planEndDate: $planEndDate, ')
          ..write('slotsJson: $slotsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    coverage,
    planId,
    planName,
    planStartDate,
    planEndDate,
    slotsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPlanDay &&
          other.date == this.date &&
          other.coverage == this.coverage &&
          other.planId == this.planId &&
          other.planName == this.planName &&
          other.planStartDate == this.planStartDate &&
          other.planEndDate == this.planEndDate &&
          other.slotsJson == this.slotsJson);
}

class LocalPlanDaysCompanion extends UpdateCompanion<LocalPlanDay> {
  final Value<DateTime> date;
  final Value<String> coverage;
  final Value<String?> planId;
  final Value<String?> planName;
  final Value<DateTime?> planStartDate;
  final Value<DateTime?> planEndDate;
  final Value<String> slotsJson;
  final Value<int> rowid;
  const LocalPlanDaysCompanion({
    this.date = const Value.absent(),
    this.coverage = const Value.absent(),
    this.planId = const Value.absent(),
    this.planName = const Value.absent(),
    this.planStartDate = const Value.absent(),
    this.planEndDate = const Value.absent(),
    this.slotsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPlanDaysCompanion.insert({
    required DateTime date,
    required String coverage,
    this.planId = const Value.absent(),
    this.planName = const Value.absent(),
    this.planStartDate = const Value.absent(),
    this.planEndDate = const Value.absent(),
    required String slotsJson,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       coverage = Value(coverage),
       slotsJson = Value(slotsJson);
  static Insertable<LocalPlanDay> custom({
    Expression<DateTime>? date,
    Expression<String>? coverage,
    Expression<String>? planId,
    Expression<String>? planName,
    Expression<DateTime>? planStartDate,
    Expression<DateTime>? planEndDate,
    Expression<String>? slotsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (coverage != null) 'coverage': coverage,
      if (planId != null) 'plan_id': planId,
      if (planName != null) 'plan_name': planName,
      if (planStartDate != null) 'plan_start_date': planStartDate,
      if (planEndDate != null) 'plan_end_date': planEndDate,
      if (slotsJson != null) 'slots_json': slotsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPlanDaysCompanion copyWith({
    Value<DateTime>? date,
    Value<String>? coverage,
    Value<String?>? planId,
    Value<String?>? planName,
    Value<DateTime?>? planStartDate,
    Value<DateTime?>? planEndDate,
    Value<String>? slotsJson,
    Value<int>? rowid,
  }) {
    return LocalPlanDaysCompanion(
      date: date ?? this.date,
      coverage: coverage ?? this.coverage,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      planStartDate: planStartDate ?? this.planStartDate,
      planEndDate: planEndDate ?? this.planEndDate,
      slotsJson: slotsJson ?? this.slotsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (coverage.present) {
      map['coverage'] = Variable<String>(coverage.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (planName.present) {
      map['plan_name'] = Variable<String>(planName.value);
    }
    if (planStartDate.present) {
      map['plan_start_date'] = Variable<DateTime>(planStartDate.value);
    }
    if (planEndDate.present) {
      map['plan_end_date'] = Variable<DateTime>(planEndDate.value);
    }
    if (slotsJson.present) {
      map['slots_json'] = Variable<String>(slotsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlanDaysCompanion(')
          ..write('date: $date, ')
          ..write('coverage: $coverage, ')
          ..write('planId: $planId, ')
          ..write('planName: $planName, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('planEndDate: $planEndDate, ')
          ..write('slotsJson: $slotsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalDietPlansTable localDietPlans = $LocalDietPlansTable(this);
  late final $LocalPlanDaysTable localPlanDays = $LocalPlanDaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localDietPlans,
    localPlanDays,
  ];
}

typedef $$LocalDietPlansTableCreateCompanionBuilder =
    LocalDietPlansCompanion Function({
      required String id,
      required String ownerId,
      required String authorId,
      required String authorRole,
      required String name,
      required String status,
      required DateTime startDate,
      Value<DateTime?> endDate,
      required String weeklyScheduleJson,
      Value<int> rowid,
    });
typedef $$LocalDietPlansTableUpdateCompanionBuilder =
    LocalDietPlansCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> authorId,
      Value<String> authorRole,
      Value<String> name,
      Value<String> status,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<String> weeklyScheduleJson,
      Value<int> rowid,
    });

class $$LocalDietPlansTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDietPlansTable> {
  $$LocalDietPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorRole => $composableBuilder(
    column: $table.authorRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weeklyScheduleJson => $composableBuilder(
    column: $table.weeklyScheduleJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDietPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDietPlansTable> {
  $$LocalDietPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorRole => $composableBuilder(
    column: $table.authorRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weeklyScheduleJson => $composableBuilder(
    column: $table.weeklyScheduleJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDietPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDietPlansTable> {
  $$LocalDietPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get authorRole => $composableBuilder(
    column: $table.authorRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get weeklyScheduleJson => $composableBuilder(
    column: $table.weeklyScheduleJson,
    builder: (column) => column,
  );
}

class $$LocalDietPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDietPlansTable,
          LocalDietPlan,
          $$LocalDietPlansTableFilterComposer,
          $$LocalDietPlansTableOrderingComposer,
          $$LocalDietPlansTableAnnotationComposer,
          $$LocalDietPlansTableCreateCompanionBuilder,
          $$LocalDietPlansTableUpdateCompanionBuilder,
          (
            LocalDietPlan,
            BaseReferences<_$AppDatabase, $LocalDietPlansTable, LocalDietPlan>,
          ),
          LocalDietPlan,
          PrefetchHooks Function()
        > {
  $$LocalDietPlansTableTableManager(
    _$AppDatabase db,
    $LocalDietPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDietPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDietPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDietPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> authorRole = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> weeklyScheduleJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDietPlansCompanion(
                id: id,
                ownerId: ownerId,
                authorId: authorId,
                authorRole: authorRole,
                name: name,
                status: status,
                startDate: startDate,
                endDate: endDate,
                weeklyScheduleJson: weeklyScheduleJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String authorId,
                required String authorRole,
                required String name,
                required String status,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                required String weeklyScheduleJson,
                Value<int> rowid = const Value.absent(),
              }) => LocalDietPlansCompanion.insert(
                id: id,
                ownerId: ownerId,
                authorId: authorId,
                authorRole: authorRole,
                name: name,
                status: status,
                startDate: startDate,
                endDate: endDate,
                weeklyScheduleJson: weeklyScheduleJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDietPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDietPlansTable,
      LocalDietPlan,
      $$LocalDietPlansTableFilterComposer,
      $$LocalDietPlansTableOrderingComposer,
      $$LocalDietPlansTableAnnotationComposer,
      $$LocalDietPlansTableCreateCompanionBuilder,
      $$LocalDietPlansTableUpdateCompanionBuilder,
      (
        LocalDietPlan,
        BaseReferences<_$AppDatabase, $LocalDietPlansTable, LocalDietPlan>,
      ),
      LocalDietPlan,
      PrefetchHooks Function()
    >;
typedef $$LocalPlanDaysTableCreateCompanionBuilder =
    LocalPlanDaysCompanion Function({
      required DateTime date,
      required String coverage,
      Value<String?> planId,
      Value<String?> planName,
      Value<DateTime?> planStartDate,
      Value<DateTime?> planEndDate,
      required String slotsJson,
      Value<int> rowid,
    });
typedef $$LocalPlanDaysTableUpdateCompanionBuilder =
    LocalPlanDaysCompanion Function({
      Value<DateTime> date,
      Value<String> coverage,
      Value<String?> planId,
      Value<String?> planName,
      Value<DateTime?> planStartDate,
      Value<DateTime?> planEndDate,
      Value<String> slotsJson,
      Value<int> rowid,
    });

class $$LocalPlanDaysTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPlanDaysTable> {
  $$LocalPlanDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverage => $composableBuilder(
    column: $table.coverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get planEndDate => $composableBuilder(
    column: $table.planEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slotsJson => $composableBuilder(
    column: $table.slotsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPlanDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPlanDaysTable> {
  $$LocalPlanDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverage => $composableBuilder(
    column: $table.coverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get planEndDate => $composableBuilder(
    column: $table.planEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slotsJson => $composableBuilder(
    column: $table.slotsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPlanDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPlanDaysTable> {
  $$LocalPlanDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get coverage =>
      $composableBuilder(column: $table.coverage, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get planName =>
      $composableBuilder(column: $table.planName, builder: (column) => column);

  GeneratedColumn<DateTime> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get planEndDate => $composableBuilder(
    column: $table.planEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get slotsJson =>
      $composableBuilder(column: $table.slotsJson, builder: (column) => column);
}

class $$LocalPlanDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPlanDaysTable,
          LocalPlanDay,
          $$LocalPlanDaysTableFilterComposer,
          $$LocalPlanDaysTableOrderingComposer,
          $$LocalPlanDaysTableAnnotationComposer,
          $$LocalPlanDaysTableCreateCompanionBuilder,
          $$LocalPlanDaysTableUpdateCompanionBuilder,
          (
            LocalPlanDay,
            BaseReferences<_$AppDatabase, $LocalPlanDaysTable, LocalPlanDay>,
          ),
          LocalPlanDay,
          PrefetchHooks Function()
        > {
  $$LocalPlanDaysTableTableManager(_$AppDatabase db, $LocalPlanDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPlanDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPlanDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPlanDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<String> coverage = const Value.absent(),
                Value<String?> planId = const Value.absent(),
                Value<String?> planName = const Value.absent(),
                Value<DateTime?> planStartDate = const Value.absent(),
                Value<DateTime?> planEndDate = const Value.absent(),
                Value<String> slotsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlanDaysCompanion(
                date: date,
                coverage: coverage,
                planId: planId,
                planName: planName,
                planStartDate: planStartDate,
                planEndDate: planEndDate,
                slotsJson: slotsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                required String coverage,
                Value<String?> planId = const Value.absent(),
                Value<String?> planName = const Value.absent(),
                Value<DateTime?> planStartDate = const Value.absent(),
                Value<DateTime?> planEndDate = const Value.absent(),
                required String slotsJson,
                Value<int> rowid = const Value.absent(),
              }) => LocalPlanDaysCompanion.insert(
                date: date,
                coverage: coverage,
                planId: planId,
                planName: planName,
                planStartDate: planStartDate,
                planEndDate: planEndDate,
                slotsJson: slotsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPlanDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPlanDaysTable,
      LocalPlanDay,
      $$LocalPlanDaysTableFilterComposer,
      $$LocalPlanDaysTableOrderingComposer,
      $$LocalPlanDaysTableAnnotationComposer,
      $$LocalPlanDaysTableCreateCompanionBuilder,
      $$LocalPlanDaysTableUpdateCompanionBuilder,
      (
        LocalPlanDay,
        BaseReferences<_$AppDatabase, $LocalPlanDaysTable, LocalPlanDay>,
      ),
      LocalPlanDay,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalDietPlansTableTableManager get localDietPlans =>
      $$LocalDietPlansTableTableManager(_db, _db.localDietPlans);
  $$LocalPlanDaysTableTableManager get localPlanDays =>
      $$LocalPlanDaysTableTableManager(_db, _db.localPlanDays);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'701eb6f8194035bca82bbb3e5c92992fe86a2ae3';
