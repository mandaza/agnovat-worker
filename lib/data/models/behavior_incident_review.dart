import 'package:equatable/equatable.dart';

/// Review Status
enum ReviewStatus {
  draft,
  submitted,
  acknowledged;

  String toJson() => name;

  static ReviewStatus fromJson(String value) {
    return ReviewStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ReviewStatus.draft,
    );
  }

  String get displayName {
    switch (this) {
      case ReviewStatus.draft:
        return 'Draft';
      case ReviewStatus.submitted:
        return 'Submitted';
      case ReviewStatus.acknowledged:
        return 'Acknowledged';
    }
  }
}

/// Severity Assessment (includes critical level)
enum SeverityAssessment {
  low,
  medium,
  high,
  critical;

  String toJson() => name;

  static SeverityAssessment fromJson(String value) {
    return SeverityAssessment.values.firstWhere(
      (severity) => severity.name == value,
      orElse: () => SeverityAssessment.medium,
    );
  }

  String get displayName {
    switch (this) {
      case SeverityAssessment.low:
        return 'Low';
      case SeverityAssessment.medium:
        return 'Medium';
      case SeverityAssessment.high:
        return 'High';
      case SeverityAssessment.critical:
        return 'Critical';
    }
  }
}

/// Behavior Incident Review Status (on the incident itself)
enum IncidentReviewStatus {
  pending,
  reviewed,
  requiresAction;

  String toJson() {
    switch (this) {
      case IncidentReviewStatus.pending:
        return 'pending';
      case IncidentReviewStatus.reviewed:
        return 'reviewed';
      case IncidentReviewStatus.requiresAction:
        return 'requires_action';
    }
  }

  static IncidentReviewStatus fromJson(String value) {
    switch (value) {
      case 'pending':
        return IncidentReviewStatus.pending;
      case 'reviewed':
        return IncidentReviewStatus.reviewed;
      case 'requires_action':
        return IncidentReviewStatus.requiresAction;
      default:
        return IncidentReviewStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case IncidentReviewStatus.pending:
        return 'Pending Review';
      case IncidentReviewStatus.reviewed:
        return 'Reviewed';
      case IncidentReviewStatus.requiresAction:
        return 'Requires Action';
    }
  }
}

/// Behavior Incident Review model
/// Created by behavior practitioners to review incidents submitted by support workers
class BehaviorIncidentReview extends Equatable {
  final String id;
  final String behaviorIncidentId;
  final String clientId;
  final String reviewerId; // Practitioner ID
  final String reviewerName; // From backend enrichment

  // Review content
  final String comments;
  final String recommendations;
  final SeverityAssessment severityAssessment;
  final bool followUpRequired;
  final String? followUpNotes;

  // Status
  final ReviewStatus status;

  // Acknowledgment
  final String? acknowledgedBy; // Support worker ID
  final String? acknowledgedByName; // From backend enrichment
  final DateTime? acknowledgedAt;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  // Enriched incident details (from backend)
  final Map<String, dynamic>? incidentDetails;

  const BehaviorIncidentReview({
    required this.id,
    required this.behaviorIncidentId,
    required this.clientId,
    required this.reviewerId,
    required this.reviewerName,
    required this.comments,
    required this.recommendations,
    required this.severityAssessment,
    required this.followUpRequired,
    this.followUpNotes,
    this.status = ReviewStatus.draft,
    this.acknowledgedBy,
    this.acknowledgedByName,
    this.acknowledgedAt,
    required this.createdAt,
    required this.updatedAt,
    this.incidentDetails,
  });

  /// Check if this is a draft
  bool get isDraft => status == ReviewStatus.draft;

  /// Check if this is submitted
  bool get isSubmitted => status == ReviewStatus.submitted;

  /// Check if this is acknowledged
  bool get isAcknowledged => status == ReviewStatus.acknowledged;

  /// Check if this is unacknowledged (submitted but not acknowledged)
  bool get isUnacknowledged => status == ReviewStatus.submitted;

  /// Check if this review can be edited
  bool get canEdit => status == ReviewStatus.draft;

  /// Check if this review can be submitted
  bool get canSubmit => status == ReviewStatus.draft &&
                        comments.trim().isNotEmpty &&
                        recommendations.trim().isNotEmpty;

