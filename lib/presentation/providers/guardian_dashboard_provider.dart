import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/client.dart';
import '../../data/models/activity.dart';
import '../../data/models/goal.dart';
import '../../data/models/user.dart';
import '../../data/models/activity_session.dart';
import 'auth_provider.dart';

/// Guardian Dashboard State
class GuardianDashboardState {
  final bool isLoading;
  final String? error;
  final GuardianDashboardData? data;

  const GuardianDashboardState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  GuardianDashboardState copyWith({
    bool? isLoading,
    String? error,
    GuardianDashboardData? data,
  }) {
    return GuardianDashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}

/// Guardian Dashboard Data Model
class GuardianDashboardData {
  // Top Stats
  final int activeGoals;
  final int supportWorkers;
  final int pendingReports;
  
  // Goals Progress
  final int goalsOnTrack;
  final int goalsBehind;
  final List<GoalProgressWeek> weeklyProgress;
  final List<ClientGoalsData> clientGoals;
  
  // Activities
  final Map<String, int> activityDistribution;
  final int totalActivities;
  
  // Reports
  final List<ReportData> monthlyReports;
  
  // Recent Activity
  final List<RecentActivityItem> recentActivities;
  
  // Recent Activity Sessions
  final List<ActivitySession> recentActivitySessions;

  const GuardianDashboardData({
    required this.activeGoals,
    required this.supportWorkers,
    required this.pendingReports,
    required this.goalsOnTrack,
    required this.goalsBehind,
    required this.weeklyProgress,
    required this.clientGoals,
    required this.activityDistribution,
    required this.totalActivities,
    required this.monthlyReports,
    required this.recentActivities,
    required this.recentActivitySessions,
  });
}

/// Goal Progress by Week
class GoalProgressWeek {
  final int week;
  final double onTrack;
  final double behind;

  const GoalProgressWeek({
    required this.week,
    required this.onTrack,
    required this.behind,
  });
}

/// Client Goals Data
class ClientGoalsData {
  final String clientName;
  final List<GoalItem> goals;

  const ClientGoalsData({
    required this.clientName,
    required this.goals,
  });
}

/// Individual Goal Item
class GoalItem {
  final String title;
  final String progress;

  const GoalItem({
    required this.title,
    required this.progress,
  });
}

/// Report Data for Charts
class ReportData {
  final String month;
  final int shiftReports;
  final int behaviorIncidents;

  const ReportData({
    required this.month,
    required this.shiftReports,
    required this.behaviorIncidents,
  });
}

/// Recent Activity Item
class RecentActivityItem {
  final String type; // 'report', 'goal', 'incident'
  final String title;
  final String subtitle;
  final String timeAgo;
  final String status;

  const RecentActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.status,
  });
}

/// Guardian Dashboard Notifier
class GuardianDashboardNotifier extends StateNotifier<GuardianDashboardState> {
  final Ref ref;

  GuardianDashboardNotifier(this.ref) : super(const GuardianDashboardState()) {
    Future.microtask(() => loadDashboardData());
  }

