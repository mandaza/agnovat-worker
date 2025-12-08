import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:agnovat_w/data/models/user.dart';
import 'package:agnovat_w/data/models/client.dart';
import 'package:agnovat_w/data/models/goal.dart';
import 'package:agnovat_w/data/models/activity.dart';
import 'package:agnovat_w/data/services/mcp_api_service.dart';
import 'package:agnovat_w/core/providers/service_providers.dart';
import 'package:agnovat_w/presentation/providers/auth_provider.dart';
import 'test_helpers.dart';

/// Mock API service for integration tests
class MockIntegrationApiService extends Mock implements McpApiService {
  final User currentUser;
  final List<Client> clients;
  final List<Goal> goals;
  final List<Activity> activities;
  final Map<String, dynamic> Function()? onCreateShiftNote;
  final Map<String, dynamic> Function(String)? onUpdateShiftNote;

  MockIntegrationApiService({
    required this.currentUser,
    this.clients = const [],
    this.goals = const [],
    this.activities = const [],
    this.onCreateShiftNote,
    this.onUpdateShiftNote,
  });

  @override
  Future<User> getCurrentUser({required String? clerkId}) async {
    return currentUser;
  }

  @override
  Future<User> getUserProfile({required String? clerkId}) async {
    return currentUser;
  }

  @override
  Future<List<Client>> listClients({
    bool? active,
    String? search,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network
    return clients;
  }

  @override
  Future<Client> getClient(String? clientId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return clients.firstWhere(
      (c) => c.id == clientId,
      orElse: () => throw Exception('Client not found'),
    );
  }

  @override
  Future<List<Goal>> listGoals({
    String? clientId,
    String? status,
    String? category,
    bool? archived,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (clientId != null) {
      return goals.where((g) => g.clientId == clientId).toList();
    }
    return goals;
  }

  @override
  Future<List<Activity>> listActivities({
    String? clientId,
    String? stakeholderId,
    String? activityType,
    String? status,
    String? goalId,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (clientId != null) {
      return activities.where((a) => a.clientId == clientId).toList();
    }
    return activities;
  }

  @override
  Future<Map<String, dynamic>> createShiftNote({
    required String? clientId,
    required String? userId,
    required String? shiftDate,
    required String? startTime,
    required String? endTime,
    List<String>? primaryLocations,
    required String? rawNotes,
    List<String>? activityIds,
    List<Map<String, dynamic>>? goalsProgress,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (onCreateShiftNote != null) {
      return onCreateShiftNote!();
    }

    // Default successful response
    return {
      '_id': 'test_shift_note_${DateTime.now().millisecondsSinceEpoch}',
      'clientId': clientId,
      'userId': userId,
      'shiftDate': shiftDate,
      'startTime': startTime,
      'endTime': endTime,
      'primaryLocations': primaryLocations ?? [],
      'rawNotes': rawNotes,
      'status': 'draft',
      'activityIds': activityIds ?? [],
      'goalsProgress': goalsProgress ?? [],
      '_creationTime': DateTime.now().millisecondsSinceEpoch.toDouble(),
    };
  }

  @override
  Future<Map<String, dynamic>> updateShiftNote({
    required String? shiftNoteId,
    String? userId,
    String? shiftDate,
    String? startTime,
    String? endTime,
    List<String>? primaryLocations,
    String? rawNotes,
    List<String>? activityIds,
    List<Map<String, dynamic>>? goalsProgress,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (onUpdateShiftNote != null) {
      return onUpdateShiftNote!(shiftNoteId!);
    }

    // Default successful response
    return {
      '_id': shiftNoteId,
      'userId': userId,
      'shiftDate': shiftDate,
      'startTime': startTime,
      'endTime': endTime,
      'primaryLocations': primaryLocations,
      'rawNotes': rawNotes,
      'status': 'draft',
      'activityIds': activityIds,
      'goalsProgress': goalsProgress,
      '_creationTime': DateTime.now().millisecondsSinceEpoch.toDouble(),
    };
  }

  @override
  Future<Map<String, dynamic>> submitShiftNote(String? shiftNoteId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return {
      '_id': shiftNoteId,
      'status': 'submitted',
      '_creationTime': DateTime.now().millisecondsSinceEpoch.toDouble(),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> listShiftNotes({
    String? clientId,
    String? stakeholderId,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }

  @override
  Future<DashboardData> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DashboardData(
      totalClients: clients.length,
      activeClients: clients.where((c) => c.active).length,
      totalGoals: goals.length,
      activeGoals: goals.where((g) => !g.archived).length,
      goalsAtRisk: [],
      recentActivities: activities,
      recentShiftNotes: [],
      statistics: DashboardStatistics(
        goalsByStatus: {},
        activitiesByType: {},
      ),
    );
  }
}

/// Create provider overrides for integration tests
List<Override> createTestProviderOverrides({
  required User currentUser,
  List<Client>? clients,
  List<Goal>? goals,
  List<Activity>? activities,
  Map<String, dynamic> Function()? onCreateShiftNote,
  Map<String, dynamic> Function(String)? onUpdateShiftNote,
}) {
  final mockApiService = MockIntegrationApiService(
    currentUser: currentUser,
    clients: clients ?? [createTestClient()],
    goals: goals ?? [createTestGoal()],
    activities: activities ?? [createTestActivity()],
    onCreateShiftNote: onCreateShiftNote,
    onUpdateShiftNote: onUpdateShiftNote,
  );

  return [
    // Override API service
    mcpApiServiceProvider.overrideWithValue(mockApiService),

    // Override auth provider to return authenticated state with test user
    authProvider.overrideWith(() {
      return TestAuthNotifier(currentUser);
    }),
  ];
}

/// Test auth notifier that returns a mocked authenticated state
class TestAuthNotifier extends AuthNotifier {
  final User testUser;

  TestAuthNotifier(this.testUser);

  @override
  AuthState build() {
    return AuthState(
      isAuthenticated: true,
      isLoading: false,
      user: testUser,
      error: null,
    );
  }

  Future<void> signIn() async {
    // No-op for tests
  }

  Future<void> signOut() async {
    // No-op for tests
  }

  Future<void> refresh() async {
    // No-op for tests
  }
}
