import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agnovat_w/core/services/convex_client_service.dart';
import 'package:agnovat_w/data/services/mcp_api_service.dart';
import 'package:agnovat_w/data/models/user.dart';
import 'package:agnovat_w/data/models/client.dart';

import 'mcp_api_service_test.mocks.dart';

@GenerateMocks([ConvexClientService])
void main() {
  group('McpApiService Tests', () {
    late MockConvexClientService mockConvexClient;
    late McpApiService apiService;

    setUp(() {
      mockConvexClient = MockConvexClientService();
      apiService = McpApiService(mockConvexClient);
    });

    group('Auth / Users', () {
      final testDateTime = DateTime(2024, 1, 15);

      test('getCurrentUser returns user from Convex', () async {
        final mockResponse = {
          'id': 'user_123',
          'clerk_id': 'clerk_abc',
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'supportWorker',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        when(mockConvexClient.query<Map<String, dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => mockResponse);

        final user = await apiService.getCurrentUser(clerkId: 'clerk_abc');

        expect(user.id, equals('user_123'));
        expect(user.email, equals('test@example.com'));
        expect(user.role, equals(UserRole.supportWorker));

        verify(mockConvexClient.query<Map<String, dynamic>>(
          'auth:getCurrentUser',
          args: {'clerk_id': 'clerk_abc'},
        )).called(1);
      });

      test('getUserById returns user by ID', () async {
        final mockResponse = {
          'id': 'user_456',
          'clerk_id': 'clerk_def',
          'email': 'user@example.com',
          'name': 'User Name',
          'role': 'behaviorPractitioner',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        when(mockConvexClient.query<Map<String, dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => mockResponse);

        final user = await apiService.getUserById('user_456');

        expect(user.id, equals('user_456'));
        expect(user.role, equals(UserRole.behaviorPractitioner));

        verify(mockConvexClient.query<Map<String, dynamic>>(
          'users:get',
          args: {'id': 'user_456'},
        )).called(1);
      });

      test('listUsers returns list of users', () async {
        final mockResponse = [
          {
            'id': 'user_1',
            'clerk_id': 'clerk_1',
            'email': 'user1@example.com',
            'name': 'User One',
            'role': 'supportWorker',
            'active': true,
            'created_at': testDateTime.toIso8601String(),
            'updated_at': testDateTime.toIso8601String(),
          },
          {
            'id': 'user_2',
            'clerk_id': 'clerk_2',
            'email': 'user2@example.com',
            'name': 'User Two',
            'role': 'manager',
            'active': true,
            'created_at': testDateTime.toIso8601String(),
            'updated_at': testDateTime.toIso8601String(),
          },
        ];

        when(mockConvexClient.query<List<dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => mockResponse);

        final users = await apiService.listUsers();

        expect(users, hasLength(2));
        expect(users[0].id, equals('user_1'));
        expect(users[1].id, equals('user_2'));
        expect(users[0].role, equals(UserRole.supportWorker));
        expect(users[1].role, equals(UserRole.manager));
      });

      test('listUsers with filters passes correct parameters', () async {
        when(mockConvexClient.query<List<dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => []);

        await apiService.listUsers(
          role: 'supportWorker',
          active: true,
          limit: 10,
          offset: 5,
        );

        verify(mockConvexClient.query<List<dynamic>>(
          'users:list',
          args: {
            'role': 'supportWorker',
            'active': true,
            'limit': 10,
            'offset': 5,
          },
        )).called(1);
      });

      test('syncUserFromClerk creates user in Convex', () async {
        final mockResponse = {
          'id': 'user_new',
          'clerk_id': 'clerk_new',
          'email': 'new@example.com',
          'name': 'New User',
          'image_url': 'https://example.com/avatar.jpg',
          'role': 'supportWorker',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        when(mockConvexClient.mutation<Map<String, dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => mockResponse);

        final user = await apiService.syncUserFromClerk(
          clerkId: 'clerk_new',
          email: 'new@example.com',
          name: 'New User',
          imageUrl: 'https://example.com/avatar.jpg',
        );

        expect(user.clerkId, equals('clerk_new'));
        expect(user.email, equals('new@example.com'));

        verify(mockConvexClient.mutation<Map<String, dynamic>>(
          'auth:syncUserFromClerk',
          args: {
            'clerk_id': 'clerk_new',
            'email': 'new@example.com',
            'name': 'New User',
            'image_url': 'https://example.com/avatar.jpg',
          },
        )).called(1);
      });

      test('syncUserFromClerk without imageUrl omits parameter', () async {
        final mockResponse = {
          'id': 'user_new',
          'clerk_id': 'clerk_new',
          'email': 'new@example.com',
          'name': 'New User',
          'role': 'supportWorker',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        when(mockConvexClient.mutation<Map<String, dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => mockResponse);

        await apiService.syncUserFromClerk(
          clerkId: 'clerk_new',
          email: 'new@example.com',
          name: 'New User',
        );

        verify(mockConvexClient.mutation<Map<String, dynamic>>(
          'auth:syncUserFromClerk',
          args: {
            'clerk_id': 'clerk_new',
            'email': 'new@example.com',
            'name': 'New User',
            // No image_url should be present
          },
        )).called(1);
      });
    });

    group('Clients', () {
      final testDateTime = DateTime(2024, 1, 15);

      test('getClient returns client by ID', () async {
        final mockResponse = {
          'id': 'client_123',
          'name': 'John Doe',
          'date_of_birth': '1990-05-15',
          'ndis_number': '12345678901',
          'active': true,
          'created_at': testDateTime.toIso8601String(),
          'updated_at': testDateTime.toIso8601String(),
        };

        when(mockConvexClient.query<Map<String, dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => mockResponse);

        final client = await apiService.getClient('client_123');

        expect(client.id, equals('client_123'));
        expect(client.name, equals('John Doe'));
        expect(client.ndisNumber, equals('12345678901'));

        verify(mockConvexClient.query<Map<String, dynamic>>(
          'clients:get',
          args: {'id': 'client_123'},
        )).called(1);
      });

      test('listClients returns list of clients', () async {
        final mockResponse = [
          {
            'id': 'client_1',
            'name': 'Client One',
            'date_of_birth': '1990-01-01',
            'active': true,
            'created_at': testDateTime.toIso8601String(),
            'updated_at': testDateTime.toIso8601String(),
          },
          {
            'id': 'client_2',
            'name': 'Client Two',
            'date_of_birth': '1985-06-15',
            'active': true,
            'created_at': testDateTime.toIso8601String(),
            'updated_at': testDateTime.toIso8601String(),
          },
        ];

        when(mockConvexClient.query<List<dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => mockResponse);

        final clients = await apiService.listClients();

        expect(clients, hasLength(2));
        expect(clients[0].id, equals('client_1'));
        expect(clients[1].id, equals('client_2'));
      });

      test('listClients with filters passes correct parameters', () async {
        when(mockConvexClient.query<List<dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => []);

        await apiService.listClients(
          active: true,
          search: 'John',
          limit: 10,
          offset: 5,
        );

        verify(mockConvexClient.query<List<dynamic>>(
          'clients:list',
          args: {
            'active': true,
            'search': 'John',
            'limit': 10,
            'offset': 5,
          },
        )).called(1);
      });
    });

    group('Shift Notes', () {
      final testDateTime = DateTime(2024, 1, 15);

      test('createShiftNote calls mutation with correct parameters', () async {
        final mockResponse = {
          'id': 'note_new_123',
        };

        when(mockConvexClient.mutation<Map<String, dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenAnswer((_) async => mockResponse);

        final result = await apiService.createShiftNote(
          clientId: 'client_1',
          userId: 'user_1',
          shiftDate: '2024-01-15',
          startTime: '09:00',
          endTime: '17:00',
          rawNotes: 'Test shift notes',
        );

        expect(result['id'], equals('note_new_123'));

        verify(mockConvexClient.mutation<Map<String, dynamic>>(
          'shiftNotes:create',
          args: anyNamed('args'),
        )).called(1);
      });
    });

    group('Error Handling', () {
      test('throws exception when query fails', () async {
        when(mockConvexClient.query<Map<String, dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenThrow(Exception('Network error'));

        expect(
          () => apiService.getCurrentUser(clerkId: 'clerk_123'),
          throwsException,
        );
      });

      test('throws exception when mutation fails', () async {
        when(mockConvexClient.mutation<Map<String, dynamic>>(
          any,
          args: anyNamed('args'),
        )).thenThrow(Exception('Server error'));

        expect(
          () => apiService.createShiftNote(
            clientId: 'client_1',
            userId: 'user_1',
            shiftDate: '2024-01-15',
            startTime: '09:00',
            endTime: '17:00',
            rawNotes: 'Test',
          ),
          throwsException,
        );
      });
    });
  });
}
