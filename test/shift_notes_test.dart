import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:agnovat_w/data/models/shift_note.dart';
import 'package:agnovat_w/data/services/mcp_api_service.dart';
import 'package:agnovat_w/presentation/providers/shift_notes_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Generate mocks
@GenerateMocks([McpApiService])
import 'shift_notes_test.mocks.dart';

void main() {
  group('ShiftNote Model Tests', () {
    test('ShiftNote should be created with draft status by default', () {
      final shiftNote = ShiftNote(
        id: 'test-id',
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2025-12-02',
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Test notes',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(shiftNote.status, ShiftNoteStatus.draft);
      expect(shiftNote.isDraft, true);
      expect(shiftNote.isSubmitted, false);
      expect(shiftNote.submittedAt, isNull);
    });

    test('ShiftNote with submitted status should have correct properties', () {
      final submittedAt = DateTime.now();
      final shiftNote = ShiftNote(
        id: 'test-id',
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2025-12-02',
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Test notes',
        status: ShiftNoteStatus.submitted,
        submittedAt: submittedAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(shiftNote.status, ShiftNoteStatus.submitted);
      expect(shiftNote.isDraft, false);
      expect(shiftNote.isSubmitted, true);
      expect(shiftNote.submittedAt, submittedAt);
    });

    test('Draft shift note should always be editable and deletable', () {
      final shiftNote = ShiftNote(
        id: 'test-id',
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2020-01-01', // Old date
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Test notes',
        status: ShiftNoteStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(shiftNote.canEdit, true);
      expect(shiftNote.canDelete, true);
    });

    test('Submitted shift note within 24 hours should be editable', () {
      final today = DateTime.now();
      final shiftNote = ShiftNote(
        id: 'test-id',
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: DateTime(today.year, today.month, today.day).toIso8601String().split('T')[0],
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Test notes',
        status: ShiftNoteStatus.submitted,
        submittedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(shiftNote.canEdit, true);
      expect(shiftNote.canDelete, true);
    });

    test('Submitted shift note older than 24 hours should not be editable', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 2));
      final shiftNote = ShiftNote(
        id: 'test-id',
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: DateTime(yesterday.year, yesterday.month, yesterday.day).toIso8601String().split('T')[0],
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Test notes',
        status: ShiftNoteStatus.submitted,
        submittedAt: yesterday,
        createdAt: yesterday,
        updatedAt: yesterday,
      );

      expect(shiftNote.canEdit, false);
      expect(shiftNote.canDelete, false);
    });

    test('Draft with non-empty notes should be submittable', () {
      final shiftNote = ShiftNote(
        id: 'test-id',
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2025-12-02',
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Test notes',
        status: ShiftNoteStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(shiftNote.canSubmit, true);
    });

    test('Draft with empty notes should not be submittable', () {
      final shiftNote = ShiftNote(
        id: 'test-id',
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2025-12-02',
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: '   ', // Empty/whitespace
        status: ShiftNoteStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(shiftNote.canSubmit, false);
    });

    test('Submitted shift note should not be submittable again', () {
      final shiftNote = ShiftNote(
        id: 'test-id',
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2025-12-02',
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Test notes',
        status: ShiftNoteStatus.submitted,
        submittedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(shiftNote.canSubmit, false);
    });
  });

  group('ShiftNote JSON Serialization Tests', () {
    test('ShiftNote should serialize to JSON correctly', () {
      final now = DateTime.now();
      final shiftNote = ShiftNote(
        id: 'test-id',
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2025-12-02',
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Test notes',
        primaryLocations: ['Home', 'Park'],
        activityIds: ['activity-1', 'activity-2'],
        status: ShiftNoteStatus.draft,
        createdAt: now,
        updatedAt: now,
      );

      final json = shiftNote.toJson();

      expect(json['id'], 'test-id');
      expect(json['client_id'], 'client-123');
      expect(json['user_id'], 'user-456');
      expect(json['shift_date'], '2025-12-02');
      expect(json['start_time'], '09:00');
      expect(json['end_time'], '17:00');
      expect(json['raw_notes'], 'Test notes');
      expect(json['status'], 'draft');
      expect(json['primary_locations'], ['Home', 'Park']);
      expect(json['activity_ids'], ['activity-1', 'activity-2']);
    });

    test('ShiftNote should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'client_id': 'client-123',
        'user_id': 'user-456',
        'shift_date': '2025-12-02',
        'start_time': '09:00',
        'end_time': '17:00',
        'raw_notes': 'Test notes',
        'status': 'draft',
        'created_at': '2025-12-02T10:00:00.000Z',
        'updated_at': '2025-12-02T10:00:00.000Z',
      };

      final shiftNote = ShiftNote.fromJson(json);

      expect(shiftNote.id, 'test-id');
      expect(shiftNote.clientId, 'client-123');
      expect(shiftNote.userId, 'user-456');
      expect(shiftNote.shiftDate, '2025-12-02');
      expect(shiftNote.startTime, '09:00');
      expect(shiftNote.endTime, '17:00');
      expect(shiftNote.rawNotes, 'Test notes');
      expect(shiftNote.status, ShiftNoteStatus.draft);
    });

    test('ShiftNote should handle _id field from MongoDB', () {
      final json = {
        '_id': 'mongo-id',
        'client_id': 'client-123',
        'user_id': 'user-456',
        'shift_date': '2025-12-02',
        'start_time': '09:00',
        'end_time': '17:00',
        'raw_notes': 'Test notes',
        'status': 'submitted',
        'submitted_at': '2025-12-02T12:00:00.000Z',
        'created_at': '2025-12-02T10:00:00.000Z',
        'updated_at': '2025-12-02T10:00:00.000Z',
      };

      final shiftNote = ShiftNote.fromJson(json);

      expect(shiftNote.id, 'mongo-id');
      expect(shiftNote.status, ShiftNoteStatus.submitted);
      expect(shiftNote.submittedAt, isNotNull);
    });
  });

  group('ShiftNote Creation Tests', () {
    late MockMcpApiService mockApiService;

    setUp(() {
      mockApiService = MockMcpApiService();
    });

    test('Create shift note with required fields should return draft', () async {
      final expectedResponse = {
        'id': 'new-shift-123',
        'client_id': 'client-123',
        'user_id': 'user-456',
        'shift_date': '2025-12-02',
        'start_time': '09:00',
        'end_time': '17:00',
        'raw_notes': 'Client was engaged during activities',
        'status': 'draft',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockApiService.createShiftNote(
        clientId: anyNamed('clientId'),
        userId: anyNamed('userId'),
        shiftDate: anyNamed('shiftDate'),
        startTime: anyNamed('startTime'),
        endTime: anyNamed('endTime'),
        rawNotes: anyNamed('rawNotes'),
      )).thenAnswer((_) async => expectedResponse);

      final result = await mockApiService.createShiftNote(
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2025-12-02',
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Client was engaged during activities',
      );

      expect(result['id'], 'new-shift-123');
      expect(result['status'], 'draft');
      verify(mockApiService.createShiftNote(
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2025-12-02',
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Client was engaged during activities',
      )).called(1);
    });

    test('Create shift note with all optional fields', () async {
      final goalsProgress = [
        {
          'goal_id': 'goal-1',
          'progress_notes': 'Made good progress',
          'progress_observed': 8,
        }
      ];

      final expectedResponse = {
        'id': 'new-shift-123',
        'client_id': 'client-123',
        'user_id': 'user-456',
        'shift_date': '2025-12-02',
        'start_time': '09:00',
        'end_time': '17:00',
        'raw_notes': 'Detailed shift notes',
        'primary_locations': ['Home', 'Park'],
        'activity_ids': ['activity-1', 'activity-2'],
        'goals_progress': goalsProgress,
        'status': 'draft',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockApiService.createShiftNote(
        clientId: anyNamed('clientId'),
        userId: anyNamed('userId'),
        shiftDate: anyNamed('shiftDate'),
        startTime: anyNamed('startTime'),
        endTime: anyNamed('endTime'),
        rawNotes: anyNamed('rawNotes'),
        primaryLocations: anyNamed('primaryLocations'),
        activityIds: anyNamed('activityIds'),
        goalsProgress: anyNamed('goalsProgress'),
      )).thenAnswer((_) async => expectedResponse);

      final result = await mockApiService.createShiftNote(
        clientId: 'client-123',
        userId: 'user-456',
        shiftDate: '2025-12-02',
        startTime: '09:00',
        endTime: '17:00',
        rawNotes: 'Detailed shift notes',
        primaryLocations: ['Home', 'Park'],
        activityIds: ['activity-1', 'activity-2'],
        goalsProgress: goalsProgress,
      );

      expect(result['primary_locations'], ['Home', 'Park']);
      expect(result['activity_ids'], ['activity-1', 'activity-2']);
      expect(result['goals_progress'], goalsProgress);
    });
  });

  group('Submit Shift Note Tests', () {
    late MockMcpApiService mockApiService;

    setUp(() {
      mockApiService = MockMcpApiService();
    });

    test('Submit draft shift note should change status to submitted', () async {
      final submittedAt = DateTime.now();
      final expectedResponse = {
        'id': 'shift-123',
        'client_id': 'client-123',
        'user_id': 'user-456',
        'shift_date': '2025-12-02',
        'start_time': '09:00',
        'end_time': '17:00',
        'raw_notes': 'Client was engaged during activities',
        'status': 'submitted',
        'submitted_at': submittedAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockApiService.submitShiftNote(any))
          .thenAnswer((_) async => expectedResponse);

      final result = await mockApiService.submitShiftNote('shift-123');
      final shiftNote = ShiftNote.fromJson(result);

      expect(shiftNote.status, ShiftNoteStatus.submitted);
      expect(shiftNote.isSubmitted, true);
      expect(shiftNote.isDraft, false);
      expect(shiftNote.submittedAt, isNotNull);
      verify(mockApiService.submitShiftNote('shift-123')).called(1);
    });

    test('Submit shift note should set submittedAt timestamp', () async {
      final submittedAt = DateTime.now();
      final expectedResponse = {
        'id': 'shift-123',
        'client_id': 'client-123',
        'user_id': 'user-456',
        'shift_date': '2025-12-02',
        'start_time': '09:00',
        'end_time': '17:00',
        'raw_notes': 'Notes',
        'status': 'submitted',
        'submitted_at': submittedAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockApiService.submitShiftNote(any))
          .thenAnswer((_) async => expectedResponse);

      final result = await mockApiService.submitShiftNote('shift-123');
      final shiftNote = ShiftNote.fromJson(result);

      expect(shiftNote.submittedAt, isNotNull);
      expect(shiftNote.submittedAt!.year, submittedAt.year);
      expect(shiftNote.submittedAt!.month, submittedAt.month);
      expect(shiftNote.submittedAt!.day, submittedAt.day);
    });
  });

  group('Save as Draft Tests', () {
    late MockMcpApiService mockApiService;

    setUp(() {
      mockApiService = MockMcpApiService();
    });

    test('Update shift note should maintain draft status', () async {
      final expectedResponse = {
        'id': 'shift-123',
        'client_id': 'client-123',
        'user_id': 'user-456',
        'shift_date': '2025-12-02',
        'start_time': '09:00',
        'end_time': '17:00',
        'raw_notes': 'Updated notes content',
        'status': 'draft',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockApiService.updateShiftNote(
        shiftNoteId: anyNamed('shiftNoteId'),
        rawNotes: anyNamed('rawNotes'),
      )).thenAnswer((_) async => expectedResponse);

      final result = await mockApiService.updateShiftNote(
        shiftNoteId: 'shift-123',
        rawNotes: 'Updated notes content',
      );

      final shiftNote = ShiftNote.fromJson(result);

      expect(shiftNote.status, ShiftNoteStatus.draft);
      expect(shiftNote.isDraft, true);
      expect(shiftNote.rawNotes, 'Updated notes content');
      verify(mockApiService.updateShiftNote(
        shiftNoteId: 'shift-123',
        rawNotes: 'Updated notes content',
      )).called(1);
    });

    test('Update multiple fields of draft shift note', () async {
      final expectedResponse = {
        'id': 'shift-123',
        'client_id': 'client-123',
        'user_id': 'user-456',
        'shift_date': '2025-12-03',
        'start_time': '10:00',
        'end_time': '18:00',
        'raw_notes': 'Updated comprehensive notes',
        'primary_locations': ['Office', 'Gym'],
        'status': 'draft',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockApiService.updateShiftNote(
        shiftNoteId: anyNamed('shiftNoteId'),
        shiftDate: anyNamed('shiftDate'),
        startTime: anyNamed('startTime'),
        endTime: anyNamed('endTime'),
        rawNotes: anyNamed('rawNotes'),
        primaryLocations: anyNamed('primaryLocations'),
      )).thenAnswer((_) async => expectedResponse);

      final result = await mockApiService.updateShiftNote(
        shiftNoteId: 'shift-123',
        shiftDate: '2025-12-03',
        startTime: '10:00',
        endTime: '18:00',
        rawNotes: 'Updated comprehensive notes',
        primaryLocations: ['Office', 'Gym'],
      );

      final shiftNote = ShiftNote.fromJson(result);

      expect(shiftNote.shiftDate, '2025-12-03');
      expect(shiftNote.startTime, '10:00');
      expect(shiftNote.endTime, '18:00');
      expect(shiftNote.rawNotes, 'Updated comprehensive notes');
      expect(shiftNote.primaryLocations, ['Office', 'Gym']);
      expect(shiftNote.status, ShiftNoteStatus.draft);
    });
  });

  group('ShiftNotesProvider Tests', () {
    test('ShiftNotesState should initialize with correct defaults', () {
      const state = ShiftNotesState();

      expect(state.isLoading, true);
      expect(state.error, isNull);
      expect(state.shiftNotes, isEmpty);
      expect(state.filteredShiftNotes, isEmpty);
      expect(state.statusFilter, ShiftNoteFilter.all);
      expect(state.searchQuery, '');
    });

    test('ShiftNotesState should filter draft notes correctly', () {
      final now = DateTime.now();
      final notes = [
        ShiftNote(
          id: '1',
          clientId: 'client-1',
          userId: 'user-1',
          shiftDate: '2025-12-02',
          startTime: '09:00',
          endTime: '17:00',
          rawNotes: 'Draft note',
          status: ShiftNoteStatus.draft,
          createdAt: now,
          updatedAt: now,
        ),
        ShiftNote(
          id: '2',
          clientId: 'client-1',
          userId: 'user-1',
          shiftDate: '2025-12-01',
          startTime: '09:00',
          endTime: '17:00',
          rawNotes: 'Submitted note',
          status: ShiftNoteStatus.submitted,
          submittedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final state = ShiftNotesState(
        shiftNotes: notes,
        filteredShiftNotes: notes,
      );

      expect(state.draftNotesCount, 1);
      expect(state.submittedNotesCount, 1);
      expect(state.hasDraftNotes, true);
    });
  });

  group('GoalProgress Tests', () {
    test('GoalProgress should serialize to JSON correctly', () {
      const goalProgress = GoalProgress(
        goalId: 'goal-123',
        progressNotes: 'Client showed improvement',
        progressObserved: 8,
      );

      final json = goalProgress.toJson();

      expect(json['goal_id'], 'goal-123');
      expect(json['progress_notes'], 'Client showed improvement');
      expect(json['progress_observed'], 8);
    });

    test('GoalProgress should deserialize from JSON correctly', () {
      final json = {
        'goal_id': 'goal-123',
        'progress_notes': 'Client showed improvement',
        'progress_observed': 7,
      };

      final goalProgress = GoalProgress.fromJson(json);

      expect(goalProgress.goalId, 'goal-123');
      expect(goalProgress.progressNotes, 'Client showed improvement');
      expect(goalProgress.progressObserved, 7);
    });
  });
}
