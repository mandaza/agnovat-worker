import 'package:equatable/equatable.dart';

/// Goal status
enum GoalStatus {
  notStarted,
  inProgress,
  achieved,
  onHold,
  discontinued,
}

/// Goal category
enum GoalCategory {
  dailyLiving,
  socialCommunity,
  employment,
  healthWellbeing,
  homeLiving,
  relationships,
  choiceControl,
  other,
}

/// Goal model
class Goal extends Equatable {
  final String id;
  final String clientId;
  final String title;
  final String description;
  final GoalCategory category;
  final String targetDate; // ISO format: YYYY-MM-DD
  final GoalStatus status;
  final int progressPercentage; // 0-100
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? achievedAt;
  final bool archived;

  const Goal({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    required this.status,
    required this.progressPercentage,
    required this.createdAt,
    required this.updatedAt,
    this.achievedAt,
    required this.archived,
  });

  /// Copy with method
  Goal copyWith({
    String? id,
    String? clientId,
    String? title,
    String? description,
    GoalCategory? category,
    String? targetDate,
    GoalStatus? status,
    int? progressPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? achievedAt,
    bool? archived,
  }) {
    return Goal(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      achievedAt: achievedAt ?? this.achievedAt,
      archived: archived ?? this.archived,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'title': title,
      'description': description,
      'category': category.name,
      'target_date': targetDate,
      'status': status.name,
      'progress_percentage': progressPercentage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'achieved_at': achievedAt?.toIso8601String(),
      'archived': archived,
    };
  }

  /// Create from JSON
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: _parseGoalCategory(json['category'] as String),
      targetDate: json['target_date'] as String,
      status: _parseGoalStatus(json['status'] as String),
      progressPercentage: (json['progress_percentage'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      achievedAt: json['achieved_at'] != null
          ? DateTime.parse(json['achieved_at'] as String)
          : null,
      archived: json['archived'] as bool,
    );
  }

  static GoalCategory _parseGoalCategory(String category) {
    return GoalCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => GoalCategory.other,
    );
  }

  static GoalStatus _parseGoalStatus(String status) {
    return GoalStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => GoalStatus.notStarted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        title,
        description,
        category,
        targetDate,
        status,
        progressPercentage,
        createdAt,
        updatedAt,
        achievedAt,
        archived,
      ];
}

/// Goal category extensions for display
extension GoalCategoryExtension on GoalCategory {
  String get displayName {
    switch (this) {
      case GoalCategory.dailyLiving:
        return 'Daily Living';
      case GoalCategory.socialCommunity:
        return 'Social & Community';
      case GoalCategory.employment:
        return 'Employment';
      case GoalCategory.healthWellbeing:
        return 'Health & Wellbeing';
      case GoalCategory.homeLiving:
        return 'Home Living';
      case GoalCategory.relationships:
        return 'Relationships';
      case GoalCategory.choiceControl:
        return 'Choice & Control';
      case GoalCategory.other:
        return 'Other';
    }
  }
}

/// Goal status extensions for display
extension GoalStatusExtension on GoalStatus {
  String get displayName {
    switch (this) {
      case GoalStatus.notStarted:
        return 'Not Started';
      case GoalStatus.inProgress:
        return 'In Progress';
      case GoalStatus.achieved:
        return 'Achieved';
      case GoalStatus.onHold:
        return 'On Hold';
      case GoalStatus.discontinued:
        return 'Discontinued';
    }
  }
}