  /// Check if this review can be acknowledged
  bool get canAcknowledge => status == ReviewStatus.submitted;

  /// Check if this is a critical review
  bool get isCritical => severityAssessment == SeverityAssessment.critical;

  /// Create from Convex JSON response
  factory BehaviorIncidentReview.fromJson(Map<String, dynamic> json) {
    return BehaviorIncidentReview(
      id: json['id'] as String,
      behaviorIncidentId: json['behavior_incident_id'] as String,
      clientId: json['client_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewerName: json['reviewer_name'] as String? ?? 'Unknown Reviewer',
      comments: json['comments'] as String,
      recommendations: json['recommendations'] as String,
      severityAssessment: SeverityAssessment.fromJson(json['severity_assessment'] as String),
      followUpRequired: json['follow_up_required'] as bool,
      followUpNotes: json['follow_up_notes'] as String?,
      status: json['status'] != null
          ? ReviewStatus.fromJson(json['status'] as String)
          : ReviewStatus.draft,
      acknowledgedBy: json['acknowledged_by'] as String?,
      acknowledgedByName: json['acknowledged_by_name'] as String?,
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      incidentDetails: json['incident_details'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON for Convex mutations (only include required fields for create/update)
  Map<String, dynamic> toJson() {
    return {
      'behavior_incident_id': behaviorIncidentId,
      'client_id': clientId,
      'reviewer_id': reviewerId,
      'comments': comments,
      'recommendations': recommendations,
      'severity_assessment': severityAssessment.name,
      'follow_up_required': followUpRequired,
      if (followUpNotes != null) 'follow_up_notes': followUpNotes,
      'status': status.toJson(),
      if (acknowledgedBy != null) 'acknowledged_by': acknowledgedBy,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt!.toIso8601String(),
    };
  }

  BehaviorIncidentReview copyWith({
    String? id,
    String? behaviorIncidentId,
    String? clientId,
    String? reviewerId,
    String? reviewerName,
    String? comments,
    String? recommendations,
    SeverityAssessment? severityAssessment,
    bool? followUpRequired,
    String? followUpNotes,
    ReviewStatus? status,
    String? acknowledgedBy,
    String? acknowledgedByName,
    DateTime? acknowledgedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? incidentDetails,
  }) {
    return BehaviorIncidentReview(
      id: id ?? this.id,
      behaviorIncidentId: behaviorIncidentId ?? this.behaviorIncidentId,
      clientId: clientId ?? this.clientId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      comments: comments ?? this.comments,
      recommendations: recommendations ?? this.recommendations,
      severityAssessment: severityAssessment ?? this.severityAssessment,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      followUpNotes: followUpNotes ?? this.followUpNotes,
      status: status ?? this.status,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedByName: acknowledgedByName ?? this.acknowledgedByName,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      incidentDetails: incidentDetails ?? this.incidentDetails,
    );
  }

  @override
  List<Object?> get props => [
        id,
        behaviorIncidentId,
        clientId,
        reviewerId,
        reviewerName,
        comments,
        recommendations,
        severityAssessment,
        followUpRequired,
        followUpNotes,
        status,
        acknowledgedBy,
        acknowledgedByName,
        acknowledgedAt,
        createdAt,
        updatedAt,
        incidentDetails,
      ];
}

/// Review Summary Statistics
class ReviewSummary extends Equatable {
  final int totalReviews;
  final int pendingAcknowledgment;
  final int requiringFollowUp;
  final Map<String, int> bySeverity;

  const ReviewSummary({
    required this.totalReviews,
    required this.pendingAcknowledgment,
    required this.requiringFollowUp,
    required this.bySeverity,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      pendingAcknowledgment: (json['pending_acknowledgment'] as num?)?.toInt() ?? 0,
      requiringFollowUp: (json['requiring_follow_up'] as num?)?.toInt() ?? 0,
      bySeverity: (json['by_severity'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ) ??
          {},
    );
  }

  @override
  List<Object?> get props => [
        totalReviews,
        pendingAcknowledgment,
        requiringFollowUp,
        bySeverity,
      ];
}
