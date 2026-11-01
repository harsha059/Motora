// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $IssuesTable extends Issues with TableInfo<$IssuesTable, Issue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mg_comet_ev'),
  );
  static const VerificationMeta _componentIdMeta = const VerificationMeta(
    'componentId',
  );
  @override
  late final GeneratedColumn<String> componentId = GeneratedColumn<String>(
    'component_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IssuePriority, int> priority =
      GeneratedColumn<int>(
        'priority',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<IssuePriority>($IssuesTable.$converterpriority);
  static const VerificationMeta _dateNoticedMeta = const VerificationMeta(
    'dateNoticed',
  );
  @override
  late final GeneratedColumn<DateTime> dateNoticed = GeneratedColumn<DateTime>(
    'date_noticed',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IssueFrequency, int> frequency =
      GeneratedColumn<int>(
        'frequency',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<IssueFrequency>($IssuesTable.$converterfrequency);
  static const VerificationMeta _photoUrlsJsonMeta = const VerificationMeta(
    'photoUrlsJson',
  );
  @override
  late final GeneratedColumn<String> photoUrlsJson = GeneratedColumn<String>(
    'photo_urls_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IssueStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<IssueStatus>($IssuesTable.$converterstatus);
  static const VerificationMeta _technicianRemarksMeta = const VerificationMeta(
    'technicianRemarks',
  );
  @override
  late final GeneratedColumn<String> technicianRemarks =
      GeneratedColumn<String>(
        'technician_remarks',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _resolutionNotesMeta = const VerificationMeta(
    'resolutionNotes',
  );
  @override
  late final GeneratedColumn<String> resolutionNotes = GeneratedColumn<String>(
    'resolution_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    componentId,
    title,
    description,
    priority,
    dateNoticed,
    frequency,
    photoUrlsJson,
    status,
    technicianRemarks,
    resolutionNotes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issues';
  @override
  VerificationContext validateIntegrity(
    Insertable<Issue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    }
    if (data.containsKey('component_id')) {
      context.handle(
        _componentIdMeta,
        componentId.isAcceptableOrUnknown(
          data['component_id']!,
          _componentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_componentIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('date_noticed')) {
      context.handle(
        _dateNoticedMeta,
        dateNoticed.isAcceptableOrUnknown(
          data['date_noticed']!,
          _dateNoticedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateNoticedMeta);
    }
    if (data.containsKey('photo_urls_json')) {
      context.handle(
        _photoUrlsJsonMeta,
        photoUrlsJson.isAcceptableOrUnknown(
          data['photo_urls_json']!,
          _photoUrlsJsonMeta,
        ),
      );
    }
    if (data.containsKey('technician_remarks')) {
      context.handle(
        _technicianRemarksMeta,
        technicianRemarks.isAcceptableOrUnknown(
          data['technician_remarks']!,
          _technicianRemarksMeta,
        ),
      );
    }
    if (data.containsKey('resolution_notes')) {
      context.handle(
        _resolutionNotesMeta,
        resolutionNotes.isAcceptableOrUnknown(
          data['resolution_notes']!,
          _resolutionNotesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Issue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Issue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      componentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      priority: $IssuesTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}priority'],
        )!,
      ),
      dateNoticed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_noticed'],
      )!,
      frequency: $IssuesTable.$converterfrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}frequency'],
        )!,
      ),
      photoUrlsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_urls_json'],
      ),
      status: $IssuesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      technicianRemarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technician_remarks'],
      ),
      resolutionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $IssuesTable createAlias(String alias) {
    return $IssuesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IssuePriority, int, int> $converterpriority =
      const EnumIndexConverter<IssuePriority>(IssuePriority.values);
  static JsonTypeConverter2<IssueFrequency, int, int> $converterfrequency =
      const EnumIndexConverter<IssueFrequency>(IssueFrequency.values);
  static JsonTypeConverter2<IssueStatus, int, int> $converterstatus =
      const EnumIndexConverter<IssueStatus>(IssueStatus.values);
}

class Issue extends DataClass implements Insertable<Issue> {
  final String id;
  final String vehicleId;
  final String componentId;
  final String title;
  final String description;
  final IssuePriority priority;
  final DateTime dateNoticed;
  final IssueFrequency frequency;
  final String? photoUrlsJson;
  final IssueStatus status;
  final String? technicianRemarks;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Issue({
    required this.id,
    required this.vehicleId,
    required this.componentId,
    required this.title,
    required this.description,
    required this.priority,
    required this.dateNoticed,
    required this.frequency,
    this.photoUrlsJson,
    required this.status,
    this.technicianRemarks,
    this.resolutionNotes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['component_id'] = Variable<String>(componentId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    {
      map['priority'] = Variable<int>(
        $IssuesTable.$converterpriority.toSql(priority),
      );
    }
    map['date_noticed'] = Variable<DateTime>(dateNoticed);
    {
      map['frequency'] = Variable<int>(
        $IssuesTable.$converterfrequency.toSql(frequency),
      );
    }
    if (!nullToAbsent || photoUrlsJson != null) {
      map['photo_urls_json'] = Variable<String>(photoUrlsJson);
    }
    {
      map['status'] = Variable<int>(
        $IssuesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || technicianRemarks != null) {
      map['technician_remarks'] = Variable<String>(technicianRemarks);
    }
    if (!nullToAbsent || resolutionNotes != null) {
      map['resolution_notes'] = Variable<String>(resolutionNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  IssuesCompanion toCompanion(bool nullToAbsent) {
    return IssuesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      componentId: Value(componentId),
      title: Value(title),
      description: Value(description),
      priority: Value(priority),
      dateNoticed: Value(dateNoticed),
      frequency: Value(frequency),
      photoUrlsJson: photoUrlsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrlsJson),
      status: Value(status),
      technicianRemarks: technicianRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(technicianRemarks),
      resolutionNotes: resolutionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionNotes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Issue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Issue(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      componentId: serializer.fromJson<String>(json['componentId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      priority: $IssuesTable.$converterpriority.fromJson(
        serializer.fromJson<int>(json['priority']),
      ),
      dateNoticed: serializer.fromJson<DateTime>(json['dateNoticed']),
      frequency: $IssuesTable.$converterfrequency.fromJson(
        serializer.fromJson<int>(json['frequency']),
      ),
      photoUrlsJson: serializer.fromJson<String?>(json['photoUrlsJson']),
      status: $IssuesTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      technicianRemarks: serializer.fromJson<String?>(
        json['technicianRemarks'],
      ),
      resolutionNotes: serializer.fromJson<String?>(json['resolutionNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'componentId': serializer.toJson<String>(componentId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'priority': serializer.toJson<int>(
        $IssuesTable.$converterpriority.toJson(priority),
      ),
      'dateNoticed': serializer.toJson<DateTime>(dateNoticed),
      'frequency': serializer.toJson<int>(
        $IssuesTable.$converterfrequency.toJson(frequency),
      ),
      'photoUrlsJson': serializer.toJson<String?>(photoUrlsJson),
      'status': serializer.toJson<int>(
        $IssuesTable.$converterstatus.toJson(status),
      ),
      'technicianRemarks': serializer.toJson<String?>(technicianRemarks),
      'resolutionNotes': serializer.toJson<String?>(resolutionNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Issue copyWith({
    String? id,
    String? vehicleId,
    String? componentId,
    String? title,
    String? description,
    IssuePriority? priority,
    DateTime? dateNoticed,
    IssueFrequency? frequency,
    Value<String?> photoUrlsJson = const Value.absent(),
    IssueStatus? status,
    Value<String?> technicianRemarks = const Value.absent(),
    Value<String?> resolutionNotes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Issue(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    componentId: componentId ?? this.componentId,
    title: title ?? this.title,
    description: description ?? this.description,
    priority: priority ?? this.priority,
    dateNoticed: dateNoticed ?? this.dateNoticed,
    frequency: frequency ?? this.frequency,
    photoUrlsJson: photoUrlsJson.present
        ? photoUrlsJson.value
        : this.photoUrlsJson,
    status: status ?? this.status,
    technicianRemarks: technicianRemarks.present
        ? technicianRemarks.value
        : this.technicianRemarks,
    resolutionNotes: resolutionNotes.present
        ? resolutionNotes.value
        : this.resolutionNotes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Issue copyWithCompanion(IssuesCompanion data) {
    return Issue(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      componentId: data.componentId.present
          ? data.componentId.value
          : this.componentId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      dateNoticed: data.dateNoticed.present
          ? data.dateNoticed.value
          : this.dateNoticed,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      photoUrlsJson: data.photoUrlsJson.present
          ? data.photoUrlsJson.value
          : this.photoUrlsJson,
      status: data.status.present ? data.status.value : this.status,
      technicianRemarks: data.technicianRemarks.present
          ? data.technicianRemarks.value
          : this.technicianRemarks,
      resolutionNotes: data.resolutionNotes.present
          ? data.resolutionNotes.value
          : this.resolutionNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Issue(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('componentId: $componentId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('dateNoticed: $dateNoticed, ')
          ..write('frequency: $frequency, ')
          ..write('photoUrlsJson: $photoUrlsJson, ')
          ..write('status: $status, ')
          ..write('technicianRemarks: $technicianRemarks, ')
          ..write('resolutionNotes: $resolutionNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    componentId,
    title,
    description,
    priority,
    dateNoticed,
    frequency,
    photoUrlsJson,
    status,
    technicianRemarks,
    resolutionNotes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Issue &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.componentId == this.componentId &&
          other.title == this.title &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.dateNoticed == this.dateNoticed &&
          other.frequency == this.frequency &&
          other.photoUrlsJson == this.photoUrlsJson &&
          other.status == this.status &&
          other.technicianRemarks == this.technicianRemarks &&
          other.resolutionNotes == this.resolutionNotes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class IssuesCompanion extends UpdateCompanion<Issue> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> componentId;
  final Value<String> title;
  final Value<String> description;
  final Value<IssuePriority> priority;
  final Value<DateTime> dateNoticed;
  final Value<IssueFrequency> frequency;
  final Value<String?> photoUrlsJson;
  final Value<IssueStatus> status;
  final Value<String?> technicianRemarks;
  final Value<String?> resolutionNotes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const IssuesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.componentId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.dateNoticed = const Value.absent(),
    this.frequency = const Value.absent(),
    this.photoUrlsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.technicianRemarks = const Value.absent(),
    this.resolutionNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssuesCompanion.insert({
    required String id,
    this.vehicleId = const Value.absent(),
    required String componentId,
    required String title,
    required String description,
    required IssuePriority priority,
    required DateTime dateNoticed,
    required IssueFrequency frequency,
    this.photoUrlsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.technicianRemarks = const Value.absent(),
    this.resolutionNotes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       componentId = Value(componentId),
       title = Value(title),
       description = Value(description),
       priority = Value(priority),
       dateNoticed = Value(dateNoticed),
       frequency = Value(frequency),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Issue> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? componentId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? priority,
    Expression<DateTime>? dateNoticed,
    Expression<int>? frequency,
    Expression<String>? photoUrlsJson,
    Expression<int>? status,
    Expression<String>? technicianRemarks,
    Expression<String>? resolutionNotes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (componentId != null) 'component_id': componentId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (dateNoticed != null) 'date_noticed': dateNoticed,
      if (frequency != null) 'frequency': frequency,
      if (photoUrlsJson != null) 'photo_urls_json': photoUrlsJson,
      if (status != null) 'status': status,
      if (technicianRemarks != null) 'technician_remarks': technicianRemarks,
      if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssuesCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? componentId,
    Value<String>? title,
    Value<String>? description,
    Value<IssuePriority>? priority,
    Value<DateTime>? dateNoticed,
    Value<IssueFrequency>? frequency,
    Value<String?>? photoUrlsJson,
    Value<IssueStatus>? status,
    Value<String?>? technicianRemarks,
    Value<String?>? resolutionNotes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return IssuesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      componentId: componentId ?? this.componentId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dateNoticed: dateNoticed ?? this.dateNoticed,
      frequency: frequency ?? this.frequency,
      photoUrlsJson: photoUrlsJson ?? this.photoUrlsJson,
      status: status ?? this.status,
      technicianRemarks: technicianRemarks ?? this.technicianRemarks,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (componentId.present) {
      map['component_id'] = Variable<String>(componentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(
        $IssuesTable.$converterpriority.toSql(priority.value),
      );
    }
    if (dateNoticed.present) {
      map['date_noticed'] = Variable<DateTime>(dateNoticed.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(
        $IssuesTable.$converterfrequency.toSql(frequency.value),
      );
    }
    if (photoUrlsJson.present) {
      map['photo_urls_json'] = Variable<String>(photoUrlsJson.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $IssuesTable.$converterstatus.toSql(status.value),
      );
    }
    if (technicianRemarks.present) {
      map['technician_remarks'] = Variable<String>(technicianRemarks.value);
    }
    if (resolutionNotes.present) {
      map['resolution_notes'] = Variable<String>(resolutionNotes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssuesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('componentId: $componentId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('dateNoticed: $dateNoticed, ')
          ..write('frequency: $frequency, ')
          ..write('photoUrlsJson: $photoUrlsJson, ')
          ..write('status: $status, ')
          ..write('technicianRemarks: $technicianRemarks, ')
          ..write('resolutionNotes: $resolutionNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IssuesTable issues = $IssuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [issues];
}

typedef $$IssuesTableCreateCompanionBuilder =
    IssuesCompanion Function({
      required String id,
      Value<String> vehicleId,
      required String componentId,
      required String title,
      required String description,
      required IssuePriority priority,
      required DateTime dateNoticed,
      required IssueFrequency frequency,
      Value<String?> photoUrlsJson,
      Value<IssueStatus> status,
      Value<String?> technicianRemarks,
      Value<String?> resolutionNotes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$IssuesTableUpdateCompanionBuilder =
    IssuesCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> componentId,
      Value<String> title,
      Value<String> description,
      Value<IssuePriority> priority,
      Value<DateTime> dateNoticed,
      Value<IssueFrequency> frequency,
      Value<String?> photoUrlsJson,
      Value<IssueStatus> status,
      Value<String?> technicianRemarks,
      Value<String?> resolutionNotes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$IssuesTableFilterComposer
    extends Composer<_$AppDatabase, $IssuesTable> {
  $$IssuesTableFilterComposer({
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

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get componentId => $composableBuilder(
    column: $table.componentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IssuePriority, IssuePriority, int>
  get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dateNoticed => $composableBuilder(
    column: $table.dateNoticed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IssueFrequency, IssueFrequency, int>
  get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get photoUrlsJson => $composableBuilder(
    column: $table.photoUrlsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IssueStatus, IssueStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get technicianRemarks => $composableBuilder(
    column: $table.technicianRemarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionNotes => $composableBuilder(
    column: $table.resolutionNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssuesTableOrderingComposer
    extends Composer<_$AppDatabase, $IssuesTable> {
  $$IssuesTableOrderingComposer({
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

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get componentId => $composableBuilder(
    column: $table.componentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateNoticed => $composableBuilder(
    column: $table.dateNoticed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrlsJson => $composableBuilder(
    column: $table.photoUrlsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get technicianRemarks => $composableBuilder(
    column: $table.technicianRemarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionNotes => $composableBuilder(
    column: $table.resolutionNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssuesTable> {
  $$IssuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get componentId => $composableBuilder(
    column: $table.componentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<IssuePriority, int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get dateNoticed => $composableBuilder(
    column: $table.dateNoticed,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<IssueFrequency, int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get photoUrlsJson => $composableBuilder(
    column: $table.photoUrlsJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<IssueStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get technicianRemarks => $composableBuilder(
    column: $table.technicianRemarks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolutionNotes => $composableBuilder(
    column: $table.resolutionNotes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$IssuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssuesTable,
          Issue,
          $$IssuesTableFilterComposer,
          $$IssuesTableOrderingComposer,
          $$IssuesTableAnnotationComposer,
          $$IssuesTableCreateCompanionBuilder,
          $$IssuesTableUpdateCompanionBuilder,
          (Issue, BaseReferences<_$AppDatabase, $IssuesTable, Issue>),
          Issue,
          PrefetchHooks Function()
        > {
  $$IssuesTableTableManager(_$AppDatabase db, $IssuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> componentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<IssuePriority> priority = const Value.absent(),
                Value<DateTime> dateNoticed = const Value.absent(),
                Value<IssueFrequency> frequency = const Value.absent(),
                Value<String?> photoUrlsJson = const Value.absent(),
                Value<IssueStatus> status = const Value.absent(),
                Value<String?> technicianRemarks = const Value.absent(),
                Value<String?> resolutionNotes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssuesCompanion(
                id: id,
                vehicleId: vehicleId,
                componentId: componentId,
                title: title,
                description: description,
                priority: priority,
                dateNoticed: dateNoticed,
                frequency: frequency,
                photoUrlsJson: photoUrlsJson,
                status: status,
                technicianRemarks: technicianRemarks,
                resolutionNotes: resolutionNotes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> vehicleId = const Value.absent(),
                required String componentId,
                required String title,
                required String description,
                required IssuePriority priority,
                required DateTime dateNoticed,
                required IssueFrequency frequency,
                Value<String?> photoUrlsJson = const Value.absent(),
                Value<IssueStatus> status = const Value.absent(),
                Value<String?> technicianRemarks = const Value.absent(),
                Value<String?> resolutionNotes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => IssuesCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                componentId: componentId,
                title: title,
                description: description,
                priority: priority,
                dateNoticed: dateNoticed,
                frequency: frequency,
                photoUrlsJson: photoUrlsJson,
                status: status,
                technicianRemarks: technicianRemarks,
                resolutionNotes: resolutionNotes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IssuesTable, Issue>(table),
                  BaseReferences<_$AppDatabase, $IssuesTable, Issue>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssuesTable,
      Issue,
      $$IssuesTableFilterComposer,
      $$IssuesTableOrderingComposer,
      $$IssuesTableAnnotationComposer,
      $$IssuesTableCreateCompanionBuilder,
      $$IssuesTableUpdateCompanionBuilder,
      (Issue, BaseReferences<_$AppDatabase, $IssuesTable, Issue>),
      Issue,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IssuesTableTableManager get issues =>
      $$IssuesTableTableManager(_db, _db.issues);
}
