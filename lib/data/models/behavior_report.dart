import 'package:equatable/equatable.dart';

/// Behavior Report Status
enum BehaviorReportStatus {
  draft,
  submitted;

  String toJson() => name;

  static BehaviorReportStatus fromJson(String value) {
    return BehaviorReportStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => BehaviorReportStatus.draft,
    );
  }
}

/// Behavior severity level
enum BehaviorSeverity {
  low,
  medium,
  high;

  String toJson() => name;

  static BehaviorSeverity fromJson(String value) {
    return BehaviorSeverity.values.firstWhere(
      (severity) => severity.name == value,
      orElse: () => BehaviorSeverity.low,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case BehaviorSeverity.low:
        return 'Low';
      case BehaviorSeverity.medium:
        return 'Medium';
      case BehaviorSeverity.high:
        return 'High';
    }
  }
}

/// Behavior type/category (simplified enum for backward compatibility)
enum BehaviorType {
  verbalAggression,
  physicalAggression,
  selfInjury,
  propertyDestruction,
  elopement,
  wandering,
  withdrawal,
  other;

  String toJson() => _camelToSnake(name);

  static BehaviorType fromJson(String value) {
    final camelValue = _snakeToCamel(value);
    return BehaviorType.values.firstWhere(
      (type) => type.name == camelValue,
      orElse: () => BehaviorType.other,
    );
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case BehaviorType.verbalAggression:
        return 'Verbal Aggression';
      case BehaviorType.physicalAggression:
        return 'Physical Aggression';
      case BehaviorType.selfInjury:
        return 'Self-Injury';
      case BehaviorType.propertyDestruction:
        return 'Property Destruction';
      case BehaviorType.elopement:
        return 'Elopement';
      case BehaviorType.wandering:
        return 'Wandering';
      case BehaviorType.withdrawal:
        return 'Withdrawal';
      case BehaviorType.other:
        return 'Other';
    }
  }

  static String _snakeToCamel(String snake) {
    final parts = snake.split('_');
    if (parts.isEmpty) return snake;
    return parts[0] + parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join('');
  }

  static String _camelToSnake(String camel) {
    return camel.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}

/// Enhanced Behavior Report model matching Convex backend schema
class BehaviorReport extends Equatable {
  final String id;
  final String clientId;
  final String clientName; // From backend enrichment (getById)
  final String workerId; // Maps to submitted_by (stakeholder_id)
  final String workerName; // From backend enrichment (submitter_name)

  // Core incident details
  final DateTime incidentDate;
  final String submittedFor; // 'self' or 'other'
  final String? submittedForName; // Name if submitted for someone else

  // Location
  final String location;
  final String? locationOther;

  // Activity before
  final String activityBefore;
  final String? activityBeforeOther;

  // Behaviors (array of behavior strings from backend)
  final List<String> behaviorsDisplayed;
  final String? behaviorsOther;

  // Duration
  final String duration;
  final String? durationOther;

  // Severity
  final BehaviorSeverity severity;

  // Self harm
  final List<String> selfHarmTypes;
  final String? selfHarmOther;
  final int selfHarmCount;

  // Intervention
  final String initialIntervention;
  final String? interventionDescription;

  // Second support
  final List<String> secondSupportNeeded;
  final String? secondSupportDescription;

  // Description
  final String detailedDescription;

  // Status
  final BehaviorReportStatus status;
  final DateTime? submittedAt;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  // Legacy/convenience fields for backward compatibility
  String get description => detailedDescription;
  String? get antecedent => activityBeforeOther;
  String? get consequence => interventionDescription;
  DateTime get incidentTime => incidentDate;

  BehaviorType get behaviorType {
    if (behaviorsDisplayed.isEmpty) return BehaviorType.other;
    return BehaviorType.fromJson(behaviorsDisplayed.first);
  }

