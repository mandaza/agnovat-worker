// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BehaviorIncidentImpl _$$BehaviorIncidentImplFromJson(
  Map<String, dynamic> json,
) => _$BehaviorIncidentImpl(
  id: json['id'] as String,
  behaviorsDisplayed: (json['behaviors_displayed'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  duration: json['duration'] as String,
  severity: _severityFromJson(json['severity'] as String),
  selfHarm: json['self_harm'] as bool,
  selfHarmTypes:
      (json['self_harm_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  selfHarmCount: json['self_harm_count'] == null
      ? 0
      : _selfHarmCountToInt(json['self_harm_count']),
  initialIntervention: json['initial_intervention'] as String,
  interventionDescription: json['intervention_description'] as String?,
  secondSupportNeeded:
      (json['second_support_needed'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  secondSupportDescription: json['second_support_description'] as String?,
  description: json['description'] as String,
);

Map<String, dynamic> _$$BehaviorIncidentImplToJson(
  _$BehaviorIncidentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'behaviors_displayed': instance.behaviorsDisplayed,
  'duration': instance.duration,
  'severity': _severityToJson(instance.severity),
  'self_harm': instance.selfHarm,
  'self_harm_types': instance.selfHarmTypes,
  'self_harm_count': instance.selfHarmCount,
  'initial_intervention': instance.initialIntervention,
  'intervention_description': instance.interventionDescription,
  'second_support_needed': instance.secondSupportNeeded,
  'second_support_description': instance.secondSupportDescription,
  'description': instance.description,
};

_$GoalProgressEntryImpl _$$GoalProgressEntryImplFromJson(
  Map<String, dynamic> json,
) => _$GoalProgressEntryImpl(
  goalId: json['goal_id'] as String,
  progressObserved: _progressToInt(json['progress_observed']),
  evidenceNotes: json['evidence_notes'] as String,
);

Map<String, dynamic> _$$GoalProgressEntryImplToJson(
  _$GoalProgressEntryImpl instance,
) => <String, dynamic>{
  'goal_id': instance.goalId,
  'progress_observed': instance.progressObserved,
  'evidence_notes': instance.evidenceNotes,
};

_$MediaItemImpl _$$MediaItemImplFromJson(Map<String, dynamic> json) =>
    _$MediaItemImpl(
      id: json['id'] as String? ?? '',
      storageId: json['storage_id'] as String? ?? '',
      type: json['type'] as String? ?? 'photo',
      fileName: json['file_name'] as String? ?? '',
      fileSize: json['file_size'] == null
          ? 0
          : _fileSizeToInt(json['file_size']),
      mimeType: json['mime_type'] as String? ?? '',
      uploadedAt: json['uploaded_at'] == null
          ? null
          : DateTime.parse(json['uploaded_at'] as String),
    );

Map<String, dynamic> _$$MediaItemImplToJson(_$MediaItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storage_id': instance.storageId,
      'type': instance.type,
      'file_name': instance.fileName,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'uploaded_at': instance.uploadedAt?.toIso8601String(),
    };

_$ActivitySessionImpl _$$ActivitySessionImplFromJson(
  Map<String, dynamic> json,
) => _$ActivitySessionImpl(
  id: json['id'] as String,
  activityId: json['activity_id'] as String,
  clientId: json['client_id'] as String,
  stakeholderId: json['user_id'] as String,
  shiftNoteId: json['shift_note_id'] as String?,
  sessionStartTime: DateTime.parse(json['session_start_time'] as String),
  sessionEndTime: DateTime.parse(json['session_end_time'] as String),
  durationMinutes: _durationToInt(json['duration_minutes']),
  location: json['location'] as String? ?? 'Unknown',
  sessionNotes: json['session_notes'] as String? ?? '',
  participantEngagement: _participantEngagementFromJson(
    (json['participant_engagement'] as num).toInt(),
  ),
  goalProgress:
      (json['goal_progress'] as List<dynamic>?)
          ?.map((e) => GoalProgressEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  behaviorIncidents:
      (json['behavior_incidents'] as List<dynamic>?)
          ?.map((e) => BehaviorIncident.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  activityTitle: json['activity_title'] as String?,
  activityType: json['activity_type'] as String?,
  clientName: json['client_name'] as String?,
  stakeholderName: json['stakeholder_name'] as String?,
  goalTitles: (json['goal_titles'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$ActivitySessionImplToJson(
  _$ActivitySessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'activity_id': instance.activityId,
  'client_id': instance.clientId,
  'user_id': instance.stakeholderId,
  'shift_note_id': instance.shiftNoteId,
  'session_start_time': instance.sessionStartTime.toIso8601String(),
  'session_end_time': instance.sessionEndTime.toIso8601String(),
  'duration_minutes': instance.durationMinutes,
  'location': instance.location,
  'session_notes': instance.sessionNotes,
  'participant_engagement': _participantEngagementToJson(
    instance.participantEngagement,
  ),
  'goal_progress': instance.goalProgress,
  'behavior_incidents': instance.behaviorIncidents,
  'media': instance.media,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'activity_title': instance.activityTitle,
  'activity_type': instance.activityType,
  'client_name': instance.clientName,
  'stakeholder_name': instance.stakeholderName,
  'goal_titles': instance.goalTitles,
};

_$DraftActivitySessionImpl _$$DraftActivitySessionImplFromJson(
  Map<String, dynamic> json,
) => _$DraftActivitySessionImpl(
  id: json['id'] as String,
  activityId: json['activity_id'] as String,
  clientId: json['client_id'] as String,
  stakeholderId: json['user_id'] as String,
  performedAt: DateTime.parse(json['performed_at'] as String),
  durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
  sessionNotes: json['session_notes'] as String?,
  participantEngagement: _participantEngagementFromJsonNullable(
    (json['participant_engagement'] as num?)?.toInt(),
  ),
  goalProgress:
      (json['goal_progress'] as List<dynamic>?)
          ?.map((e) => GoalProgressEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  behaviorIncidentIds:
      (json['behavior_incident_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  syncStatus: _syncStatusFromJson(json['sync_status'] as String),
);

Map<String, dynamic> _$$DraftActivitySessionImplToJson(
  _$DraftActivitySessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'activity_id': instance.activityId,
  'client_id': instance.clientId,
  'user_id': instance.stakeholderId,
  'performed_at': instance.performedAt.toIso8601String(),
  'duration_minutes': instance.durationMinutes,
  'session_notes': instance.sessionNotes,
  'participant_engagement': _participantEngagementToJsonNullable(
    instance.participantEngagement,
  ),
  'goal_progress': instance.goalProgress,
  'behavior_incident_ids': instance.behaviorIncidentIds,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'sync_status': _syncStatusToJson(instance.syncStatus),
};
