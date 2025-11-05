import 'package:equatable/equatable.dart';

/// Goal progress entry for shift notes
class GoalProgress extends Equatable {
  final String goalId;
  final String progressNotes;
  final int progressObserved; // 1-10 scale

  const GoalProgress({
    required this.goalId,
    required this.progressNotes,
    required this.progressObserved,
  });

  Map<String, dynamic> toJson() {
    return {
      'goal_id': goalId,
      'progress_notes': progressNotes,
      'progress_observed': progressObserved,
    };
  }

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      goalId: json['goal_id'] as String,
      progressNotes: json['progress_notes'] as String,
      progressObserved: json['progress_observed'] as int,
    );
  }

  @override
  List<Object?> get props => [goalId, progressNotes, progressObserved];
}

/// Shift Note model
class ShiftNote extends Equatable {
  final String id;
  final String clientId;
  final String stakeholderId;
  final String shiftDate; // ISO format: YYYY-MM-DD
  final String startTime; // HH:MM (24-hour)
  final String endTime; // HH:MM (24-hour)
  final List<String>? primaryLocations;
  final String rawNotes;
  final String? formattedNote;
  final List<String>? activityIds;
  final List<GoalProgress>? goalsProgress;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShiftNote({
    required this.id,
    required this.clientId,
    required this.stakeholderId,
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
    this.primaryLocations,
    required this.rawNotes,
    this.formattedNote,
    this.activityIds,
    this.goalsProgress,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if this shift note can be edited (within 24 hours)
  bool get canEdit {
    final shiftDateTime = DateTime.parse(shiftDate);
    final hoursSinceShift = DateTime.now().difference(shiftDateTime).inHours;
    return hoursSinceShift < 24;
  }

  /// Get hours remaining until edit window closes
  int get hoursUntilEditExpires {
    final shiftDateTime = DateTime.parse(shiftDate);
    final hoursSinceShift = DateTime.now().difference(shiftDateTime).inHours;
    return 24 - hoursSinceShift;
  }

  /// Copy with method
  ShiftNote copyWith({
    String? id,
    String? clientId,
    String? stakeholderId,
    String? shiftDate,
    String? startTime,
    String? endTime,
    List<String>? primaryLocations,
    String? rawNotes,
    String? formattedNote,
    List<String>? activityIds,
    List<GoalProgress>? goalsProgress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftNote(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      stakeholderId: stakeholderId ?? this.stakeholderId,
      shiftDate: shiftDate ?? this.shiftDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      primaryLocations: primaryLocations ?? this.primaryLocations,
      rawNotes: rawNotes ?? this.rawNotes,
      formattedNote: formattedNote ?? this.formattedNote,
      activityIds: activityIds ?? this.activityIds,
      goalsProgress: goalsProgress ?? this.goalsProgress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'stakeholder_id': stakeholderId,
      'shift_date': shiftDate,
      'start_time': startTime,
      'end_time': endTime,
      'primary_locations': primaryLocations,
      'raw_notes': rawNotes,
      'formatted_note': formattedNote,
      'activity_ids': activityIds,
      'goals_progress': goalsProgress?.map((g) => g.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ShiftNote.fromJson(Map<String, dynamic> json) {
    return ShiftNote(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      stakeholderId: json['stakeholder_id'] as String,
      shiftDate: json['shift_date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      primaryLocations: (json['primary_locations'] as List?)?.cast<String>(),
      rawNotes: json['raw_notes'] as String,
      formattedNote: json['formatted_note'] as String?,
      activityIds: (json['activity_ids'] as List?)?.cast<String>(),
      goalsProgress: (json['goals_progress'] as List?)
          ?.map((g) => GoalProgress.fromJson(g as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        stakeholderId,
        shiftDate,
        startTime,
        endTime,
        primaryLocations,
        rawNotes,
        formattedNote,
        activityIds,
        goalsProgress,
        createdAt,
        updatedAt,
      ];
}
