import 'package:flutter_test/flutter_test.dart';
import 'package:agnovat_w/data/models/client.dart';

void main() {
  group('Client Model Tests', () {
    final testDateTime = DateTime(2024, 1, 15);

    final testClient = Client(
      id: 'client_123',
      name: 'John Doe',
      dateOfBirth: '1990-05-15',
      ndisNumber: '12345678901',
      primaryContact: 'Jane Doe (Mother)',
      supportNotes: 'Requires assistance with daily activities',
      imageUrl: 'https://example.com/profile.jpg',
      active: true,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

    group('Object Creation', () {
      test('creates client with all fields', () {
        expect(testClient.id, equals('client_123'));
        expect(testClient.name, equals('John Doe'));
        expect(testClient.dateOfBirth, equals('1990-05-15'));
        expect(testClient.ndisNumber, equals('12345678901'));
        expect(testClient.primaryContact, equals('Jane Doe (Mother)'));
        expect(testClient.supportNotes, equals('Requires assistance with daily activities'));
        expect(testClient.imageUrl, equals('https://example.com/profile.jpg'));
        expect(testClient.active, isTrue);
        expect(testClient.createdAt, equals(testDateTime));
        expect(testClient.updatedAt, equals(testDateTime));
      });

      test('creates client with optional fields as null', () {
        final minimalClient = Client(
          id: 'client_456',
          name: 'Jane Smith',
          dateOfBirth: '1985-03-20',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        expect(minimalClient.ndisNumber, isNull);
        expect(minimalClient.primaryContact, isNull);
        expect(minimalClient.supportNotes, isNull);
        expect(minimalClient.imageUrl, isNull);
      });
    });

    group('Age Calculation', () {
      test('calculates age correctly for past birthday this year', () {
        final client = Client(
          id: 'test',
          name: 'Test',
          dateOfBirth: '1990-01-01', // Already had birthday this year
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final expectedAge = DateTime.now().year - 1990;
        expect(client.age, equals(expectedAge));
      });

      test('calculates age correctly for future birthday this year', () {
        final now = DateTime.now();
        final futureMonth = (now.month % 12) + 1;
        final futureYear = now.year - 30;

        final client = Client(
          id: 'test',
          name: 'Test',
          dateOfBirth: '$futureYear-${futureMonth.toString().padLeft(2, '0')}-15',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // If birthday hasn't occurred yet this year, age should be one less
        final basedAge = now.year - futureYear;
        final expectedAge = (now.month < futureMonth) ? basedAge - 1 : basedAge;

        expect(client.age, equals(expectedAge));
      });

      test('calculates age for someone born today', () {
        final today = DateTime.now();
        final client = Client(
          id: 'test',
          name: 'Test',
          dateOfBirth: '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        expect(client.age, equals(0));
      });
    });

    group('JSON Serialization', () {
      test('toJson converts client to JSON correctly', () {
        final json = testClient.toJson();

        expect(json['id'], equals('client_123'));
        expect(json['name'], equals('John Doe'));
        expect(json['date_of_birth'], equals('1990-05-15'));
        expect(json['ndis_number'], equals('12345678901'));
        expect(json['primary_contact'], equals('Jane Doe (Mother)'));
        expect(json['support_notes'], equals('Requires assistance with daily activities'));
        expect(json['image_url'], equals('https://example.com/profile.jpg'));
        expect(json['active'], isTrue);
        expect(json['created_at'], equals(testDateTime.toIso8601String()));
        expect(json['updated_at'], equals(testDateTime.toIso8601String()));
      });

      test('toJson handles null fields correctly', () {
        final minimalClient = Client(
          id: 'client_456',
          name: 'Jane Smith',
          dateOfBirth: '1985-03-20',
          active: false,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final json = minimalClient.toJson();

        expect(json['ndis_number'], isNull);
        expect(json['primary_contact'], isNull);
        expect(json['support_notes'], isNull);
        expect(json['image_url'], isNull);
        expect(json['active'], isFalse);
      });
    });

    group('JSON Deserialization', () {
      test('fromJson creates client from JSON correctly', () {
        final json = {
          'id': 'client_789',
          'name': 'Bob Wilson',
          'date_of_birth': '1995-08-10',
          'ndis_number': '98765432109',
          'primary_contact': 'Sarah Wilson',
          'support_notes': 'Wheelchair accessible',
          'image_url': 'https://example.com/bob.jpg',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        final client = Client.fromJson(json);

        expect(client.id, equals('client_789'));
        expect(client.name, equals('Bob Wilson'));
        expect(client.dateOfBirth, equals('1995-08-10'));
        expect(client.ndisNumber, equals('98765432109'));
        expect(client.primaryContact, equals('Sarah Wilson'));
        expect(client.supportNotes, equals('Wheelchair accessible'));
        expect(client.imageUrl, equals('https://example.com/bob.jpg'));
        expect(client.active, isTrue);
        expect(client.createdAt, equals(testDateTime));
        expect(client.updatedAt, equals(testDateTime));
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'id': 'client_999',
          'name': 'Minimal Client',
          'date_of_birth': '2000-01-01',
          'active': false,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        final client = Client.fromJson(json);

        expect(client.id, equals('client_999'));
        expect(client.name, equals('Minimal Client'));
        expect(client.ndisNumber, isNull);
        expect(client.primaryContact, isNull);
        expect(client.supportNotes, isNull);
        expect(client.imageUrl, isNull);
      });
    });

    group('copyWith Method', () {
      test('copyWith creates modified copy', () {
        final updated = testClient.copyWith(
          name: 'John Updated',
          active: false,
        );

        expect(updated.id, equals(testClient.id));
        expect(updated.name, equals('John Updated'));
        expect(updated.active, isFalse);
        expect(updated.dateOfBirth, equals(testClient.dateOfBirth));
        expect(updated.ndisNumber, equals(testClient.ndisNumber));
      });

      test('copyWith with no parameters returns equal copy', () {
        final copy = testClient.copyWith();

        expect(copy, equals(testClient));
        expect(copy.id, equals(testClient.id));
        expect(copy.name, equals(testClient.name));
      });

      test('copyWith can set all fields', () {
        final newDateTime = DateTime(2024, 12, 1);
        final updated = testClient.copyWith(
          id: 'new_id',
          name: 'New Name',
          dateOfBirth: '2000-01-01',
          ndisNumber: '11111111111',
          primaryContact: 'New Contact',
          supportNotes: 'New Notes',
          imageUrl: 'https://new.url',
          active: false,
          createdAt: newDateTime,
          updatedAt: newDateTime,
        );

        expect(updated.id, equals('new_id'));
        expect(updated.name, equals('New Name'));
        expect(updated.dateOfBirth, equals('2000-01-01'));
        expect(updated.ndisNumber, equals('11111111111'));
        expect(updated.primaryContact, equals('New Contact'));
        expect(updated.supportNotes, equals('New Notes'));
        expect(updated.imageUrl, equals('https://new.url'));
        expect(updated.active, isFalse);
        expect(updated.createdAt, equals(newDateTime));
        expect(updated.updatedAt, equals(newDateTime));
      });
    });

    group('Equality (Equatable)', () {
      test('two clients with same properties are equal', () {
        final client1 = Client(
          id: 'same_id',
          name: 'Same Name',
          dateOfBirth: '1990-01-01',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final client2 = Client(
          id: 'same_id',
          name: 'Same Name',
          dateOfBirth: '1990-01-01',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        expect(client1, equals(client2));
        expect(client1.hashCode, equals(client2.hashCode));
      });

      test('two clients with different properties are not equal', () {
        final client1 = testClient;
        final client2 = testClient.copyWith(name: 'Different Name');

        expect(client1, isNot(equals(client2)));
      });
    });

    group('Round-trip Serialization', () {
      test('client survives JSON round-trip', () {
        final json = testClient.toJson();
        final deserialized = Client.fromJson(json);

        expect(deserialized, equals(testClient));
        expect(deserialized.id, equals(testClient.id));
        expect(deserialized.name, equals(testClient.name));
        expect(deserialized.age, equals(testClient.age));
      });
    });
  });

  group('ClientWithStats Model Tests', () {
    final testDateTime = DateTime(2024, 1, 15);
    final lastActivityDate = DateTime(2024, 1, 10);
    final lastShiftNoteDate = DateTime(2024, 1, 12);

    final testClientWithStats = ClientWithStats(
      id: 'client_stats_123',
      name: 'John Doe',
      dateOfBirth: '1990-05-15',
      ndisNumber: '12345678901',
      active: true,
      createdAt: testDateTime,
      updatedAt: testDateTime,
      activeGoalsCount: 5,
      totalActivitiesCount: 42,
      lastActivityDate: lastActivityDate,
      lastShiftNoteDate: lastShiftNoteDate,
    );

    group('Object Creation', () {
      test('creates client with stats', () {
        expect(testClientWithStats.id, equals('client_stats_123'));
        expect(testClientWithStats.name, equals('John Doe'));
        expect(testClientWithStats.activeGoalsCount, equals(5));
        expect(testClientWithStats.totalActivitiesCount, equals(42));
        expect(testClientWithStats.lastActivityDate, equals(lastActivityDate));
        expect(testClientWithStats.lastShiftNoteDate, equals(lastShiftNoteDate));
      });

      test('creates client with optional stat fields as null', () {
        final minimalStats = ClientWithStats(
          id: 'client_stats_456',
          name: 'Jane Smith',
          dateOfBirth: '1985-03-20',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
          activeGoalsCount: 0,
          totalActivitiesCount: 0,
        );

        expect(minimalStats.lastActivityDate, isNull);
        expect(minimalStats.lastShiftNoteDate, isNull);
      });
    });

    group('JSON Deserialization', () {
      test('fromJson creates client with stats from JSON', () {
        final json = {
          'id': 'client_stats_789',
          'name': 'Bob Wilson',
          'date_of_birth': '1995-08-10',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
          'active_goals': 3,
          'total_activities': 15,
          'last_activity_date': lastActivityDate.toIso8601String(),
          'last_shift_note_date': lastShiftNoteDate.toIso8601String(),
        };

        final client = ClientWithStats.fromJson(json);

        expect(client.id, equals('client_stats_789'));
        expect(client.activeGoalsCount, equals(3));
        expect(client.totalActivitiesCount, equals(15));
        expect(client.lastActivityDate, equals(lastActivityDate));
        expect(client.lastShiftNoteDate, equals(lastShiftNoteDate));
      });

      test('fromJson handles missing stat fields with defaults', () {
        final json = {
          'id': 'client_stats_999',
          'name': 'Minimal Stats',
          'date_of_birth': '2000-01-01',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        final client = ClientWithStats.fromJson(json);

        expect(client.activeGoalsCount, equals(0));
        expect(client.totalActivitiesCount, equals(0));
        expect(client.lastActivityDate, isNull);
        expect(client.lastShiftNoteDate, isNull);
      });
    });

    group('Equality (Equatable)', () {
      test('two clients with stats with same properties are equal', () {
        final client1 = ClientWithStats(
          id: 'same_id',
          name: 'Same Name',
          dateOfBirth: '1990-01-01',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
          activeGoalsCount: 5,
          totalActivitiesCount: 10,
          lastActivityDate: lastActivityDate,
          lastShiftNoteDate: lastShiftNoteDate,
        );

        final client2 = ClientWithStats(
          id: 'same_id',
          name: 'Same Name',
          dateOfBirth: '1990-01-01',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
          activeGoalsCount: 5,
          totalActivitiesCount: 10,
          lastActivityDate: lastActivityDate,
          lastShiftNoteDate: lastShiftNoteDate,
        );

        expect(client1, equals(client2));
      });

      test('clients with different stats are not equal', () {
        final client1 = testClientWithStats;
        final client2 = ClientWithStats(
          id: testClientWithStats.id,
          name: testClientWithStats.name,
          dateOfBirth: testClientWithStats.dateOfBirth,
          active: testClientWithStats.active,
          createdAt: testClientWithStats.createdAt,
          updatedAt: testClientWithStats.updatedAt,
          activeGoalsCount: 999, // Different
          totalActivitiesCount: testClientWithStats.totalActivitiesCount,
        );

        expect(client1, isNot(equals(client2)));
      });
    });
  });
}
