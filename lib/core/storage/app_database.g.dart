// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
  late final $LocalPlanDaysTable localPlanDays = $LocalPlanDaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localPlanDays];
}

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
