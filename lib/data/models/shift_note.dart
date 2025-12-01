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
      progressObserved: (json['progress_observed'] as num).toInt(),
    );
  }

  @override
  List<Object?> get props => [goalId, progressNotes, progressObserved];
}

/// Shift Note Status
enum ShiftNoteStatus {
  draft,
  submitted;

  String toJson() => name;

  static ShiftNoteStatus fromJson(String value) {
    return ShiftNoteStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ShiftNoteStatus.draft,
    );
  }
}

/// Shift Note model
class ShiftNote extends Equatable {
  final String id;
  final String clientId;
  final String userId;
  final String shiftDate; // ISO format: YYYY-MM-DD
  final String startTime; // HH:MM (24-hour)
  final String endTime; // HH:MM (24-hour)
  final ShiftNoteStatus status; // draft or submitted
  final DateTime? submittedAt; // When the note was submitted
  final List<String>? primaryLocations;
  final String rawNotes;
  final List<String>? activityIds;
  final List<GoalProgress>? goalsProgress;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShiftNote({
    required this.id,
    required this.clientId,
    required this.userId,
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
    this.status = ShiftNoteStatus.draft,
    this.submittedAt,
    this.primaryLocations,
    required this.rawNotes,
    this.activityIds,
    this.goalsProgress,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if this is a draft
  bool get isDraft => status == ShiftNoteStatus.draft;

  /// Check if this is submitted
  bool get isSubmitted => status == ShiftNoteStatus.submitted;

  /// Check if this shift note can be edited
  /// - Drafts can always be edited
  /// - Submitted notes can only be edited within 24 hours of shift date
  bool get canEdit {
    if (isDraft) return true;

    final shiftDateTime = DateTime.parse(shiftDate);
    final hoursSinceShift = DateTime.now().difference(shiftDateTime).inHours;
    return hoursSinceShift < 24;
  }

  /// Check if this shift note can be deleted
  /// - Drafts can always be deleted
  /// - Submitted notes can only be deleted within 24 hours of shift date
  bool get canDelete {
    if (isDraft) return true;

    final shiftDateTime = DateTime.parse(shiftDate);
    final hoursSinceShift = DateTime.now().difference(shiftDateTime).inHours;
    return hoursSinceShift < 24;
  }

  /// Check if this shift note can be submitted
  bool get canSubmit => isDraft && rawNotes.trim().isNotEmpty;

  /// Get hours remaining until edit window closes (for submitted notes)
  int? get hoursUntilEditExpires {
    if (isDraft) return null;

    final shiftDateTime = DateTime.parse(shiftDate);
    final hoursSinceShift = DateTime.now().difference(shiftDateTime).inHours;
    final remaining = 24 - hoursSinceShift;
    return remaining > 0 ? remaining : 0;
  }

  /// Copy with method
  ShiftNote copyWith({
    String? id,
    String? clientId,
    String? userId,
    String? shiftDate,
    String? startTime,
    String? endTime,
    ShiftNoteStatus? status,
    DateTime? submittedAt,
    List<String>? primaryLocations,
    String? rawNotes,
    List<String>? activityIds,
    List<GoalProgress>? goalsProgress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftNote(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      shiftDate: shiftDate ?? this.shiftDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      primaryLocations: primaryLocations ?? this.primaryLocations,
      rawNotes: rawNotes ?? this.rawNotes,
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
      'user_id': userId,
      'shift_date': shiftDate,
      'start_time': startTime,
      'end_time': endTime,
      'status': status.toJson(),
      'submitted_at': submittedAt?.toIso8601String(),
      'primary_locations': primaryLocations,
      'raw_notes': rawNotes,
      'activity_ids': activityIds,
      'goals_progress': goalsProgress?.map((g) => g.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ShiftNote.fromJson(Map<String, dynamic> json) {
    // Helper to safely get string value with fallback
    String getString(String key, [String fallback = '']) {
      final value = json[key];
      if (value == null) return fallback;
      return value.toString();
    }

    return ShiftNote(
      id: getString('_id', getString('id')),
      clientId: getString('client_id'),
      userId: getString('user_id'),
      shiftDate: getString('shift_date'),
      startTime: getString('start_time', '00:00'),
      endTime: getString('end_time', '00:00'),
      status: json['status'] != null
          ? ShiftNoteStatus.fromJson(json['status'] as String)
          : ShiftNoteStatus.draft,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      primaryLocations: (json['primary_locations'] as List?)?.cast<String>(),
      rawNotes: getString('raw_notes'),
      activityIds: (json['activity_ids'] as List?)?.cast<String>(),
      goalsProgress: (json['goals_progress'] as List?)
          ?.map((g) => GoalProgress.fromJson(g as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        userId,
        shiftDate,
        startTime,
        endTime,
        status,
        submittedAt,
        primaryLocations,
        rawNotes,
        activityIds,
        goalsProgress,
        createdAt,
        updatedAt,
      ];
}
