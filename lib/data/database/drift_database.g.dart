// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $LocalDraftSessionsTable extends LocalDraftSessions
    with TableInfo<$LocalDraftSessionsTable, LocalDraftSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDraftSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stakeholderIdMeta = const VerificationMeta(
    'stakeholderId',
  );
  @override
  late final GeneratedColumn<String> stakeholderId = GeneratedColumn<String>(
    'stakeholder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionNotesMeta = const VerificationMeta(
    'sessionNotes',
  );
  @override
  late final GeneratedColumn<String> sessionNotes = GeneratedColumn<String>(
    'session_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _participantEngagementMeta =
      const VerificationMeta('participantEngagement');
  @override
  late final GeneratedColumn<int> participantEngagement = GeneratedColumn<int>(
    'participant_engagement',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalProgressMeta = const VerificationMeta(
    'goalProgress',
  );
  @override
  late final GeneratedColumn<String> goalProgress = GeneratedColumn<String>(
    'goal_progress',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _behaviorIncidentIdsMeta =
      const VerificationMeta('behaviorIncidentIds');
  @override
  late final GeneratedColumn<String> behaviorIncidentIds =
      GeneratedColumn<String>(
        'behavior_incident_ids',
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
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    clientId,
    stakeholderId,
    performedAt,
    durationMinutes,
    sessionNotes,
    participantEngagement,
    goalProgress,
    behaviorIncidentIds,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_draft_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDraftSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('stakeholder_id')) {
      context.handle(
        _stakeholderIdMeta,
        stakeholderId.isAcceptableOrUnknown(
          data['stakeholder_id']!,
          _stakeholderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stakeholderIdMeta);
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_performedAtMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('session_notes')) {
      context.handle(
        _sessionNotesMeta,
        sessionNotes.isAcceptableOrUnknown(
          data['session_notes']!,
          _sessionNotesMeta,
        ),
      );
    }
    if (data.containsKey('participant_engagement')) {
      context.handle(
        _participantEngagementMeta,
        participantEngagement.isAcceptableOrUnknown(
          data['participant_engagement']!,
          _participantEngagementMeta,
        ),
      );
    }
    if (data.containsKey('goal_progress')) {
      context.handle(
        _goalProgressMeta,
        goalProgress.isAcceptableOrUnknown(
          data['goal_progress']!,
          _goalProgressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_goalProgressMeta);
    }
    if (data.containsKey('behavior_incident_ids')) {
      context.handle(
        _behaviorIncidentIdsMeta,
        behaviorIncidentIds.isAcceptableOrUnknown(
          data['behavior_incident_ids']!,
          _behaviorIncidentIdsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_behaviorIncidentIdsMeta);
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
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDraftSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDraftSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      stakeholderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stakeholder_id'],
      )!,
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      sessionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_notes'],
      ),
      participantEngagement: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_engagement'],
      ),
      goalProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_progress'],
      )!,
      behaviorIncidentIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}behavior_incident_ids'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $LocalDraftSessionsTable createAlias(String alias) {
    return $LocalDraftSessionsTable(attachedDatabase, alias);
  }
}

