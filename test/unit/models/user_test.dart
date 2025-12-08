import 'package:flutter_test/flutter_test.dart';
import 'package:agnovat_w/data/models/user.dart';

void main() {
  group('User Model Tests', () {
    final testDateTime = DateTime(2024, 1, 15);
    final lastLoginDateTime = DateTime(2024, 1, 14, 10, 30);

    final testUser = User(
      id: 'user_123',
      clerkId: 'clerk_abc123',
      email: 'john.doe@example.com',
      name: 'John Doe',
      imageUrl: 'https://example.com/avatar.jpg',
      role: UserRole.supportWorker,
      stakeholderId: 'stakeholder_456',
      clientId: 'client_789',
      specialty: 'Behavioral Support',
      active: true,
      createdAt: testDateTime,
      updatedAt: testDateTime,
      lastLogin: lastLoginDateTime,
    );

    group('UserRole Enum', () {
      test('all user roles are defined', () {
        expect(UserRole.values, hasLength(8));
        expect(UserRole.values, contains(UserRole.superAdmin));
        expect(UserRole.values, contains(UserRole.manager));
        expect(UserRole.values, contains(UserRole.supportCoordinator));
        expect(UserRole.values, contains(UserRole.supportWorker));
        expect(UserRole.values, contains(UserRole.therapist));
        expect(UserRole.values, contains(UserRole.behaviorPractitioner));
        expect(UserRole.values, contains(UserRole.family));
        expect(UserRole.values, contains(UserRole.client));
      });

      test('role names are correct', () {
        expect(UserRole.supportWorker.name, equals('supportWorker'));
        expect(UserRole.behaviorPractitioner.name, equals('behaviorPractitioner'));
        expect(UserRole.supportCoordinator.name, equals('supportCoordinator'));
      });
    });

    group('Object Creation', () {
      test('creates user with all fields', () {
        expect(testUser.id, equals('user_123'));
        expect(testUser.clerkId, equals('clerk_abc123'));
        expect(testUser.email, equals('john.doe@example.com'));
        expect(testUser.name, equals('John Doe'));
        expect(testUser.imageUrl, equals('https://example.com/avatar.jpg'));
        expect(testUser.role, equals(UserRole.supportWorker));
        expect(testUser.stakeholderId, equals('stakeholder_456'));
        expect(testUser.clientId, equals('client_789'));
        expect(testUser.specialty, equals('Behavioral Support'));
        expect(testUser.active, isTrue);
        expect(testUser.createdAt, equals(testDateTime));
        expect(testUser.updatedAt, equals(testDateTime));
        expect(testUser.lastLogin, equals(lastLoginDateTime));
      });

      test('creates user with optional fields as null', () {
        final minimalUser = User(
          id: 'user_456',
          clerkId: 'clerk_def456',
          email: 'jane.smith@example.com',
          name: 'Jane Smith',
          role: UserRole.family,
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        expect(minimalUser.imageUrl, isNull);
        expect(minimalUser.stakeholderId, isNull);
        expect(minimalUser.clientId, isNull);
        expect(minimalUser.specialty, isNull);
        expect(minimalUser.lastLogin, isNull);
      });
    });

    group('JSON Serialization', () {
      test('toJson converts user to JSON correctly', () {
        final json = testUser.toJson();

        expect(json['id'], equals('user_123'));
        expect(json['clerk_id'], equals('clerk_abc123'));
        expect(json['email'], equals('john.doe@example.com'));
        expect(json['name'], equals('John Doe'));
        expect(json['image_url'], equals('https://example.com/avatar.jpg'));
        expect(json['role'], equals('supportWorker'));
        expect(json['stakeholder_id'], equals('stakeholder_456'));
        expect(json['client_id'], equals('client_789'));
        expect(json['specialty'], equals('Behavioral Support'));
        expect(json['active'], isTrue);
        expect(json['created_at'], equals(testDateTime.toIso8601String()));
        expect(json['updated_at'], equals(testDateTime.toIso8601String()));
        expect(json['last_login'], equals(lastLoginDateTime.toIso8601String()));
      });

      test('toJson handles null fields correctly', () {
        final minimalUser = User(
          id: 'user_789',
          clerkId: 'clerk_ghi789',
          email: 'bob@example.com',
          name: 'Bob',
          role: UserRole.client,
          active: false,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final json = minimalUser.toJson();

        expect(json['image_url'], isNull);
        expect(json['stakeholder_id'], isNull);
        expect(json['client_id'], isNull);
        expect(json['specialty'], isNull);
        expect(json['last_login'], isNull);
        expect(json['active'], isFalse);
      });

      test('toJson serializes all role types correctly', () {
        for (final role in UserRole.values) {
          final user = User(
            id: 'test',
            clerkId: 'clerk',
            email: 'test@example.com',
            name: 'Test',
            role: role,
            active: true,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          final json = user.toJson();
          expect(json['role'], equals(role.name));
        }
      });
    });

    group('JSON Deserialization', () {
      test('fromJson creates user from JSON correctly', () {
        final json = {
          'id': 'user_999',
          'clerk_id': 'clerk_xyz999',
          'email': 'alice@example.com',
          'name': 'Alice Wonder',
          'image_url': 'https://example.com/alice.jpg',
          'role': 'behaviorPractitioner',
          'stakeholder_id': 'stakeholder_111',
          'client_id': 'client_222',
          'specialty': 'Speech Therapy',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
          'last_login': lastLoginDateTime.toIso8601String(),
        };

        final user = User.fromJson(json);

        expect(user.id, equals('user_999'));
        expect(user.clerkId, equals('clerk_xyz999'));
        expect(user.email, equals('alice@example.com'));
        expect(user.name, equals('Alice Wonder'));
        expect(user.imageUrl, equals('https://example.com/alice.jpg'));
        expect(user.role, equals(UserRole.behaviorPractitioner));
        expect(user.stakeholderId, equals('stakeholder_111'));
        expect(user.clientId, equals('client_222'));
        expect(user.specialty, equals('Speech Therapy'));
        expect(user.active, isTrue);
        expect(user.createdAt, equals(testDateTime));
        expect(user.updatedAt, equals(testDateTime));
        expect(user.lastLogin, equals(lastLoginDateTime));
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'id': 'user_minimal',
          'clerk_id': 'clerk_minimal',
          'email': 'minimal@example.com',
          'name': 'Minimal User',
          'active': false,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        final user = User.fromJson(json);

        expect(user.id, equals('user_minimal'));
        expect(user.email, equals('minimal@example.com'));
        expect(user.imageUrl, isNull);
        expect(user.stakeholderId, isNull);
        expect(user.clientId, isNull);
        expect(user.specialty, isNull);
        expect(user.lastLogin, isNull);
        // Defaults to supportWorker when role is missing
        expect(user.role, equals(UserRole.supportWorker));
      });

      test('fromJson normalizes snake_case roles to camelCase', () {
        final testCases = {
          'support_worker': UserRole.supportWorker,
          'behavior_practitioner': UserRole.behaviorPractitioner,
          'support_coordinator': UserRole.supportCoordinator,
          'super_admin': UserRole.superAdmin,
        };

        for (final entry in testCases.entries) {
          final json = {
            'id': 'test',
            'clerk_id': 'clerk',
            'email': 'test@example.com',
            'name': 'Test',
            'role': entry.key,
            'active': true,
            'created_at': testDateTime.toIso8601String(),
            'updated_at': testDateTime.toIso8601String(),
          };

          final user = User.fromJson(json);
          expect(user.role, equals(entry.value),
            reason: 'Failed to normalize ${entry.key} to ${entry.value}');
        }
      });

      test('fromJson defaults to supportWorker for unknown role', () {
        final json = {
          'id': 'test',
          'clerk_id': 'clerk',
          'email': 'test@example.com',
          'name': 'Test',
          'role': 'unknownRole',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        final user = User.fromJson(json);
        expect(user.role, equals(UserRole.supportWorker));
      });

      test('fromJson handles camelCase roles correctly', () {
        final testCases = [
          'supportWorker',
          'behaviorPractitioner',
          'supportCoordinator',
          'superAdmin',
          'manager',
          'therapist',
          'family',
          'client',
        ];

        for (final roleStr in testCases) {
          final json = {
            'id': 'test',
            'clerk_id': 'clerk',
            'email': 'test@example.com',
            'name': 'Test',
            'role': roleStr,
            'active': true,
            'created_at': testDateTime.toIso8601String(),
            'updated_at': testDateTime.toIso8601String(),
          };

          final user = User.fromJson(json);
          expect(user.role.name, equals(roleStr));
        }
      });
    });

    group('copyWith Method', () {
      test('copyWith creates modified copy', () {
        final updated = testUser.copyWith(
          name: 'John Updated',
          active: false,
          role: UserRole.behaviorPractitioner,
        );

        expect(updated.id, equals(testUser.id));
        expect(updated.clerkId, equals(testUser.clerkId));
        expect(updated.name, equals('John Updated'));
        expect(updated.active, isFalse);
        expect(updated.role, equals(UserRole.behaviorPractitioner));
        expect(updated.email, equals(testUser.email));
      });

      test('copyWith with no parameters returns equal copy', () {
        final copy = testUser.copyWith();

        expect(copy, equals(testUser));
        expect(copy.id, equals(testUser.id));
        expect(copy.name, equals(testUser.name));
        expect(copy.role, equals(testUser.role));
      });

      test('copyWith can set all fields', () {
        final newDateTime = DateTime(2024, 12, 1);
        final updated = testUser.copyWith(
          id: 'new_id',
          clerkId: 'new_clerk',
          email: 'new@example.com',
          name: 'New Name',
          imageUrl: 'https://new.url',
          role: UserRole.manager,
          stakeholderId: 'new_stakeholder',
          clientId: 'new_client',
          specialty: 'New Specialty',
          active: false,
          createdAt: newDateTime,
          updatedAt: newDateTime,
          lastLogin: newDateTime,
        );

        expect(updated.id, equals('new_id'));
        expect(updated.clerkId, equals('new_clerk'));
        expect(updated.email, equals('new@example.com'));
        expect(updated.name, equals('New Name'));
        expect(updated.imageUrl, equals('https://new.url'));
        expect(updated.role, equals(UserRole.manager));
        expect(updated.stakeholderId, equals('new_stakeholder'));
        expect(updated.clientId, equals('new_client'));
        expect(updated.specialty, equals('New Specialty'));
        expect(updated.active, isFalse);
        expect(updated.createdAt, equals(newDateTime));
        expect(updated.updatedAt, equals(newDateTime));
        expect(updated.lastLogin, equals(newDateTime));
      });
    });

    group('Equality (Equatable)', () {
      test('two users with same properties are equal', () {
        final user1 = User(
          id: 'same_id',
          clerkId: 'same_clerk',
          email: 'same@example.com',
          name: 'Same Name',
          role: UserRole.supportWorker,
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final user2 = User(
          id: 'same_id',
          clerkId: 'same_clerk',
          email: 'same@example.com',
          name: 'Same Name',
          role: UserRole.supportWorker,
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('two users with different properties are not equal', () {
        final user1 = testUser;
        final user2 = testUser.copyWith(name: 'Different Name');

        expect(user1, isNot(equals(user2)));
      });

      test('users with different roles are not equal', () {
        final user1 = testUser;
        final user2 = testUser.copyWith(role: UserRole.manager);

        expect(user1, isNot(equals(user2)));
      });
    });

    group('Round-trip Serialization', () {
      test('user survives JSON round-trip', () {
        final json = testUser.toJson();
        final deserialized = User.fromJson(json);

        expect(deserialized, equals(testUser));
        expect(deserialized.id, equals(testUser.id));
        expect(deserialized.role, equals(testUser.role));
        expect(deserialized.email, equals(testUser.email));
      });

      test('all user roles survive JSON round-trip', () {
        for (final role in UserRole.values) {
          final user = User(
            id: 'test',
            clerkId: 'clerk',
            email: 'test@example.com',
            name: 'Test',
            role: role,
            active: true,
            createdAt: testDateTime,
            updatedAt: testDateTime,
          );

          final json = user.toJson();
          final deserialized = User.fromJson(json);

          expect(deserialized.role, equals(role));
          expect(deserialized, equals(user));
        }
      });
    });
  });
}