  /// Load all admin dashboard data
  Future<void> loadDashboardData() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.isLoggingOut) {
      state = const GuardianDashboardState(isLoading: false, error: null, data: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiService = ref.read(mcpApiServiceProvider);

      // Fetch all data in parallel
      final results = await Future.wait([
        apiService.listClients(active: true),
        apiService.listGoals(),
        apiService.listActivities(limit: 100),
        apiService.getRecentShiftNotes(limit: 20),
        // Try listing stakeholders directly if listUsers fails or returns empty
        apiService.listStakeholders(role: 'support_worker', limit: 100),
      ]);

      final clients = (results[0] as List<Client>?) ?? [];
      final goals = (results[1] as List<Goal>?) ?? [];
      final activities = (results[2] as List<Activity>?) ?? [];
      final shiftNotes = (results[3] as List<Map<String, dynamic>>?) ?? [];
      
      // Handle stakeholders result - might be List<dynamic> of maps, not User objects
      final stakeholdersRaw = (results[4] as List<dynamic>?) ?? [];
      final supportWorkersCount = stakeholdersRaw.length;
      
      print('📊 Dashboard: Found $supportWorkersCount support workers via stakeholders:list');

      // Fetch recent activity sessions
      final activitySessionService = ref.read(activitySessionServiceProvider);
      final recentActivitySessions = await activitySessionService.listSessions(
        limit: 10,
      );

      // Process data
      final dashboardData = _processData(
        clients: clients,
        goals: goals,
        activities: activities,
        shiftNotes: shiftNotes,
        supportWorkersCount: supportWorkersCount,
        activitySessions: recentActivitySessions,
      );

      state = state.copyWith(
        isLoading: false,
        data: dashboardData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Process raw data into admin dashboard format
  GuardianDashboardData _processData({
    required List<Client> clients,
    required List<Goal> goals,
    required List<Activity> activities,
    required List<Map<String, dynamic>> shiftNotes,
    required int supportWorkersCount,
    required List<ActivitySession> activitySessions,
  }) {
    // Calculate top stats
    final activeGoals = goals.length; // Total count of all goals
    final pendingReports = shiftNotes.where((n) => n['status'] == 'draft').length;

    // Goals progress - using progressPercentage (0-100)
    final goalsOnTrack = goals.where((g) {
      return g.progressPercentage >= 80; // 80% threshold
    }).length;
    final goalsBehind = goals.where((g) {
      return g.progressPercentage < 80 && g.status == GoalStatus.inProgress;
    }).length;

    // Weekly progress (simulated trend - in real app, would track historical data)
    final weeklyProgress = [
      GoalProgressWeek(week: 0, onTrack: 18, behind: 6),
      GoalProgressWeek(week: 1, onTrack: 20, behind: 4),
      GoalProgressWeek(week: 2, onTrack: 24, behind: 3),
      GoalProgressWeek(week: 3, onTrack: goalsOnTrack.toDouble(), behind: goalsBehind.toDouble()),
    ];

    // Client goals breakdown (top 2 clients with most goals)
    final clientGoalsMap = <String, List<Goal>>{};
    for (var goal in goals) {
      final clientId = goal.clientId;
      final client = clients.firstWhere((c) => c.id == clientId, orElse: () => clients.first);
      clientGoalsMap.putIfAbsent(client.name, () => []).add(goal);
    }

    final clientGoals = clientGoalsMap.entries
        .take(2)
        .map((entry) => ClientGoalsData(
              clientName: entry.key,
              goals: entry.value.take(3).map((g) {
                return GoalItem(
                  title: g.title,
                  progress: '${g.progressPercentage}% complete',
                );
              }).toList(),
            ))
        .toList();

    // Activity distribution
    final activityDistribution = <String, int>{};
    for (var activity in activities) {
      final type = activity.activityType.name;
      activityDistribution[type] = (activityDistribution[type] ?? 0) + 1;
    }

    // Monthly reports (simulated - in real app, would aggregate by month)
    final monthlyReports = [
      ReportData(month: 'Jul', shiftReports: 55, behaviorIncidents: 15),
      ReportData(month: 'Aug', shiftReports: 58, behaviorIncidents: 12),
      ReportData(month: 'Sep', shiftReports: 52, behaviorIncidents: 18),
      ReportData(month: 'Oct', shiftReports: 60, behaviorIncidents: 10),
      ReportData(month: 'Nov', shiftReports: shiftNotes.length, behaviorIncidents: 8),
    ];

    // Recent activities
    final recentActivities = <RecentActivityItem>[];
    
    // Add recent shift notes
    for (var note in shiftNotes.take(3)) {
      recentActivities.add(RecentActivityItem(
        type: 'report',
        title: 'New Shift Report',
        subtitle: '${note['client_name'] ?? 'Client'} • ${note['title'] ?? 'Weekly activities'}',
        timeAgo: _getTimeAgo(note['created_at']),
        status: note['status'] == 'submitted' ? 'submitted' : 'draft',
      ));
    }

    // Add recent goals
    final recentGoals = goals.where((g) => g.status == GoalStatus.achieved).take(2);
    for (var goal in recentGoals) {
      final client = clients.firstWhere((c) => c.id == goal.clientId, orElse: () => clients.first);
      recentActivities.add(RecentActivityItem(
        type: 'goal',
        title: 'Goal Updated',
        subtitle: '${client.name} • ${goal.title}',
        timeAgo: _getTimeAgo(goal.updatedAt.toIso8601String()),
        status: 'success',
      ));
    }

    // Sort by most recent
    // In a real app, you'd sort by actual timestamp

    return GuardianDashboardData(
      activeGoals: activeGoals,
      supportWorkers: supportWorkersCount,
      pendingReports: pendingReports,
      goalsOnTrack: goalsOnTrack,
      goalsBehind: goalsBehind,
      weeklyProgress: weeklyProgress,
      clientGoals: clientGoals,
      activityDistribution: activityDistribution,
      totalActivities: activities.length,
      monthlyReports: monthlyReports,
      recentActivities: recentActivities,
      recentActivitySessions: activitySessions,
    );
  }

  /// Convert timestamp to "time ago" format
  String _getTimeAgo(String? timestamp) {
    if (timestamp == null) return 'Recently';
    
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboardData();
  }
}

/// Guardian Dashboard Provider
final guardianDashboardProvider =
    StateNotifierProvider<GuardianDashboardNotifier, GuardianDashboardState>((ref) {
  return GuardianDashboardNotifier(ref);
});

