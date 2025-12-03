import 'package:equatable/equatable.dart';

/// User roles in the system
enum UserRole {
  superAdmin,
  manager,
  supportCoordinator,
  supportWorker,
  therapist,
  behaviorPractitioner,
  family,
  client,
}

/// User model
class User extends Equatable {
  final String id;
  final String clerkId;
  final String email;
  final String name;
  final String? imageUrl;
  final UserRole role;
  final String? stakeholderId;
  final String? clientId;
  final String? specialty;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.clerkId,
    required this.email,
    required this.name,
    this.imageUrl,
    required this.role,
    this.stakeholderId,
    this.clientId,
    this.specialty,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  /// Copy with method
  User copyWith({
    String? id,
    String? clerkId,
    String? email,
    String? name,
    String? imageUrl,
    UserRole? role,
    String? stakeholderId,
    String? clientId,
    String? specialty,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      clerkId: clerkId ?? this.clerkId,
      email: email ?? this.email,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      stakeholderId: stakeholderId ?? this.stakeholderId,
      clientId: clientId ?? this.clientId,
      specialty: specialty ?? this.specialty,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clerk_id': clerkId,
      'email': email,
      'name': name,
      'image_url': imageUrl,
      'role': role.name,
      'stakeholder_id': stakeholderId,
      'client_id': clientId,
      'specialty': specialty,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    // Helper to convert snake_case to camelCase for role matching
    String normalizeRoleName(String roleName) {
      // Convert snake_case to camelCase
      if (roleName.contains('_')) {
        final parts = roleName.split('_');
        return parts[0] + parts.sublist(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
      }
      return roleName;
    }

    final roleString = (json['role'] as String?) ?? 'supportWorker';
    final normalizedRole = normalizeRoleName(roleString);
    
    return User(
      id: json['id'] as String,
      clerkId: json['clerk_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == normalizedRole,
        orElse: () {
          // Log for debugging
          print('⚠️ Unknown role from database: "$roleString" (normalized: "$normalizedRole"). Defaulting to supportWorker.');
          return UserRole.supportWorker;
        },
      ),
      stakeholderId: json['stakeholder_id'] as String?,
      clientId: json['client_id'] as String?,
      specialty: json['specialty'] as String?,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clerkId,
        email,
        name,
        imageUrl,
        role,
        stakeholderId,
        clientId,
        specialty,
        active,
        createdAt,
        updatedAt,
        lastLogin,
      ];
}
