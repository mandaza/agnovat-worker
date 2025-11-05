import 'package:equatable/equatable.dart';

/// Client (NDIS Participant) model
class Client extends Equatable {
  final String id;
  final String name;
  final String dateOfBirth; // ISO format: YYYY-MM-DD
  final String? ndisNumber; // 11 digits
  final String? primaryContact;
  final String? supportNotes;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.ndisNumber,
    this.primaryContact,
    this.supportNotes,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get age from date of birth
  int get age {
    final dob = DateTime.parse(dateOfBirth);
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  /// Copy with method
  Client copyWith({
    String? id,
    String? name,
    String? dateOfBirth,
    String? ndisNumber,
    String? primaryContact,
    String? supportNotes,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      ndisNumber: ndisNumber ?? this.ndisNumber,
      primaryContact: primaryContact ?? this.primaryContact,
      supportNotes: supportNotes ?? this.supportNotes,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth,
      'ndis_number': ndisNumber,
      'primary_contact': primaryContact,
      'support_notes': supportNotes,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      ndisNumber: json['ndis_number'] as String?,
      primaryContact: json['primary_contact'] as String?,
      supportNotes: json['support_notes'] as String?,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        dateOfBirth,
        ndisNumber,
        primaryContact,
        supportNotes,
        active,
        createdAt,
        updatedAt,
      ];
}

/// Client with statistics
class ClientWithStats extends Client {
  final int activeGoalsCount;
  final int totalActivitiesCount;
  final DateTime? lastActivityDate;
  final DateTime? lastShiftNoteDate;

  const ClientWithStats({
    required super.id,
    required super.name,
    required super.dateOfBirth,
    super.ndisNumber,
    super.primaryContact,
    super.supportNotes,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required this.activeGoalsCount,
    required this.totalActivitiesCount,
    this.lastActivityDate,
    this.lastShiftNoteDate,
  });

  factory ClientWithStats.fromJson(Map<String, dynamic> json) {
    return ClientWithStats(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      ndisNumber: json['ndis_number'] as String?,
      primaryContact: json['primary_contact'] as String?,
      supportNotes: json['support_notes'] as String?,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      activeGoalsCount: json['active_goals'] as int? ?? 0,
      totalActivitiesCount: json['total_activities'] as int? ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
      lastShiftNoteDate: json['last_shift_note_date'] != null
          ? DateTime.parse(json['last_shift_note_date'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        activeGoalsCount,
        totalActivitiesCount,
        lastActivityDate,
        lastShiftNoteDate,
      ];
}
