import 'package:equatable/equatable.dart';

/// Activity types
enum ActivityType {
  lifeSkills,
  socialRecreation,
  personalCare,
  communityAccess,
  transport,
  therapy,
  householdTasks,
  employmentEducation,
  communication,
  other,
}

/// Activity status
enum ActivityStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
}

/// Activity model
class Activity extends Equatable {
  final String id;
  final String clientId;
  final String stakeholderId;
  final String title;
  final String? description;
  final ActivityType activityType;
  final ActivityStatus status;
  final List<String>? goalIds;
  final String? outcomeNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Activity({
    required this.id,
    required this.clientId,
    required this.stakeholderId,
    required this.title,
    this.description,
    required this.activityType,
    required this.status,
    this.goalIds,
    this.outcomeNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Copy with method
  Activity copyWith({
    String? id,
    String? clientId,
    String? stakeholderId,
    String? title,
    String? description,
    ActivityType? activityType,
    ActivityStatus? status,
    List<String>? goalIds,
    String? outcomeNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      stakeholderId: stakeholderId ?? this.stakeholderId,
      title: title ?? this.title,
      description: description ?? this.description,
      activityType: activityType ?? this.activityType,
      status: status ?? this.status,
      goalIds: goalIds ?? this.goalIds,
      outcomeNotes: outcomeNotes ?? this.outcomeNotes,
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
      'title': title,
      'description': description,
      'activity_type': activityType.name,
      'status': status.name,
      'goal_ids': goalIds,
      'outcome_notes': outcomeNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      stakeholderId: json['stakeholder_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      activityType: _parseActivityType(json['activity_type'] as String),
      status: _parseActivityStatus(json['status'] as String),
      goalIds: (json['goal_ids'] as List?)?.cast<String>(),
      outcomeNotes: json['outcome_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static ActivityType _parseActivityType(String type) {
    return ActivityType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ActivityType.other,
    );
  }

  static ActivityStatus _parseActivityStatus(String status) {
    return ActivityStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ActivityStatus.scheduled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        stakeholderId,
        title,
        description,
        activityType,
        status,
        goalIds,
        outcomeNotes,
        createdAt,
        updatedAt,
      ];
}

/// Activity type extensions for display
extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.lifeSkills:
        return 'Life Skills';
      case ActivityType.socialRecreation:
        return 'Social & Recreation';
      case ActivityType.personalCare:
        return 'Personal Care';
      case ActivityType.communityAccess:
        return 'Community Access';
      case ActivityType.transport:
        return 'Transport';
      case ActivityType.therapy:
        return 'Therapy';
      case ActivityType.householdTasks:
        return 'Household Tasks';
      case ActivityType.employmentEducation:
        return 'Employment & Education';
      case ActivityType.communication:
        return 'Communication';
      case ActivityType.other:
        return 'Other';
    }
  }
}

/// Activity status extensions for display
extension ActivityStatusExtension on ActivityStatus {
  String get displayName {
    switch (this) {
      case ActivityStatus.scheduled:
        return 'Scheduled';
      case ActivityStatus.inProgress:
        return 'In Progress';
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.cancelled:
        return 'Cancelled';
      case ActivityStatus.noShow:
        return 'No Show';
    }
  }
}
