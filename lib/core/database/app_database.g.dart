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
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _parentIssueIdMeta = const VerificationMeta(
    'parentIssueId',
  );
  @override
  late final GeneratedColumn<String> parentIssueId = GeneratedColumn<String>(
    'parent_issue_id',
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
    isRecurring,
    parentIssueId,
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
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('parent_issue_id')) {
      context.handle(
        _parentIssueIdMeta,
        parentIssueId.isAcceptableOrUnknown(
          data['parent_issue_id']!,
          _parentIssueIdMeta,
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
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      parentIssueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_issue_id'],
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
  final bool isRecurring;
  final String? parentIssueId;
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
    required this.isRecurring,
    this.parentIssueId,
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
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || parentIssueId != null) {
      map['parent_issue_id'] = Variable<String>(parentIssueId);
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
      isRecurring: Value(isRecurring),
      parentIssueId: parentIssueId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentIssueId),
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
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      parentIssueId: serializer.fromJson<String?>(json['parentIssueId']),
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
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'parentIssueId': serializer.toJson<String?>(parentIssueId),
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
    bool? isRecurring,
    Value<String?> parentIssueId = const Value.absent(),
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
    isRecurring: isRecurring ?? this.isRecurring,
    parentIssueId: parentIssueId.present
        ? parentIssueId.value
        : this.parentIssueId,
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
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      parentIssueId: data.parentIssueId.present
          ? data.parentIssueId.value
          : this.parentIssueId,
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
          ..write('isRecurring: $isRecurring, ')
          ..write('parentIssueId: $parentIssueId, ')
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
    isRecurring,
    parentIssueId,
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
          other.isRecurring == this.isRecurring &&
          other.parentIssueId == this.parentIssueId &&
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
  final Value<bool> isRecurring;
  final Value<String?> parentIssueId;
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
    this.isRecurring = const Value.absent(),
    this.parentIssueId = const Value.absent(),
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
    this.isRecurring = const Value.absent(),
    this.parentIssueId = const Value.absent(),
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
    Expression<bool>? isRecurring,
    Expression<String>? parentIssueId,
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
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (parentIssueId != null) 'parent_issue_id': parentIssueId,
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
    Value<bool>? isRecurring,
    Value<String?>? parentIssueId,
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
      isRecurring: isRecurring ?? this.isRecurring,
      parentIssueId: parentIssueId ?? this.parentIssueId,
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
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (parentIssueId.present) {
      map['parent_issue_id'] = Variable<String>(parentIssueId.value);
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
          ..write('isRecurring: $isRecurring, ')
          ..write('parentIssueId: $parentIssueId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceVisitsTable extends ServiceVisits
    with TableInfo<$ServiceVisitsTable, ServiceVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceVisitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serviceCentreMeta = const VerificationMeta(
    'serviceCentre',
  );
  @override
  late final GeneratedColumn<String> serviceCentre = GeneratedColumn<String>(
    'service_centre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitDateMeta = const VerificationMeta(
    'visitDate',
  );
  @override
  late final GeneratedColumn<DateTime> visitDate = GeneratedColumn<DateTime>(
    'visit_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerReadingMeta = const VerificationMeta(
    'odometerReading',
  );
  @override
  late final GeneratedColumn<int> odometerReading = GeneratedColumn<int>(
    'odometer_reading',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ServiceVisitStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      ).withConverter<ServiceVisitStatus>($ServiceVisitsTable.$converterstatus);
  static const VerificationMeta _additionalRequestsMeta =
      const VerificationMeta('additionalRequests');
  @override
  late final GeneratedColumn<String> additionalRequests =
      GeneratedColumn<String>(
        'additional_requests',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _technicianNameMeta = const VerificationMeta(
    'technicianName',
  );
  @override
  late final GeneratedColumn<String> technicianName = GeneratedColumn<String>(
    'technician_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signOffDetailsMeta = const VerificationMeta(
    'signOffDetails',
  );
  @override
  late final GeneratedColumn<String> signOffDetails = GeneratedColumn<String>(
    'sign_off_details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
    'total_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    serviceCentre,
    visitDate,
    odometerReading,
    status,
    additionalRequests,
    technicianName,
    signOffDetails,
    totalCost,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceVisit> instance, {
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
    if (data.containsKey('service_centre')) {
      context.handle(
        _serviceCentreMeta,
        serviceCentre.isAcceptableOrUnknown(
          data['service_centre']!,
          _serviceCentreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceCentreMeta);
    }
    if (data.containsKey('visit_date')) {
      context.handle(
        _visitDateMeta,
        visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta),
      );
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('odometer_reading')) {
      context.handle(
        _odometerReadingMeta,
        odometerReading.isAcceptableOrUnknown(
          data['odometer_reading']!,
          _odometerReadingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_odometerReadingMeta);
    }
    if (data.containsKey('additional_requests')) {
      context.handle(
        _additionalRequestsMeta,
        additionalRequests.isAcceptableOrUnknown(
          data['additional_requests']!,
          _additionalRequestsMeta,
        ),
      );
    }
    if (data.containsKey('technician_name')) {
      context.handle(
        _technicianNameMeta,
        technicianName.isAcceptableOrUnknown(
          data['technician_name']!,
          _technicianNameMeta,
        ),
      );
    }
    if (data.containsKey('sign_off_details')) {
      context.handle(
        _signOffDetailsMeta,
        signOffDetails.isAcceptableOrUnknown(
          data['sign_off_details']!,
          _signOffDetailsMeta,
        ),
      );
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
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
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceVisit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      serviceCentre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_centre'],
      )!,
      visitDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visit_date'],
      )!,
      odometerReading: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_reading'],
      )!,
      status: $ServiceVisitsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      additionalRequests: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}additional_requests'],
      ),
      technicianName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technician_name'],
      ),
      signOffDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sign_off_details'],
      ),
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cost'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ServiceVisitsTable createAlias(String alias) {
    return $ServiceVisitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ServiceVisitStatus, int, int> $converterstatus =
      const EnumIndexConverter<ServiceVisitStatus>(ServiceVisitStatus.values);
}

class ServiceVisit extends DataClass implements Insertable<ServiceVisit> {
  final String id;
  final String vehicleId;
  final String serviceCentre;
  final DateTime visitDate;
  final int odometerReading;
  final ServiceVisitStatus status;
  final String? additionalRequests;
  final String? technicianName;
  final String? signOffDetails;
  final double? totalCost;
  final DateTime createdAt;
  final DateTime? completedAt;
  const ServiceVisit({
    required this.id,
    required this.vehicleId,
    required this.serviceCentre,
    required this.visitDate,
    required this.odometerReading,
    required this.status,
    this.additionalRequests,
    this.technicianName,
    this.signOffDetails,
    this.totalCost,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['service_centre'] = Variable<String>(serviceCentre);
    map['visit_date'] = Variable<DateTime>(visitDate);
    map['odometer_reading'] = Variable<int>(odometerReading);
    {
      map['status'] = Variable<int>(
        $ServiceVisitsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || additionalRequests != null) {
      map['additional_requests'] = Variable<String>(additionalRequests);
    }
    if (!nullToAbsent || technicianName != null) {
      map['technician_name'] = Variable<String>(technicianName);
    }
    if (!nullToAbsent || signOffDetails != null) {
      map['sign_off_details'] = Variable<String>(signOffDetails);
    }
    if (!nullToAbsent || totalCost != null) {
      map['total_cost'] = Variable<double>(totalCost);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ServiceVisitsCompanion toCompanion(bool nullToAbsent) {
    return ServiceVisitsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      serviceCentre: Value(serviceCentre),
      visitDate: Value(visitDate),
      odometerReading: Value(odometerReading),
      status: Value(status),
      additionalRequests: additionalRequests == null && nullToAbsent
          ? const Value.absent()
          : Value(additionalRequests),
      technicianName: technicianName == null && nullToAbsent
          ? const Value.absent()
          : Value(technicianName),
      signOffDetails: signOffDetails == null && nullToAbsent
          ? const Value.absent()
          : Value(signOffDetails),
      totalCost: totalCost == null && nullToAbsent
          ? const Value.absent()
          : Value(totalCost),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ServiceVisit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceVisit(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      serviceCentre: serializer.fromJson<String>(json['serviceCentre']),
      visitDate: serializer.fromJson<DateTime>(json['visitDate']),
      odometerReading: serializer.fromJson<int>(json['odometerReading']),
      status: $ServiceVisitsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      additionalRequests: serializer.fromJson<String?>(
        json['additionalRequests'],
      ),
      technicianName: serializer.fromJson<String?>(json['technicianName']),
      signOffDetails: serializer.fromJson<String?>(json['signOffDetails']),
      totalCost: serializer.fromJson<double?>(json['totalCost']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'serviceCentre': serializer.toJson<String>(serviceCentre),
      'visitDate': serializer.toJson<DateTime>(visitDate),
      'odometerReading': serializer.toJson<int>(odometerReading),
      'status': serializer.toJson<int>(
        $ServiceVisitsTable.$converterstatus.toJson(status),
      ),
      'additionalRequests': serializer.toJson<String?>(additionalRequests),
      'technicianName': serializer.toJson<String?>(technicianName),
      'signOffDetails': serializer.toJson<String?>(signOffDetails),
      'totalCost': serializer.toJson<double?>(totalCost),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ServiceVisit copyWith({
    String? id,
    String? vehicleId,
    String? serviceCentre,
    DateTime? visitDate,
    int? odometerReading,
    ServiceVisitStatus? status,
    Value<String?> additionalRequests = const Value.absent(),
    Value<String?> technicianName = const Value.absent(),
    Value<String?> signOffDetails = const Value.absent(),
    Value<double?> totalCost = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ServiceVisit(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    serviceCentre: serviceCentre ?? this.serviceCentre,
    visitDate: visitDate ?? this.visitDate,
    odometerReading: odometerReading ?? this.odometerReading,
    status: status ?? this.status,
    additionalRequests: additionalRequests.present
        ? additionalRequests.value
        : this.additionalRequests,
    technicianName: technicianName.present
        ? technicianName.value
        : this.technicianName,
    signOffDetails: signOffDetails.present
        ? signOffDetails.value
        : this.signOffDetails,
    totalCost: totalCost.present ? totalCost.value : this.totalCost,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ServiceVisit copyWithCompanion(ServiceVisitsCompanion data) {
    return ServiceVisit(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      serviceCentre: data.serviceCentre.present
          ? data.serviceCentre.value
          : this.serviceCentre,
      visitDate: data.visitDate.present ? data.visitDate.value : this.visitDate,
      odometerReading: data.odometerReading.present
          ? data.odometerReading.value
          : this.odometerReading,
      status: data.status.present ? data.status.value : this.status,
      additionalRequests: data.additionalRequests.present
          ? data.additionalRequests.value
          : this.additionalRequests,
      technicianName: data.technicianName.present
          ? data.technicianName.value
          : this.technicianName,
      signOffDetails: data.signOffDetails.present
          ? data.signOffDetails.value
          : this.signOffDetails,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceVisit(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('serviceCentre: $serviceCentre, ')
          ..write('visitDate: $visitDate, ')
          ..write('odometerReading: $odometerReading, ')
          ..write('status: $status, ')
          ..write('additionalRequests: $additionalRequests, ')
          ..write('technicianName: $technicianName, ')
          ..write('signOffDetails: $signOffDetails, ')
          ..write('totalCost: $totalCost, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    serviceCentre,
    visitDate,
    odometerReading,
    status,
    additionalRequests,
    technicianName,
    signOffDetails,
    totalCost,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceVisit &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.serviceCentre == this.serviceCentre &&
          other.visitDate == this.visitDate &&
          other.odometerReading == this.odometerReading &&
          other.status == this.status &&
          other.additionalRequests == this.additionalRequests &&
          other.technicianName == this.technicianName &&
          other.signOffDetails == this.signOffDetails &&
          other.totalCost == this.totalCost &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class ServiceVisitsCompanion extends UpdateCompanion<ServiceVisit> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> serviceCentre;
  final Value<DateTime> visitDate;
  final Value<int> odometerReading;
  final Value<ServiceVisitStatus> status;
  final Value<String?> additionalRequests;
  final Value<String?> technicianName;
  final Value<String?> signOffDetails;
  final Value<double?> totalCost;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ServiceVisitsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.serviceCentre = const Value.absent(),
    this.visitDate = const Value.absent(),
    this.odometerReading = const Value.absent(),
    this.status = const Value.absent(),
    this.additionalRequests = const Value.absent(),
    this.technicianName = const Value.absent(),
    this.signOffDetails = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceVisitsCompanion.insert({
    required String id,
    this.vehicleId = const Value.absent(),
    required String serviceCentre,
    required DateTime visitDate,
    required int odometerReading,
    this.status = const Value.absent(),
    this.additionalRequests = const Value.absent(),
    this.technicianName = const Value.absent(),
    this.signOffDetails = const Value.absent(),
    this.totalCost = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serviceCentre = Value(serviceCentre),
       visitDate = Value(visitDate),
       odometerReading = Value(odometerReading),
       createdAt = Value(createdAt);
  static Insertable<ServiceVisit> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? serviceCentre,
    Expression<DateTime>? visitDate,
    Expression<int>? odometerReading,
    Expression<int>? status,
    Expression<String>? additionalRequests,
    Expression<String>? technicianName,
    Expression<String>? signOffDetails,
    Expression<double>? totalCost,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (serviceCentre != null) 'service_centre': serviceCentre,
      if (visitDate != null) 'visit_date': visitDate,
      if (odometerReading != null) 'odometer_reading': odometerReading,
      if (status != null) 'status': status,
      if (additionalRequests != null) 'additional_requests': additionalRequests,
      if (technicianName != null) 'technician_name': technicianName,
      if (signOffDetails != null) 'sign_off_details': signOffDetails,
      if (totalCost != null) 'total_cost': totalCost,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceVisitsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? serviceCentre,
    Value<DateTime>? visitDate,
    Value<int>? odometerReading,
    Value<ServiceVisitStatus>? status,
    Value<String?>? additionalRequests,
    Value<String?>? technicianName,
    Value<String?>? signOffDetails,
    Value<double?>? totalCost,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return ServiceVisitsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceCentre: serviceCentre ?? this.serviceCentre,
      visitDate: visitDate ?? this.visitDate,
      odometerReading: odometerReading ?? this.odometerReading,
      status: status ?? this.status,
      additionalRequests: additionalRequests ?? this.additionalRequests,
      technicianName: technicianName ?? this.technicianName,
      signOffDetails: signOffDetails ?? this.signOffDetails,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
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
    if (serviceCentre.present) {
      map['service_centre'] = Variable<String>(serviceCentre.value);
    }
    if (visitDate.present) {
      map['visit_date'] = Variable<DateTime>(visitDate.value);
    }
    if (odometerReading.present) {
      map['odometer_reading'] = Variable<int>(odometerReading.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $ServiceVisitsTable.$converterstatus.toSql(status.value),
      );
    }
    if (additionalRequests.present) {
      map['additional_requests'] = Variable<String>(additionalRequests.value);
    }
    if (technicianName.present) {
      map['technician_name'] = Variable<String>(technicianName.value);
    }
    if (signOffDetails.present) {
      map['sign_off_details'] = Variable<String>(signOffDetails.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceVisitsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('serviceCentre: $serviceCentre, ')
          ..write('visitDate: $visitDate, ')
          ..write('odometerReading: $odometerReading, ')
          ..write('status: $status, ')
          ..write('additionalRequests: $additionalRequests, ')
          ..write('technicianName: $technicianName, ')
          ..write('signOffDetails: $signOffDetails, ')
          ..write('totalCost: $totalCost, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceVisitIssuesTable extends ServiceVisitIssues
    with TableInfo<$ServiceVisitIssuesTable, ServiceVisitIssue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceVisitIssuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceVisitIdMeta = const VerificationMeta(
    'serviceVisitId',
  );
  @override
  late final GeneratedColumn<String> serviceVisitId = GeneratedColumn<String>(
    'service_visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<String> issueId = GeneratedColumn<String>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _workPerformedMeta = const VerificationMeta(
    'workPerformed',
  );
  @override
  late final GeneratedColumn<String> workPerformed = GeneratedColumn<String>(
    'work_performed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partsReplacedMeta = const VerificationMeta(
    'partsReplaced',
  );
  @override
  late final GeneratedColumn<String> partsReplaced = GeneratedColumn<String>(
    'parts_replaced',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<VisitIssueResolution, int>
  resolutionStatus =
      GeneratedColumn<int>(
        'resolution_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(2),
      ).withConverter<VisitIssueResolution>(
        $ServiceVisitIssuesTable.$converterresolutionStatus,
      );
  static const VerificationMeta _followUpRequiredMeta = const VerificationMeta(
    'followUpRequired',
  );
  @override
  late final GeneratedColumn<bool> followUpRequired = GeneratedColumn<bool>(
    'follow_up_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("follow_up_required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serviceVisitId,
    issueId,
    technicianRemarks,
    workPerformed,
    partsReplaced,
    resolutionStatus,
    followUpRequired,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_visit_issues';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceVisitIssue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('service_visit_id')) {
      context.handle(
        _serviceVisitIdMeta,
        serviceVisitId.isAcceptableOrUnknown(
          data['service_visit_id']!,
          _serviceVisitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceVisitIdMeta);
    }
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
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
    if (data.containsKey('work_performed')) {
      context.handle(
        _workPerformedMeta,
        workPerformed.isAcceptableOrUnknown(
          data['work_performed']!,
          _workPerformedMeta,
        ),
      );
    }
    if (data.containsKey('parts_replaced')) {
      context.handle(
        _partsReplacedMeta,
        partsReplaced.isAcceptableOrUnknown(
          data['parts_replaced']!,
          _partsReplacedMeta,
        ),
      );
    }
    if (data.containsKey('follow_up_required')) {
      context.handle(
        _followUpRequiredMeta,
        followUpRequired.isAcceptableOrUnknown(
          data['follow_up_required']!,
          _followUpRequiredMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceVisitIssue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceVisitIssue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serviceVisitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_visit_id'],
      )!,
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_id'],
      )!,
      technicianRemarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technician_remarks'],
      ),
      workPerformed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_performed'],
      ),
      partsReplaced: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parts_replaced'],
      ),
      resolutionStatus: $ServiceVisitIssuesTable.$converterresolutionStatus
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}resolution_status'],
            )!,
          ),
      followUpRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}follow_up_required'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ServiceVisitIssuesTable createAlias(String alias) {
    return $ServiceVisitIssuesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<VisitIssueResolution, int, int>
  $converterresolutionStatus = const EnumIndexConverter<VisitIssueResolution>(
    VisitIssueResolution.values,
  );
}

class ServiceVisitIssue extends DataClass
    implements Insertable<ServiceVisitIssue> {
  final String id;
  final String serviceVisitId;
  final String issueId;
  final String? technicianRemarks;
  final String? workPerformed;
  final String? partsReplaced;
  final VisitIssueResolution resolutionStatus;
  final bool followUpRequired;
  final DateTime createdAt;
  const ServiceVisitIssue({
    required this.id,
    required this.serviceVisitId,
    required this.issueId,
    this.technicianRemarks,
    this.workPerformed,
    this.partsReplaced,
    required this.resolutionStatus,
    required this.followUpRequired,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['service_visit_id'] = Variable<String>(serviceVisitId);
    map['issue_id'] = Variable<String>(issueId);
    if (!nullToAbsent || technicianRemarks != null) {
      map['technician_remarks'] = Variable<String>(technicianRemarks);
    }
    if (!nullToAbsent || workPerformed != null) {
      map['work_performed'] = Variable<String>(workPerformed);
    }
    if (!nullToAbsent || partsReplaced != null) {
      map['parts_replaced'] = Variable<String>(partsReplaced);
    }
    {
      map['resolution_status'] = Variable<int>(
        $ServiceVisitIssuesTable.$converterresolutionStatus.toSql(
          resolutionStatus,
        ),
      );
    }
    map['follow_up_required'] = Variable<bool>(followUpRequired);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ServiceVisitIssuesCompanion toCompanion(bool nullToAbsent) {
    return ServiceVisitIssuesCompanion(
      id: Value(id),
      serviceVisitId: Value(serviceVisitId),
      issueId: Value(issueId),
      technicianRemarks: technicianRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(technicianRemarks),
      workPerformed: workPerformed == null && nullToAbsent
          ? const Value.absent()
          : Value(workPerformed),
      partsReplaced: partsReplaced == null && nullToAbsent
          ? const Value.absent()
          : Value(partsReplaced),
      resolutionStatus: Value(resolutionStatus),
      followUpRequired: Value(followUpRequired),
      createdAt: Value(createdAt),
    );
  }

  factory ServiceVisitIssue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceVisitIssue(
      id: serializer.fromJson<String>(json['id']),
      serviceVisitId: serializer.fromJson<String>(json['serviceVisitId']),
      issueId: serializer.fromJson<String>(json['issueId']),
      technicianRemarks: serializer.fromJson<String?>(
        json['technicianRemarks'],
      ),
      workPerformed: serializer.fromJson<String?>(json['workPerformed']),
      partsReplaced: serializer.fromJson<String?>(json['partsReplaced']),
      resolutionStatus: $ServiceVisitIssuesTable.$converterresolutionStatus
          .fromJson(serializer.fromJson<int>(json['resolutionStatus'])),
      followUpRequired: serializer.fromJson<bool>(json['followUpRequired']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serviceVisitId': serializer.toJson<String>(serviceVisitId),
      'issueId': serializer.toJson<String>(issueId),
      'technicianRemarks': serializer.toJson<String?>(technicianRemarks),
      'workPerformed': serializer.toJson<String?>(workPerformed),
      'partsReplaced': serializer.toJson<String?>(partsReplaced),
      'resolutionStatus': serializer.toJson<int>(
        $ServiceVisitIssuesTable.$converterresolutionStatus.toJson(
          resolutionStatus,
        ),
      ),
      'followUpRequired': serializer.toJson<bool>(followUpRequired),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ServiceVisitIssue copyWith({
    String? id,
    String? serviceVisitId,
    String? issueId,
    Value<String?> technicianRemarks = const Value.absent(),
    Value<String?> workPerformed = const Value.absent(),
    Value<String?> partsReplaced = const Value.absent(),
    VisitIssueResolution? resolutionStatus,
    bool? followUpRequired,
    DateTime? createdAt,
  }) => ServiceVisitIssue(
    id: id ?? this.id,
    serviceVisitId: serviceVisitId ?? this.serviceVisitId,
    issueId: issueId ?? this.issueId,
    technicianRemarks: technicianRemarks.present
        ? technicianRemarks.value
        : this.technicianRemarks,
    workPerformed: workPerformed.present
        ? workPerformed.value
        : this.workPerformed,
    partsReplaced: partsReplaced.present
        ? partsReplaced.value
        : this.partsReplaced,
    resolutionStatus: resolutionStatus ?? this.resolutionStatus,
    followUpRequired: followUpRequired ?? this.followUpRequired,
    createdAt: createdAt ?? this.createdAt,
  );
  ServiceVisitIssue copyWithCompanion(ServiceVisitIssuesCompanion data) {
    return ServiceVisitIssue(
      id: data.id.present ? data.id.value : this.id,
      serviceVisitId: data.serviceVisitId.present
          ? data.serviceVisitId.value
          : this.serviceVisitId,
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      technicianRemarks: data.technicianRemarks.present
          ? data.technicianRemarks.value
          : this.technicianRemarks,
      workPerformed: data.workPerformed.present
          ? data.workPerformed.value
          : this.workPerformed,
      partsReplaced: data.partsReplaced.present
          ? data.partsReplaced.value
          : this.partsReplaced,
      resolutionStatus: data.resolutionStatus.present
          ? data.resolutionStatus.value
          : this.resolutionStatus,
      followUpRequired: data.followUpRequired.present
          ? data.followUpRequired.value
          : this.followUpRequired,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceVisitIssue(')
          ..write('id: $id, ')
          ..write('serviceVisitId: $serviceVisitId, ')
          ..write('issueId: $issueId, ')
          ..write('technicianRemarks: $technicianRemarks, ')
          ..write('workPerformed: $workPerformed, ')
          ..write('partsReplaced: $partsReplaced, ')
          ..write('resolutionStatus: $resolutionStatus, ')
          ..write('followUpRequired: $followUpRequired, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serviceVisitId,
    issueId,
    technicianRemarks,
    workPerformed,
    partsReplaced,
    resolutionStatus,
    followUpRequired,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceVisitIssue &&
          other.id == this.id &&
          other.serviceVisitId == this.serviceVisitId &&
          other.issueId == this.issueId &&
          other.technicianRemarks == this.technicianRemarks &&
          other.workPerformed == this.workPerformed &&
          other.partsReplaced == this.partsReplaced &&
          other.resolutionStatus == this.resolutionStatus &&
          other.followUpRequired == this.followUpRequired &&
          other.createdAt == this.createdAt);
}

class ServiceVisitIssuesCompanion extends UpdateCompanion<ServiceVisitIssue> {
  final Value<String> id;
  final Value<String> serviceVisitId;
  final Value<String> issueId;
  final Value<String?> technicianRemarks;
  final Value<String?> workPerformed;
  final Value<String?> partsReplaced;
  final Value<VisitIssueResolution> resolutionStatus;
  final Value<bool> followUpRequired;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ServiceVisitIssuesCompanion({
    this.id = const Value.absent(),
    this.serviceVisitId = const Value.absent(),
    this.issueId = const Value.absent(),
    this.technicianRemarks = const Value.absent(),
    this.workPerformed = const Value.absent(),
    this.partsReplaced = const Value.absent(),
    this.resolutionStatus = const Value.absent(),
    this.followUpRequired = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceVisitIssuesCompanion.insert({
    required String id,
    required String serviceVisitId,
    required String issueId,
    this.technicianRemarks = const Value.absent(),
    this.workPerformed = const Value.absent(),
    this.partsReplaced = const Value.absent(),
    this.resolutionStatus = const Value.absent(),
    this.followUpRequired = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serviceVisitId = Value(serviceVisitId),
       issueId = Value(issueId),
       createdAt = Value(createdAt);
  static Insertable<ServiceVisitIssue> custom({
    Expression<String>? id,
    Expression<String>? serviceVisitId,
    Expression<String>? issueId,
    Expression<String>? technicianRemarks,
    Expression<String>? workPerformed,
    Expression<String>? partsReplaced,
    Expression<int>? resolutionStatus,
    Expression<bool>? followUpRequired,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceVisitId != null) 'service_visit_id': serviceVisitId,
      if (issueId != null) 'issue_id': issueId,
      if (technicianRemarks != null) 'technician_remarks': technicianRemarks,
      if (workPerformed != null) 'work_performed': workPerformed,
      if (partsReplaced != null) 'parts_replaced': partsReplaced,
      if (resolutionStatus != null) 'resolution_status': resolutionStatus,
      if (followUpRequired != null) 'follow_up_required': followUpRequired,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceVisitIssuesCompanion copyWith({
    Value<String>? id,
    Value<String>? serviceVisitId,
    Value<String>? issueId,
    Value<String?>? technicianRemarks,
    Value<String?>? workPerformed,
    Value<String?>? partsReplaced,
    Value<VisitIssueResolution>? resolutionStatus,
    Value<bool>? followUpRequired,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ServiceVisitIssuesCompanion(
      id: id ?? this.id,
      serviceVisitId: serviceVisitId ?? this.serviceVisitId,
      issueId: issueId ?? this.issueId,
      technicianRemarks: technicianRemarks ?? this.technicianRemarks,
      workPerformed: workPerformed ?? this.workPerformed,
      partsReplaced: partsReplaced ?? this.partsReplaced,
      resolutionStatus: resolutionStatus ?? this.resolutionStatus,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serviceVisitId.present) {
      map['service_visit_id'] = Variable<String>(serviceVisitId.value);
    }
    if (issueId.present) {
      map['issue_id'] = Variable<String>(issueId.value);
    }
    if (technicianRemarks.present) {
      map['technician_remarks'] = Variable<String>(technicianRemarks.value);
    }
    if (workPerformed.present) {
      map['work_performed'] = Variable<String>(workPerformed.value);
    }
    if (partsReplaced.present) {
      map['parts_replaced'] = Variable<String>(partsReplaced.value);
    }
    if (resolutionStatus.present) {
      map['resolution_status'] = Variable<int>(
        $ServiceVisitIssuesTable.$converterresolutionStatus.toSql(
          resolutionStatus.value,
        ),
      );
    }
    if (followUpRequired.present) {
      map['follow_up_required'] = Variable<bool>(followUpRequired.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceVisitIssuesCompanion(')
          ..write('id: $id, ')
          ..write('serviceVisitId: $serviceVisitId, ')
          ..write('issueId: $issueId, ')
          ..write('technicianRemarks: $technicianRemarks, ')
          ..write('workPerformed: $workPerformed, ')
          ..write('partsReplaced: $partsReplaced, ')
          ..write('resolutionStatus: $resolutionStatus, ')
          ..write('followUpRequired: $followUpRequired, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssueAttachmentsTable extends IssueAttachments
    with TableInfo<$IssueAttachmentsTable, IssueAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<String> issueId = GeneratedColumn<String>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    issueId,
    localFilePath,
    fileName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IssueAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_id'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IssueAttachmentsTable createAlias(String alias) {
    return $IssueAttachmentsTable(attachedDatabase, alias);
  }
}

class IssueAttachment extends DataClass implements Insertable<IssueAttachment> {
  final String id;
  final String issueId;
  final String localFilePath;
  final String fileName;
  final DateTime createdAt;
  const IssueAttachment({
    required this.id,
    required this.issueId,
    required this.localFilePath,
    required this.fileName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['issue_id'] = Variable<String>(issueId);
    map['local_file_path'] = Variable<String>(localFilePath);
    map['file_name'] = Variable<String>(fileName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IssueAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return IssueAttachmentsCompanion(
      id: Value(id),
      issueId: Value(issueId),
      localFilePath: Value(localFilePath),
      fileName: Value(fileName),
      createdAt: Value(createdAt),
    );
  }

  factory IssueAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueAttachment(
      id: serializer.fromJson<String>(json['id']),
      issueId: serializer.fromJson<String>(json['issueId']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'issueId': serializer.toJson<String>(issueId),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'fileName': serializer.toJson<String>(fileName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IssueAttachment copyWith({
    String? id,
    String? issueId,
    String? localFilePath,
    String? fileName,
    DateTime? createdAt,
  }) => IssueAttachment(
    id: id ?? this.id,
    issueId: issueId ?? this.issueId,
    localFilePath: localFilePath ?? this.localFilePath,
    fileName: fileName ?? this.fileName,
    createdAt: createdAt ?? this.createdAt,
  );
  IssueAttachment copyWithCompanion(IssueAttachmentsCompanion data) {
    return IssueAttachment(
      id: data.id.present ? data.id.value : this.id,
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueAttachment(')
          ..write('id: $id, ')
          ..write('issueId: $issueId, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, issueId, localFilePath, fileName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueAttachment &&
          other.id == this.id &&
          other.issueId == this.issueId &&
          other.localFilePath == this.localFilePath &&
          other.fileName == this.fileName &&
          other.createdAt == this.createdAt);
}

class IssueAttachmentsCompanion extends UpdateCompanion<IssueAttachment> {
  final Value<String> id;
  final Value<String> issueId;
  final Value<String> localFilePath;
  final Value<String> fileName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IssueAttachmentsCompanion({
    this.id = const Value.absent(),
    this.issueId = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueAttachmentsCompanion.insert({
    required String id,
    required String issueId,
    required String localFilePath,
    required String fileName,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       issueId = Value(issueId),
       localFilePath = Value(localFilePath),
       fileName = Value(fileName),
       createdAt = Value(createdAt);
  static Insertable<IssueAttachment> custom({
    Expression<String>? id,
    Expression<String>? issueId,
    Expression<String>? localFilePath,
    Expression<String>? fileName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (issueId != null) 'issue_id': issueId,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (fileName != null) 'file_name': fileName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? issueId,
    Value<String>? localFilePath,
    Value<String>? fileName,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IssueAttachmentsCompanion(
      id: id ?? this.id,
      issueId: issueId ?? this.issueId,
      localFilePath: localFilePath ?? this.localFilePath,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (issueId.present) {
      map['issue_id'] = Variable<String>(issueId.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('issueId: $issueId, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IssuesTable issues = $IssuesTable(this);
  late final $ServiceVisitsTable serviceVisits = $ServiceVisitsTable(this);
  late final $ServiceVisitIssuesTable serviceVisitIssues =
      $ServiceVisitIssuesTable(this);
  late final $IssueAttachmentsTable issueAttachments = $IssueAttachmentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    issues,
    serviceVisits,
    serviceVisitIssues,
    issueAttachments,
  ];
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
      Value<bool> isRecurring,
      Value<String?> parentIssueId,
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
      Value<bool> isRecurring,
      Value<String?> parentIssueId,
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

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentIssueId => $composableBuilder(
    column: $table.parentIssueId,
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

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentIssueId => $composableBuilder(
    column: $table.parentIssueId,
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

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentIssueId => $composableBuilder(
    column: $table.parentIssueId,
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
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> parentIssueId = const Value.absent(),
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
                isRecurring: isRecurring,
                parentIssueId: parentIssueId,
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
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> parentIssueId = const Value.absent(),
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
                isRecurring: isRecurring,
                parentIssueId: parentIssueId,
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
typedef $$ServiceVisitsTableCreateCompanionBuilder =
    ServiceVisitsCompanion Function({
      required String id,
      Value<String> vehicleId,
      required String serviceCentre,
      required DateTime visitDate,
      required int odometerReading,
      Value<ServiceVisitStatus> status,
      Value<String?> additionalRequests,
      Value<String?> technicianName,
      Value<String?> signOffDetails,
      Value<double?> totalCost,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$ServiceVisitsTableUpdateCompanionBuilder =
    ServiceVisitsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> serviceCentre,
      Value<DateTime> visitDate,
      Value<int> odometerReading,
      Value<ServiceVisitStatus> status,
      Value<String?> additionalRequests,
      Value<String?> technicianName,
      Value<String?> signOffDetails,
      Value<double?> totalCost,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$ServiceVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceVisitsTable> {
  $$ServiceVisitsTableFilterComposer({
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

  ColumnFilters<String> get serviceCentre => $composableBuilder(
    column: $table.serviceCentre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometerReading => $composableBuilder(
    column: $table.odometerReading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ServiceVisitStatus, ServiceVisitStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get additionalRequests => $composableBuilder(
    column: $table.additionalRequests,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get technicianName => $composableBuilder(
    column: $table.technicianName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signOffDetails => $composableBuilder(
    column: $table.signOffDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServiceVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceVisitsTable> {
  $$ServiceVisitsTableOrderingComposer({
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

  ColumnOrderings<String> get serviceCentre => $composableBuilder(
    column: $table.serviceCentre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometerReading => $composableBuilder(
    column: $table.odometerReading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get additionalRequests => $composableBuilder(
    column: $table.additionalRequests,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get technicianName => $composableBuilder(
    column: $table.technicianName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signOffDetails => $composableBuilder(
    column: $table.signOffDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServiceVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceVisitsTable> {
  $$ServiceVisitsTableAnnotationComposer({
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

  GeneratedColumn<String> get serviceCentre => $composableBuilder(
    column: $table.serviceCentre,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<int> get odometerReading => $composableBuilder(
    column: $table.odometerReading,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ServiceVisitStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get additionalRequests => $composableBuilder(
    column: $table.additionalRequests,
    builder: (column) => column,
  );

  GeneratedColumn<String> get technicianName => $composableBuilder(
    column: $table.technicianName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signOffDetails => $composableBuilder(
    column: $table.signOffDetails,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$ServiceVisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceVisitsTable,
          ServiceVisit,
          $$ServiceVisitsTableFilterComposer,
          $$ServiceVisitsTableOrderingComposer,
          $$ServiceVisitsTableAnnotationComposer,
          $$ServiceVisitsTableCreateCompanionBuilder,
          $$ServiceVisitsTableUpdateCompanionBuilder,
          (
            ServiceVisit,
            BaseReferences<_$AppDatabase, $ServiceVisitsTable, ServiceVisit>,
          ),
          ServiceVisit,
          PrefetchHooks Function()
        > {
  $$ServiceVisitsTableTableManager(_$AppDatabase db, $ServiceVisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> serviceCentre = const Value.absent(),
                Value<DateTime> visitDate = const Value.absent(),
                Value<int> odometerReading = const Value.absent(),
                Value<ServiceVisitStatus> status = const Value.absent(),
                Value<String?> additionalRequests = const Value.absent(),
                Value<String?> technicianName = const Value.absent(),
                Value<String?> signOffDetails = const Value.absent(),
                Value<double?> totalCost = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceVisitsCompanion(
                id: id,
                vehicleId: vehicleId,
                serviceCentre: serviceCentre,
                visitDate: visitDate,
                odometerReading: odometerReading,
                status: status,
                additionalRequests: additionalRequests,
                technicianName: technicianName,
                signOffDetails: signOffDetails,
                totalCost: totalCost,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> vehicleId = const Value.absent(),
                required String serviceCentre,
                required DateTime visitDate,
                required int odometerReading,
                Value<ServiceVisitStatus> status = const Value.absent(),
                Value<String?> additionalRequests = const Value.absent(),
                Value<String?> technicianName = const Value.absent(),
                Value<String?> signOffDetails = const Value.absent(),
                Value<double?> totalCost = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceVisitsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                serviceCentre: serviceCentre,
                visitDate: visitDate,
                odometerReading: odometerReading,
                status: status,
                additionalRequests: additionalRequests,
                technicianName: technicianName,
                signOffDetails: signOffDetails,
                totalCost: totalCost,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServiceVisitsTable, ServiceVisit>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ServiceVisitsTable,
                    ServiceVisit
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServiceVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceVisitsTable,
      ServiceVisit,
      $$ServiceVisitsTableFilterComposer,
      $$ServiceVisitsTableOrderingComposer,
      $$ServiceVisitsTableAnnotationComposer,
      $$ServiceVisitsTableCreateCompanionBuilder,
      $$ServiceVisitsTableUpdateCompanionBuilder,
      (
        ServiceVisit,
        BaseReferences<_$AppDatabase, $ServiceVisitsTable, ServiceVisit>,
      ),
      ServiceVisit,
      PrefetchHooks Function()
    >;
typedef $$ServiceVisitIssuesTableCreateCompanionBuilder =
    ServiceVisitIssuesCompanion Function({
      required String id,
      required String serviceVisitId,
      required String issueId,
      Value<String?> technicianRemarks,
      Value<String?> workPerformed,
      Value<String?> partsReplaced,
      Value<VisitIssueResolution> resolutionStatus,
      Value<bool> followUpRequired,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ServiceVisitIssuesTableUpdateCompanionBuilder =
    ServiceVisitIssuesCompanion Function({
      Value<String> id,
      Value<String> serviceVisitId,
      Value<String> issueId,
      Value<String?> technicianRemarks,
      Value<String?> workPerformed,
      Value<String?> partsReplaced,
      Value<VisitIssueResolution> resolutionStatus,
      Value<bool> followUpRequired,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ServiceVisitIssuesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceVisitIssuesTable> {
  $$ServiceVisitIssuesTableFilterComposer({
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

  ColumnFilters<String> get serviceVisitId => $composableBuilder(
    column: $table.serviceVisitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get technicianRemarks => $composableBuilder(
    column: $table.technicianRemarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workPerformed => $composableBuilder(
    column: $table.workPerformed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partsReplaced => $composableBuilder(
    column: $table.partsReplaced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    VisitIssueResolution,
    VisitIssueResolution,
    int
  >
  get resolutionStatus => $composableBuilder(
    column: $table.resolutionStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get followUpRequired => $composableBuilder(
    column: $table.followUpRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServiceVisitIssuesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceVisitIssuesTable> {
  $$ServiceVisitIssuesTableOrderingComposer({
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

  ColumnOrderings<String> get serviceVisitId => $composableBuilder(
    column: $table.serviceVisitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get technicianRemarks => $composableBuilder(
    column: $table.technicianRemarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workPerformed => $composableBuilder(
    column: $table.workPerformed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partsReplaced => $composableBuilder(
    column: $table.partsReplaced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolutionStatus => $composableBuilder(
    column: $table.resolutionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get followUpRequired => $composableBuilder(
    column: $table.followUpRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServiceVisitIssuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceVisitIssuesTable> {
  $$ServiceVisitIssuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceVisitId => $composableBuilder(
    column: $table.serviceVisitId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<String> get technicianRemarks => $composableBuilder(
    column: $table.technicianRemarks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workPerformed => $composableBuilder(
    column: $table.workPerformed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partsReplaced => $composableBuilder(
    column: $table.partsReplaced,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<VisitIssueResolution, int>
  get resolutionStatus => $composableBuilder(
    column: $table.resolutionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get followUpRequired => $composableBuilder(
    column: $table.followUpRequired,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ServiceVisitIssuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceVisitIssuesTable,
          ServiceVisitIssue,
          $$ServiceVisitIssuesTableFilterComposer,
          $$ServiceVisitIssuesTableOrderingComposer,
          $$ServiceVisitIssuesTableAnnotationComposer,
          $$ServiceVisitIssuesTableCreateCompanionBuilder,
          $$ServiceVisitIssuesTableUpdateCompanionBuilder,
          (
            ServiceVisitIssue,
            BaseReferences<
              _$AppDatabase,
              $ServiceVisitIssuesTable,
              ServiceVisitIssue
            >,
          ),
          ServiceVisitIssue,
          PrefetchHooks Function()
        > {
  $$ServiceVisitIssuesTableTableManager(
    _$AppDatabase db,
    $ServiceVisitIssuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceVisitIssuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceVisitIssuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceVisitIssuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> serviceVisitId = const Value.absent(),
                Value<String> issueId = const Value.absent(),
                Value<String?> technicianRemarks = const Value.absent(),
                Value<String?> workPerformed = const Value.absent(),
                Value<String?> partsReplaced = const Value.absent(),
                Value<VisitIssueResolution> resolutionStatus =
                    const Value.absent(),
                Value<bool> followUpRequired = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceVisitIssuesCompanion(
                id: id,
                serviceVisitId: serviceVisitId,
                issueId: issueId,
                technicianRemarks: technicianRemarks,
                workPerformed: workPerformed,
                partsReplaced: partsReplaced,
                resolutionStatus: resolutionStatus,
                followUpRequired: followUpRequired,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String serviceVisitId,
                required String issueId,
                Value<String?> technicianRemarks = const Value.absent(),
                Value<String?> workPerformed = const Value.absent(),
                Value<String?> partsReplaced = const Value.absent(),
                Value<VisitIssueResolution> resolutionStatus =
                    const Value.absent(),
                Value<bool> followUpRequired = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ServiceVisitIssuesCompanion.insert(
                id: id,
                serviceVisitId: serviceVisitId,
                issueId: issueId,
                technicianRemarks: technicianRemarks,
                workPerformed: workPerformed,
                partsReplaced: partsReplaced,
                resolutionStatus: resolutionStatus,
                followUpRequired: followUpRequired,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServiceVisitIssuesTable, ServiceVisitIssue>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ServiceVisitIssuesTable,
                    ServiceVisitIssue
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServiceVisitIssuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceVisitIssuesTable,
      ServiceVisitIssue,
      $$ServiceVisitIssuesTableFilterComposer,
      $$ServiceVisitIssuesTableOrderingComposer,
      $$ServiceVisitIssuesTableAnnotationComposer,
      $$ServiceVisitIssuesTableCreateCompanionBuilder,
      $$ServiceVisitIssuesTableUpdateCompanionBuilder,
      (
        ServiceVisitIssue,
        BaseReferences<
          _$AppDatabase,
          $ServiceVisitIssuesTable,
          ServiceVisitIssue
        >,
      ),
      ServiceVisitIssue,
      PrefetchHooks Function()
    >;
typedef $$IssueAttachmentsTableCreateCompanionBuilder =
    IssueAttachmentsCompanion Function({
      required String id,
      required String issueId,
      required String localFilePath,
      required String fileName,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$IssueAttachmentsTableUpdateCompanionBuilder =
    IssueAttachmentsCompanion Function({
      Value<String> id,
      Value<String> issueId,
      Value<String> localFilePath,
      Value<String> fileName,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$IssueAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $IssueAttachmentsTable> {
  $$IssueAttachmentsTableFilterComposer({
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

  ColumnFilters<String> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueAttachmentsTable> {
  $$IssueAttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueAttachmentsTable> {
  $$IssueAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IssueAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueAttachmentsTable,
          IssueAttachment,
          $$IssueAttachmentsTableFilterComposer,
          $$IssueAttachmentsTableOrderingComposer,
          $$IssueAttachmentsTableAnnotationComposer,
          $$IssueAttachmentsTableCreateCompanionBuilder,
          $$IssueAttachmentsTableUpdateCompanionBuilder,
          (
            IssueAttachment,
            BaseReferences<
              _$AppDatabase,
              $IssueAttachmentsTable,
              IssueAttachment
            >,
          ),
          IssueAttachment,
          PrefetchHooks Function()
        > {
  $$IssueAttachmentsTableTableManager(
    _$AppDatabase db,
    $IssueAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> issueId = const Value.absent(),
                Value<String> localFilePath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueAttachmentsCompanion(
                id: id,
                issueId: issueId,
                localFilePath: localFilePath,
                fileName: fileName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String issueId,
                required String localFilePath,
                required String fileName,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IssueAttachmentsCompanion.insert(
                id: id,
                issueId: issueId,
                localFilePath: localFilePath,
                fileName: fileName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IssueAttachmentsTable, IssueAttachment>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $IssueAttachmentsTable,
                    IssueAttachment
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueAttachmentsTable,
      IssueAttachment,
      $$IssueAttachmentsTableFilterComposer,
      $$IssueAttachmentsTableOrderingComposer,
      $$IssueAttachmentsTableAnnotationComposer,
      $$IssueAttachmentsTableCreateCompanionBuilder,
      $$IssueAttachmentsTableUpdateCompanionBuilder,
      (
        IssueAttachment,
        BaseReferences<_$AppDatabase, $IssueAttachmentsTable, IssueAttachment>,
      ),
      IssueAttachment,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IssuesTableTableManager get issues =>
      $$IssuesTableTableManager(_db, _db.issues);
  $$ServiceVisitsTableTableManager get serviceVisits =>
      $$ServiceVisitsTableTableManager(_db, _db.serviceVisits);
  $$ServiceVisitIssuesTableTableManager get serviceVisitIssues =>
      $$ServiceVisitIssuesTableTableManager(_db, _db.serviceVisitIssues);
  $$IssueAttachmentsTableTableManager get issueAttachments =>
      $$IssueAttachmentsTableTableManager(_db, _db.issueAttachments);
}