  const BehaviorReport({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.workerId,
    required this.workerName,
    required this.incidentDate,
    required this.submittedFor,
    this.submittedForName,
    required this.location,
    this.locationOther,
    required this.activityBefore,
    this.activityBeforeOther,
    required this.behaviorsDisplayed,
    this.behaviorsOther,
    required this.duration,
    this.durationOther,
    required this.severity,
    required this.selfHarmTypes,
    this.selfHarmOther,
    required this.selfHarmCount,
    required this.initialIntervention,
    this.interventionDescription,
    required this.secondSupportNeeded,
    this.secondSupportDescription,
    required this.detailedDescription,
    this.status = BehaviorReportStatus.draft,
    this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if this is a draft
  bool get isDraft => status == BehaviorReportStatus.draft;

  /// Check if this is submitted
  bool get isSubmitted => status == BehaviorReportStatus.submitted;

  /// Check if this behavior report can be edited
  /// Only drafts can be edited
  bool get canEdit => isDraft;

  /// Check if this behavior report can be deleted
  /// Only drafts can be deleted
  bool get canDelete => isDraft;

  /// Check if this behavior report can be submitted
  bool get canSubmit => isDraft && detailedDescription.trim().isNotEmpty;

  /// Create from Convex JSON response
  factory BehaviorReport.fromJson(Map<String, dynamic> json) {
    return BehaviorReport(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String? ?? 'Unknown Client',
      workerId: json['submitted_by'] as String,
      workerName: json['submitter_name'] as String? ?? 'Unknown Worker',

      incidentDate: DateTime.parse(json['incident_date'] as String),
      submittedFor: json['submitted_for'] as String,
      submittedForName: json['submitted_for_name'] as String?,

      location: json['location'] as String,
      locationOther: json['location_other'] as String?,

      activityBefore: json['activity_before'] as String,
      activityBeforeOther: json['activity_before_other'] as String?,

      behaviorsDisplayed: (json['behaviors_displayed'] as List).cast<String>(),
      behaviorsOther: json['behaviors_other'] as String?,

      duration: json['duration'] as String,
      durationOther: json['duration_other'] as String?,

      severity: BehaviorSeverity.fromJson(json['severity'] as String),

      selfHarmTypes: (json['self_harm_types'] as List).cast<String>(),
      selfHarmOther: json['self_harm_other'] as String?,
      selfHarmCount: (json['self_harm_count'] as num).toInt(), // Handle both int and double from JSON

      initialIntervention: json['initial_intervention'] as String,
      interventionDescription: json['intervention_description'] as String?,

      secondSupportNeeded: (json['second_support_needed'] as List).cast<String>(),
      secondSupportDescription: json['second_support_description'] as String?,

      detailedDescription: json['detailed_description'] as String,

      status: json['status'] != null
          ? BehaviorReportStatus.fromJson(json['status'] as String)
          : BehaviorReportStatus.draft,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,

      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Convex mutations (only include required fields for create/update)
  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'submitted_by': workerId,
      'incident_date': incidentDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'submitted_for': submittedFor,
      if (submittedForName != null) 'submitted_for_name': submittedForName,
      'location': location,
      if (locationOther != null) 'location_other': locationOther,
      'activity_before': activityBefore,
      if (activityBeforeOther != null) 'activity_before_other': activityBeforeOther,
      'behaviors_displayed': behaviorsDisplayed,
      if (behaviorsOther != null) 'behaviors_other': behaviorsOther,
      'duration': duration,
      if (durationOther != null) 'duration_other': durationOther,
      'severity': severity.name,
      'self_harm_types': selfHarmTypes,
      if (selfHarmOther != null) 'self_harm_other': selfHarmOther,
      'self_harm_count': selfHarmCount,
      'initial_intervention': initialIntervention,
      if (interventionDescription != null) 'intervention_description': interventionDescription,
      'second_support_needed': secondSupportNeeded,
      if (secondSupportDescription != null) 'second_support_description': secondSupportDescription,
      'detailed_description': detailedDescription,
      'status': status.toJson(),
      if (submittedAt != null) 'submitted_at': submittedAt!.toIso8601String(),
    };
  }

  BehaviorReport copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? workerId,
    String? workerName,
    DateTime? incidentDate,
    String? submittedFor,
    String? submittedForName,
    String? location,
    String? locationOther,
    String? activityBefore,
    String? activityBeforeOther,
    List<String>? behaviorsDisplayed,
    String? behaviorsOther,
    String? duration,
    String? durationOther,
    BehaviorSeverity? severity,
    List<String>? selfHarmTypes,
    String? selfHarmOther,
    int? selfHarmCount,
    String? initialIntervention,
    String? interventionDescription,
    List<String>? secondSupportNeeded,
    String? secondSupportDescription,
    String? detailedDescription,
    BehaviorReportStatus? status,
    DateTime? submittedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BehaviorReport(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      incidentDate: incidentDate ?? this.incidentDate,
      submittedFor: submittedFor ?? this.submittedFor,
      submittedForName: submittedForName ?? this.submittedForName,
      location: location ?? this.location,
      locationOther: locationOther ?? this.locationOther,
      activityBefore: activityBefore ?? this.activityBefore,
      activityBeforeOther: activityBeforeOther ?? this.activityBeforeOther,
      behaviorsDisplayed: behaviorsDisplayed ?? this.behaviorsDisplayed,
      behaviorsOther: behaviorsOther ?? this.behaviorsOther,
      duration: duration ?? this.duration,
      durationOther: durationOther ?? this.durationOther,
      severity: severity ?? this.severity,
      selfHarmTypes: selfHarmTypes ?? this.selfHarmTypes,
      selfHarmOther: selfHarmOther ?? this.selfHarmOther,
      selfHarmCount: selfHarmCount ?? this.selfHarmCount,
      initialIntervention: initialIntervention ?? this.initialIntervention,
      interventionDescription: interventionDescription ?? this.interventionDescription,
      secondSupportNeeded: secondSupportNeeded ?? this.secondSupportNeeded,
      secondSupportDescription: secondSupportDescription ?? this.secondSupportDescription,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        clientName,
        workerId,
        workerName,
        incidentDate,
        submittedFor,
        submittedForName,
        location,
        locationOther,
        activityBefore,
        activityBeforeOther,
        behaviorsDisplayed,
        behaviorsOther,
        duration,
        durationOther,
        severity,
        selfHarmTypes,
        selfHarmOther,
        selfHarmCount,
        initialIntervention,
        interventionDescription,
        secondSupportNeeded,
        secondSupportDescription,
        detailedDescription,
        status,
        submittedAt,
        createdAt,
        updatedAt,
      ];
}
