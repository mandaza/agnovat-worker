import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/client.dart';
import '../../data/models/activity.dart';
import '../../data/repositories/dashboard_repository.dart';

/// Dashboard state
class DashboardState {
  final List<Client> assignedClients;
  final List<Activity> todaysActivities;
  final int pendingShiftNotes;
  final int shiftsThisWeek;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.assignedClients = const [],
    this.todaysActivities = const [],
    this.pendingShiftNotes = 0,
    this.shiftsThisWeek = 0,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    List<Client>? assignedClients,
    List<Activity>? todaysActivities,
    int? pendingShiftNotes,
    int? shiftsThisWeek,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      assignedClients: assignedClients ?? this.assignedClients,
      todaysActivities: todaysActivities ?? this.todaysActivities,
      pendingShiftNotes: pendingShiftNotes ?? this.pendingShiftNotes,
      shiftsThisWeek: shiftsThisWeek ?? this.shiftsThisWeek,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Dashboard provider
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(const DashboardState());

  /// Load dashboard data from MCP backend
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch data from MCP backend
      final clients = await _repository.getAssignedClients();
      final activities = await _repository.getTodaysActivities();
      final pendingNotes = await _repository.getPendingShiftNotesCount();
      final shiftsCount = await _repository.getShiftsThisWeekCount();

      state = state.copyWith(
        assignedClients: clients,
        todaysActivities: activities,
        pendingShiftNotes: pendingNotes,
        shiftsThisWeek: shiftsCount,
        isLoading: false,
      );
    } catch (e) {
      // If API call fails, use mock data for development
      // Remove this fallback once backend is fully integrated
      _loadMockData();

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard: ${e.toString()}',
      );
    }
  }

  /// Fallback to mock data (for development when backend is not available)
  void _loadMockData() {
    final mockClients = _generateMockClients();
    final mockActivities = _generateMockActivities();

    state = state.copyWith(
      assignedClients: mockClients,
      todaysActivities: mockActivities,
      pendingShiftNotes: 2,
      shiftsThisWeek: 12,
    );
  }

  /// Generate mock clients
  List<Client> _generateMockClients() {
    final now = DateTime.now();
    return [
      Client(
        id: '1',
        name: 'John Smith',
        dateOfBirth: '1990-05-15',
        ndisNumber: '12345678901',
        active: true,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
      ),
      Client(
        id: '2',
        name: 'Sarah Johnson',
        dateOfBirth: '1985-08-22',
        ndisNumber: '98765432109',
        active: true,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      Client(
        id: '3',
        name: 'Michael Brown',
        dateOfBirth: '1992-12-10',
        active: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
    ];
  }

  /// Generate mock activities
  List<Activity> _generateMockActivities() {
    final now = DateTime.now();
    return [
      Activity(
        id: '1',
        clientId: '1',
        stakeholderId: 'worker-1',
        title: 'Life Skills - Shopping',
        description: 'Assist with grocery shopping',
        activityType: ActivityType.lifeSkills,
        status: ActivityStatus.scheduled,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now,
      ),
      Activity(
        id: '2',
        clientId: '2',
        stakeholderId: 'worker-1',
        title: 'Social & Community Activity',
        description: 'Visit local community center',
        activityType: ActivityType.socialRecreation,
        status: ActivityStatus.scheduled,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now,
      ),
      Activity(
        id: '3',
        clientId: '3',
        stakeholderId: 'worker-1',
        title: 'Personal Care Support',
        description: 'Assist with daily routine',
        activityType: ActivityType.personalCare,
        status: ActivityStatus.inProgress,
        createdAt: now.subtract(const Duration(minutes: 30)),
        updatedAt: now,
      ),
    ];
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    await loadDashboard();
  }
}

/// Dashboard provider instance
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final notifier = DashboardNotifier(repository);
  // Auto-load dashboard on creation
  Future.microtask(() => notifier.loadDashboard());
  return notifier;
});
