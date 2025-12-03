import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/services/mcp_api_service.dart';
import '../../data/models/client.dart';
import '../../data/models/activity.dart';

/// Dashboard state model
class DashboardState {
  final bool isLoading;
  final String? error;
  final List<Client> assignedClients;
  final int shiftsThisWeek;
  final int pendingShiftNotes;
  final List<Activity> todaysActivities;
  final DashboardData? data;

  const DashboardState({
    this.isLoading = true,
    this.error,
    this.assignedClients = const [],
    this.shiftsThisWeek = 0,
    this.pendingShiftNotes = 0,
    this.todaysActivities = const [],
    this.data,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    List<Client>? assignedClients,
    int? shiftsThisWeek,
    int? pendingShiftNotes,
    List<Activity>? todaysActivities,
    DashboardData? data,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      assignedClients: assignedClients ?? this.assignedClients,
      shiftsThisWeek: shiftsThisWeek ?? this.shiftsThisWeek,
      pendingShiftNotes: pendingShiftNotes ?? this.pendingShiftNotes,
      todaysActivities: todaysActivities ?? this.todaysActivities,
      data: data ?? this.data,
    );
  }
}

/// Dashboard state notifier with real-time updates
class DashboardNotifier extends AutoDisposeNotifier<DashboardState> {
  Timer? _refreshTimer;

  @override
  DashboardState build() {
    // Set up auto-refresh (every 30 seconds for real-time data)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });

    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    // Initial data fetch
    _fetchData();

    return const DashboardState();
  }

  /// Fetch dashboard data from Convex
  Future<void> _fetchData() async {
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      
      // Fetch dashboard data
      final dashboardData = await apiService.getDashboard();
      
      // Fetch all active clients list (for assigned clients count)
      final clients = await apiService.listClients(active: true);
      
      // Update state with real-time data
      state = state.copyWith(
        isLoading: false,
        error: null,
        assignedClients: clients,
        shiftsThisWeek: 0, // TODO: Calculate from shift notes
        pendingShiftNotes: dashboardData.recentShiftNotes.length,
        todaysActivities: _filterTodaysActivities(dashboardData.recentActivities),
        data: dashboardData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Filter activities for today
  List<Activity> _filterTodaysActivities(List<Activity> activities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return activities.where((activity) {
      final activityDate = activity.createdAt;
      final activityDay = DateTime(
        activityDate.year,
        activityDate.month,
        activityDate.day,
      );
      return activityDay.isAtSameMomentAs(today);
    }).toList();
  }

  /// Manually refresh dashboard data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _fetchData();
  }
}

/// Main dashboard provider with real-time updates
final dashboardProvider = AutoDisposeNotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);

/// Dashboard data provider with auto-refresh (kept for backward compatibility)
/// Fetches real-time dashboard data from Convex
final dashboardDataProvider = StreamProvider.autoDispose<DashboardData>((ref) {
  final apiService = ref.watch(mcpApiServiceProvider);
  
  // Create a stream controller for dashboard updates
  final controller = StreamController<DashboardData>();
  
  // Auto-refresh interval (every 30 seconds)
  const refreshInterval = Duration(seconds: 30);
  Timer? timer;
  
  // Fetch data immediately
  void fetchData() async {
    try {
      final data = await apiService.getDashboard();
      if (!controller.isClosed) {
        controller.add(data);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }
  
  // Initial fetch
  fetchData();
  
  // Set up periodic refresh
  timer = Timer.periodic(refreshInterval, (_) {
    fetchData();
  });
  
  // Clean up when provider is disposed
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });
  
  return controller.stream;
});

/// Dashboard statistics provider (derived from dashboard data)
final dashboardStatsProvider = Provider.autoDispose<AsyncValue<DashboardStatistics>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.statistics),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Active clients count provider
final activeClientsCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.activeClients),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Goals at risk provider
final goalsAtRiskProvider = Provider.autoDispose<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.goalsAtRisk),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Recent activities provider
final recentActivitiesProvider = Provider.autoDispose<AsyncValue<List<dynamic>>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.recentActivities),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Recent shift notes provider
final recentShiftNotesProvider = Provider.autoDispose<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.recentShiftNotes),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Manual refresh trigger for dashboard
final dashboardRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(dashboardDataProvider);
  };
});