class LocalDraftSession extends DataClass
    implements Insertable<LocalDraftSession> {
  final String id;
  final String activityId;
  final String clientId;
  final String stakeholderId;
  final DateTime performedAt;
  final int? durationMinutes;
  final String? sessionNotes;
  final int? participantEngagement;
  final String goalProgress;
  final String behaviorIncidentIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const LocalDraftSession({
    required this.id,
    required this.activityId,
    required this.clientId,
    required this.stakeholderId,
    required this.performedAt,
    this.durationMinutes,
    this.sessionNotes,
    this.participantEngagement,
    required this.goalProgress,
    required this.behaviorIncidentIds,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['client_id'] = Variable<String>(clientId);
    map['stakeholder_id'] = Variable<String>(stakeholderId);
    map['performed_at'] = Variable<DateTime>(performedAt);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || sessionNotes != null) {
      map['session_notes'] = Variable<String>(sessionNotes);
    }
    if (!nullToAbsent || participantEngagement != null) {
      map['participant_engagement'] = Variable<int>(participantEngagement);
    }
    map['goal_progress'] = Variable<String>(goalProgress);
    map['behavior_incident_ids'] = Variable<String>(behaviorIncidentIds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalDraftSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalDraftSessionsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      clientId: Value(clientId),
      stakeholderId: Value(stakeholderId),
      performedAt: Value(performedAt),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      sessionNotes: sessionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionNotes),
      participantEngagement: participantEngagement == null && nullToAbsent
          ? const Value.absent()
          : Value(participantEngagement),
      goalProgress: Value(goalProgress),
      behaviorIncidentIds: Value(behaviorIncidentIds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocalDraftSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDraftSession(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      stakeholderId: serializer.fromJson<String>(json['stakeholderId']),
      performedAt: serializer.fromJson<DateTime>(json['performedAt']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      sessionNotes: serializer.fromJson<String?>(json['sessionNotes']),
      participantEngagement: serializer.fromJson<int?>(
        json['participantEngagement'],
      ),
      goalProgress: serializer.fromJson<String>(json['goalProgress']),
      behaviorIncidentIds: serializer.fromJson<String>(
        json['behaviorIncidentIds'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'clientId': serializer.toJson<String>(clientId),
      'stakeholderId': serializer.toJson<String>(stakeholderId),
      'performedAt': serializer.toJson<DateTime>(performedAt),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'sessionNotes': serializer.toJson<String?>(sessionNotes),
      'participantEngagement': serializer.toJson<int?>(participantEngagement),
      'goalProgress': serializer.toJson<String>(goalProgress),
      'behaviorIncidentIds': serializer.toJson<String>(behaviorIncidentIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LocalDraftSession copyWith({
    String? id,
    String? activityId,
    String? clientId,
    String? stakeholderId,
    DateTime? performedAt,
    Value<int?> durationMinutes = const Value.absent(),
    Value<String?> sessionNotes = const Value.absent(),
    Value<int?> participantEngagement = const Value.absent(),
    String? goalProgress,
    String? behaviorIncidentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => LocalDraftSession(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    clientId: clientId ?? this.clientId,
    stakeholderId: stakeholderId ?? this.stakeholderId,
    performedAt: performedAt ?? this.performedAt,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    sessionNotes: sessionNotes.present ? sessionNotes.value : this.sessionNotes,
    participantEngagement: participantEngagement.present
        ? participantEngagement.value
        : this.participantEngagement,
    goalProgress: goalProgress ?? this.goalProgress,
    behaviorIncidentIds: behaviorIncidentIds ?? this.behaviorIncidentIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  LocalDraftSession copyWithCompanion(LocalDraftSessionsCompanion data) {
    return LocalDraftSession(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      stakeholderId: data.stakeholderId.present
          ? data.stakeholderId.value
          : this.stakeholderId,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      sessionNotes: data.sessionNotes.present
          ? data.sessionNotes.value
          : this.sessionNotes,
      participantEngagement: data.participantEngagement.present
          ? data.participantEngagement.value
          : this.participantEngagement,
      goalProgress: data.goalProgress.present
          ? data.goalProgress.value
          : this.goalProgress,
      behaviorIncidentIds: data.behaviorIncidentIds.present
          ? data.behaviorIncidentIds.value
          : this.behaviorIncidentIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDraftSession(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('clientId: $clientId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('performedAt: $performedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('sessionNotes: $sessionNotes, ')
          ..write('participantEngagement: $participantEngagement, ')
          ..write('goalProgress: $goalProgress, ')
          ..write('behaviorIncidentIds: $behaviorIncidentIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityId,
    clientId,
    stakeholderId,
    performedAt,
    durationMinutes,
    sessionNotes,
    participantEngagement,
    goalProgress,
    behaviorIncidentIds,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDraftSession &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.clientId == this.clientId &&
          other.stakeholderId == this.stakeholderId &&
          other.performedAt == this.performedAt &&
          other.durationMinutes == this.durationMinutes &&
          other.sessionNotes == this.sessionNotes &&
          other.participantEngagement == this.participantEngagement &&
          other.goalProgress == this.goalProgress &&
          other.behaviorIncidentIds == this.behaviorIncidentIds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class LocalDraftSessionsCompanion extends UpdateCompanion<LocalDraftSession> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<String> clientId;
  final Value<String> stakeholderId;
  final Value<DateTime> performedAt;
  final Value<int?> durationMinutes;
  final Value<String?> sessionNotes;
  final Value<int?> participantEngagement;
  final Value<String> goalProgress;
  final Value<String> behaviorIncidentIds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalDraftSessionsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.stakeholderId = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.sessionNotes = const Value.absent(),
    this.participantEngagement = const Value.absent(),
    this.goalProgress = const Value.absent(),
    this.behaviorIncidentIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDraftSessionsCompanion.insert({
    required String id,
    required String activityId,
    required String clientId,
    required String stakeholderId,
    required DateTime performedAt,
    this.durationMinutes = const Value.absent(),
    this.sessionNotes = const Value.absent(),
    this.participantEngagement = const Value.absent(),
    required String goalProgress,
    required String behaviorIncidentIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityId = Value(activityId),
       clientId = Value(clientId),
       stakeholderId = Value(stakeholderId),
       performedAt = Value(performedAt),
       goalProgress = Value(goalProgress),
       behaviorIncidentIds = Value(behaviorIncidentIds),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncStatus = Value(syncStatus);
  static Insertable<LocalDraftSession> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<String>? clientId,
    Expression<String>? stakeholderId,
    Expression<DateTime>? performedAt,
    Expression<int>? durationMinutes,
    Expression<String>? sessionNotes,
    Expression<int>? participantEngagement,
    Expression<String>? goalProgress,
    Expression<String>? behaviorIncidentIds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (clientId != null) 'client_id': clientId,
      if (stakeholderId != null) 'stakeholder_id': stakeholderId,
      if (performedAt != null) 'performed_at': performedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (sessionNotes != null) 'session_notes': sessionNotes,
      if (participantEngagement != null)
        'participant_engagement': participantEngagement,
      if (goalProgress != null) 'goal_progress': goalProgress,
      if (behaviorIncidentIds != null)
        'behavior_incident_ids': behaviorIncidentIds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDraftSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? activityId,
    Value<String>? clientId,
    Value<String>? stakeholderId,
    Value<DateTime>? performedAt,
    Value<int?>? durationMinutes,
    Value<String?>? sessionNotes,
    Value<int?>? participantEngagement,
    Value<String>? goalProgress,
    Value<String>? behaviorIncidentIds,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return LocalDraftSessionsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      clientId: clientId ?? this.clientId,
      stakeholderId: stakeholderId ?? this.stakeholderId,
      performedAt: performedAt ?? this.performedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      participantEngagement:
          participantEngagement ?? this.participantEngagement,
      goalProgress: goalProgress ?? this.goalProgress,
      behaviorIncidentIds: behaviorIncidentIds ?? this.behaviorIncidentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (stakeholderId.present) {
      map['stakeholder_id'] = Variable<String>(stakeholderId.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (sessionNotes.present) {
      map['session_notes'] = Variable<String>(sessionNotes.value);
    }
    if (participantEngagement.present) {
      map['participant_engagement'] = Variable<int>(
        participantEngagement.value,
      );
    }
    if (goalProgress.present) {
      map['goal_progress'] = Variable<String>(goalProgress.value);
    }
    if (behaviorIncidentIds.present) {
      map['behavior_incident_ids'] = Variable<String>(
        behaviorIncidentIds.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDraftSessionsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('clientId: $clientId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('performedAt: $performedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('sessionNotes: $sessionNotes, ')
          ..write('participantEngagement: $participantEngagement, ')
          ..write('goalProgress: $goalProgress, ')
          ..write('behaviorIncidentIds: $behaviorIncidentIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalDraftSessionsTable localDraftSessions =
      $LocalDraftSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localDraftSessions];
}

typedef $$LocalDraftSessionsTableCreateCompanionBuilder =
    LocalDraftSessionsCompanion Function({
      required String id,
      required String activityId,
      required String clientId,
      required String stakeholderId,
      required DateTime performedAt,
      Value<int?> durationMinutes,
      Value<String?> sessionNotes,
      Value<int?> participantEngagement,
      required String goalProgress,
      required String behaviorIncidentIds,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String syncStatus,
      Value<int> rowid,
    });
typedef $$LocalDraftSessionsTableUpdateCompanionBuilder =
    LocalDraftSessionsCompanion Function({
      Value<String> id,
      Value<String> activityId,
      Value<String> clientId,
      Value<String> stakeholderId,
      Value<DateTime> performedAt,
      Value<int?> durationMinutes,
      Value<String?> sessionNotes,
      Value<int?> participantEngagement,
      Value<String> goalProgress,
      Value<String> behaviorIncidentIds,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$LocalDraftSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDraftSessionsTable> {
  $$LocalDraftSessionsTableFilterComposer({
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

  ColumnFilters<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stakeholderId => $composableBuilder(
    column: $table.stakeholderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get participantEngagement => $composableBuilder(
    column: $table.participantEngagement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalProgress => $composableBuilder(
    column: $table.goalProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get behaviorIncidentIds => $composableBuilder(
    column: $table.behaviorIncidentIds,
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

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDraftSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDraftSessionsTable> {
  $$LocalDraftSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stakeholderId => $composableBuilder(
    column: $table.stakeholderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get participantEngagement => $composableBuilder(
    column: $table.participantEngagement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalProgress => $composableBuilder(
    column: $table.goalProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get behaviorIncidentIds => $composableBuilder(
    column: $table.behaviorIncidentIds,
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

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDraftSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDraftSessionsTable> {
  $$LocalDraftSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get stakeholderId => $composableBuilder(
    column: $table.stakeholderId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get participantEngagement => $composableBuilder(
    column: $table.participantEngagement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get goalProgress => $composableBuilder(
    column: $table.goalProgress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get behaviorIncidentIds => $composableBuilder(
    column: $table.behaviorIncidentIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$LocalDraftSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDraftSessionsTable,
          LocalDraftSession,
          $$LocalDraftSessionsTableFilterComposer,
          $$LocalDraftSessionsTableOrderingComposer,
          $$LocalDraftSessionsTableAnnotationComposer,
          $$LocalDraftSessionsTableCreateCompanionBuilder,
          $$LocalDraftSessionsTableUpdateCompanionBuilder,
          (
            LocalDraftSession,
            BaseReferences<
              _$AppDatabase,
              $LocalDraftSessionsTable,
              LocalDraftSession
            >,
          ),
          LocalDraftSession,
          PrefetchHooks Function()
        > {
  $$LocalDraftSessionsTableTableManager(
    _$AppDatabase db,
    $LocalDraftSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDraftSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDraftSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDraftSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> stakeholderId = const Value.absent(),
                Value<DateTime> performedAt = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<String?> sessionNotes = const Value.absent(),
                Value<int?> participantEngagement = const Value.absent(),
                Value<String> goalProgress = const Value.absent(),
                Value<String> behaviorIncidentIds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDraftSessionsCompanion(
                id: id,
                activityId: activityId,
                clientId: clientId,
                stakeholderId: stakeholderId,
                performedAt: performedAt,
                durationMinutes: durationMinutes,
                sessionNotes: sessionNotes,
                participantEngagement: participantEngagement,
                goalProgress: goalProgress,
                behaviorIncidentIds: behaviorIncidentIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String activityId,
                required String clientId,
                required String stakeholderId,
                required DateTime performedAt,
                Value<int?> durationMinutes = const Value.absent(),
                Value<String?> sessionNotes = const Value.absent(),
                Value<int?> participantEngagement = const Value.absent(),
                required String goalProgress,
                required String behaviorIncidentIds,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => LocalDraftSessionsCompanion.insert(
                id: id,
                activityId: activityId,
                clientId: clientId,
                stakeholderId: stakeholderId,
                performedAt: performedAt,
                durationMinutes: durationMinutes,
                sessionNotes: sessionNotes,
                participantEngagement: participantEngagement,
                goalProgress: goalProgress,
                behaviorIncidentIds: behaviorIncidentIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDraftSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDraftSessionsTable,
      LocalDraftSession,
      $$LocalDraftSessionsTableFilterComposer,
      $$LocalDraftSessionsTableOrderingComposer,
      $$LocalDraftSessionsTableAnnotationComposer,
      $$LocalDraftSessionsTableCreateCompanionBuilder,
      $$LocalDraftSessionsTableUpdateCompanionBuilder,
      (
        LocalDraftSession,
        BaseReferences<
          _$AppDatabase,
          $LocalDraftSessionsTable,
          LocalDraftSession
        >,
      ),
      LocalDraftSession,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalDraftSessionsTableTableManager get localDraftSessions =>
      $$LocalDraftSessionsTableTableManager(_db, _db.localDraftSessions);
}
