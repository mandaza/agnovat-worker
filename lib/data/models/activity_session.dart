import 'package:freezed_annotation/freezed_annotation.dart';
import 'activity_session_enums.dart';

part 'activity_session.freezed.dart';
part 'activity_session.g.dart';

/// Behavior severity levels
enum BehaviorSeverity {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case BehaviorSeverity.low:
        return 'Low: minor disruption';
      case BehaviorSeverity.medium:
        return 'Medium: Moderate impact on safety or environment';
      case BehaviorSeverity.high:
        return 'High: Severe risk to safety or significant disruption';
    }
  }

  static BehaviorSeverity fromJson(String value) {
    return BehaviorSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BehaviorSeverity.low,
    );
  }

  String toJson() => name;
}

/// Behavior incident within an activity session
@freezed
class BehaviorIncident with _$BehaviorIncident {
  const factory BehaviorIncident({
    required String id, // Local ID for the incident
    @JsonKey(name: 'behaviors_displayed') required List<String> behaviorsDisplayed,
    required String duration,
    @JsonKey(fromJson: _severityFromJson, toJson: _severityToJson) required BehaviorSeverity severity,
    @JsonKey(name: 'self_harm') required bool selfHarm,
    @JsonKey(name: 'self_harm_types') @Default([]) List<String> selfHarmTypes,
    @JsonKey(name: 'self_harm_count', fromJson: _selfHarmCountToInt) @Default(0) int selfHarmCount,
    @JsonKey(name: 'initial_intervention') required String initialIntervention,
    @JsonKey(name: 'intervention_description') String? interventionDescription,
    @JsonKey(name: 'second_support_needed') @Default([]) List<String> secondSupportNeeded,
    @JsonKey(name: 'second_support_description') String? secondSupportDescription,
    required String description,
  }) = _BehaviorIncident;

  factory BehaviorIncident.fromJson(Map<String, dynamic> json) =>
      _$BehaviorIncidentFromJson(json);
}

/// Helper to convert double/int to int for self_harm_count
int _selfHarmCountToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Helper functions for BehaviorSeverity JSON conversion
BehaviorSeverity _severityFromJson(String value) => BehaviorSeverity.fromJson(value);
String _severityToJson(BehaviorSeverity severity) => severity.toJson();

/// Goal progress entry within an activity session
@freezed
class GoalProgressEntry with _$GoalProgressEntry {
  const factory GoalProgressEntry({
    @JsonKey(name: 'goal_id') required String goalId,
    @JsonKey(name: 'progress_observed', fromJson: _progressToInt) required int progressObserved, // 1-10 scale
    @JsonKey(name: 'evidence_notes') required String evidenceNotes,
  }) = _GoalProgressEntry;

  factory GoalProgressEntry.fromJson(Map<String, dynamic> json) =>
      _$GoalProgressEntryFromJson(json);
}

/// Helper to convert double/int to int for progress_observed
int _progressToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Media item attached to an activity session
@freezed
class MediaItem with _$MediaItem {
  const factory MediaItem({
    @Default('') String id,
    @JsonKey(name: 'storage_id') @Default('') String storageId,
    @Default('photo') String type, // 'photo' or 'video'
    @JsonKey(name: 'file_name') @Default('') String fileName,
    @JsonKey(name: 'file_size', fromJson: _fileSizeToInt) @Default(0) int fileSize,
    @JsonKey(name: 'mime_type') @Default('') String mimeType,
    @JsonKey(name: 'uploaded_at') DateTime? uploadedAt,
  }) = _MediaItem;

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);
}

/// Helper to convert dynamic to int for file_size
int _fileSizeToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Complete activity session record (within a shift)
@freezed
class ActivitySession with _$ActivitySession {
  const factory ActivitySession({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'activity_id') required String activityId,
    @JsonKey(name: 'client_id') required String clientId,
    @JsonKey(name: 'user_id') required String stakeholderId,
    @JsonKey(name: 'shift_note_id') String? shiftNoteId,
    @JsonKey(name: 'session_start_time') required DateTime sessionStartTime,
    @JsonKey(name: 'session_end_time') required DateTime sessionEndTime,
    @JsonKey(name: 'duration_minutes', fromJson: _durationToInt) required int durationMinutes,
    @Default('Unknown') String location,
    @JsonKey(name: 'session_notes') @Default('') String sessionNotes,
    @JsonKey(name: 'participant_engagement', fromJson: _participantEngagementFromJson, toJson: _participantEngagementToJson)
    required ParticipantEngagement participantEngagement,
    @JsonKey(name: 'goal_progress') @Default([]) List<GoalProgressEntry> goalProgress,
    @JsonKey(name: 'behavior_incidents') @Default([]) List<BehaviorIncident> behaviorIncidents,
    @JsonKey(name: 'media') @Default([]) List<MediaItem> media,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // Enriched fields (from backend query)
    @JsonKey(name: 'activity_title') String? activityTitle,
    @JsonKey(name: 'activity_type') String? activityType,
    @JsonKey(name: 'client_name') String? clientName,
    @JsonKey(name: 'stakeholder_name') String? stakeholderName,
    @JsonKey(name: 'goal_titles') List<String>? goalTitles,
  }) = _ActivitySession;

  factory ActivitySession.fromJson(Map<String, dynamic> json) =>
      _$ActivitySessionFromJson(json);
}

/// Helper to convert double/int to int for duration_minutes
int _durationToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Helper function to convert int to ParticipantEngagement
ParticipantEngagement _participantEngagementFromJson(int value) {
  return ParticipantEngagement.fromValue(value);
}

/// Helper function to convert ParticipantEngagement to int
int _participantEngagementToJson(ParticipantEngagement engagement) {
  return engagement.value;
}

/// Draft session (saved locally before submission)
@freezed
class DraftActivitySession with _$DraftActivitySession {
  const factory DraftActivitySession({
    required String id, // Local UUID
    @JsonKey(name: 'activity_id') required String activityId,
    @JsonKey(name: 'client_id') required String clientId,
    @JsonKey(name: 'user_id') required String stakeholderId,
    @JsonKey(name: 'performed_at') required DateTime performedAt,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'session_notes') String? sessionNotes,
    @JsonKey(name: 'participant_engagement', fromJson: _participantEngagementFromJsonNullable, toJson: _participantEngagementToJsonNullable)
    ParticipantEngagement? participantEngagement,
    @JsonKey(name: 'goal_progress') @Default([]) List<GoalProgressEntry> goalProgress,
    @JsonKey(name: 'behavior_incident_ids') @Default([]) List<String> behaviorIncidentIds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'sync_status', fromJson: _syncStatusFromJson, toJson: _syncStatusToJson)
    required SyncStatus syncStatus,
  }) = _DraftActivitySession;

  factory DraftActivitySession.fromJson(Map<String, dynamic> json) =>
      _$DraftActivitySessionFromJson(json);
}

/// Helper function for nullable ParticipantEngagement
ParticipantEngagement? _participantEngagementFromJsonNullable(int? value) {
  if (value == null) return null;
  return ParticipantEngagement.fromValue(value);
}

/// Helper function for nullable ParticipantEngagement to JSON
int? _participantEngagementToJsonNullable(ParticipantEngagement? engagement) {
  return engagement?.value;
}

/// Helper function to convert string to SyncStatus
SyncStatus _syncStatusFromJson(String value) {
  return SyncStatus.fromString(value);
}

/// Helper function to convert SyncStatus to string
String _syncStatusToJson(SyncStatus status) {
  return status.value;
}
