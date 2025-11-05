import '../../core/config/api_config.dart';
import '../../core/services/convex_client_service.dart';
import '../models/client.dart';
import '../models/activity.dart';

/// MCP API Service (Convex Backend)
/// Handles all communication with Convex functions
class McpApiService {
  final ConvexClientService _convexClient;

  McpApiService(this._convexClient);

  // ==================== DASHBOARD ====================

  /// Get dashboard data with aggregated metrics
  /// Calls Convex function: dashboard:getDashboard
  Future<DashboardData> getDashboard() async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.dashboardGet,
    );

    return DashboardData.fromJson(result);
  }

  /// Get client summary (for dashboard assigned client card)
  /// Calls Convex function: dashboard:getClientSummary
  Future<ClientSummary> getClientSummary(String clientId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.dashboardGetClientSummary,
      args: {'client_id': clientId},
    );

    return ClientSummary.fromJson(result);
  }

  // ==================== CLIENTS ====================

  /// List all clients with optional filtering
  /// Calls Convex function: clients:list
  Future<List<Client>> listClients({
    bool? active,
    String? search,
    int? limit,
    int? offset,
  }) async {
    final args = <String, dynamic>{};
    if (active != null) args['active'] = active;
    if (search != null) args['search'] = search;
    if (limit != null) args['limit'] = limit;
    if (offset != null) args['offset'] = offset;

    final result = await _convexClient.query<List<dynamic>>(
      ApiConfig.clientsList,
      args: args,
    );

    return result
        .map((json) => Client.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get client by ID with stats
  /// Calls Convex function: clients:get
  Future<Client> getClient(String clientId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.clientsGet,
      args: {'id': clientId},
    );

    return Client.fromJson(result);
  }

  /// Search clients by name
  /// Calls Convex function: clients:search
  Future<List<Client>> searchClients(String searchTerm) async {
    final result = await _convexClient.query<List<dynamic>>(
      ApiConfig.clientsSearch,
      args: {'search_term': searchTerm},
    );

    return result
        .map((json) => Client.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ==================== ACTIVITIES ====================

  /// List activities with optional filtering
  /// Calls Convex function: activities:list
  Future<List<Activity>> listActivities({
    String? clientId,
    String? stakeholderId,
    String? activityType,
    String? status,
    String? goalId,
    int? limit,
    int? offset,
  }) async {
    final args = <String, dynamic>{};
    if (clientId != null) args['client_id'] = clientId;
    if (stakeholderId != null) args['stakeholder_id'] = stakeholderId;
    if (activityType != null) args['activity_type'] = activityType;
    if (status != null) args['status'] = status;
    if (goalId != null) args['goal_id'] = goalId;
    if (limit != null) args['limit'] = limit;
    if (offset != null) args['offset'] = offset;

    final result = await _convexClient.query<List<dynamic>>(
      ApiConfig.activitiesList,
      args: args,
    );

    return result
        .map((json) => Activity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get activity by ID
  /// Calls Convex function: activities:get
  Future<Activity> getActivity(String activityId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.activitiesGet,
      args: {'id': activityId},
    );

    return Activity.fromJson(result);
  }

  /// Create new activity
  /// Calls Convex function: activities:create
  Future<Activity> createActivity({
    required String clientId,
    required String stakeholderId,
    required String title,
    String? description,
    required ActivityType activityType,
    ActivityStatus? status,
    List<String>? goalIds,
    String? outcomeNotes,
  }) async {
    final args = {
      'client_id': clientId,
      'stakeholder_id': stakeholderId,
      'title': title,
      if (description != null) 'description': description,
      'activity_type': activityType.name,
      if (status != null) 'status': status.name,
      if (goalIds != null) 'goal_ids': goalIds,
      if (outcomeNotes != null) 'outcome_notes': outcomeNotes,
    };

    final result = await _convexClient.mutation<Map<String, dynamic>>(
      ApiConfig.activitiesCreate,
      args: args,
    );

    return Activity.fromJson(result);
  }

  /// Update activity
  /// Calls Convex function: activities:update
  Future<Activity> updateActivity({
    required String activityId,
    String? title,
    String? description,
    ActivityType? activityType,
    ActivityStatus? status,
    List<String>? goalIds,
    String? outcomeNotes,
  }) async {
    final args = {
      'id': activityId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (activityType != null) 'activity_type': activityType.name,
      if (status != null) 'status': status.name,
      if (goalIds != null) 'goal_ids': goalIds,
      if (outcomeNotes != null) 'outcome_notes': outcomeNotes,
    };

    final result = await _convexClient.mutation<Map<String, dynamic>>(
      ApiConfig.activitiesUpdate,
      args: args,
    );

    return Activity.fromJson(result);
  }

  // ==================== SHIFT NOTES ====================

  /// Get recent shift notes
  /// Calls Convex function: shiftNotes:getRecent
  Future<List<Map<String, dynamic>>> getRecentShiftNotes({
    int? limit,
    String? clientId,
  }) async {
    final args = <String, dynamic>{};
    if (limit != null) args['limit'] = limit;
    if (clientId != null) args['client_id'] = clientId;

    final result = await _convexClient.query<List<dynamic>>(
      ApiConfig.shiftNotesGetRecent,
      args: args,
    );

    return result.cast<Map<String, dynamic>>();
  }

  /// List shift notes with filtering
  /// Calls Convex function: shiftNotes:list
  Future<List<Map<String, dynamic>>> listShiftNotes({
    String? clientId,
    String? stakeholderId,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  }) async {
    final args = <String, dynamic>{};
    if (clientId != null) args['client_id'] = clientId;
    if (stakeholderId != null) args['stakeholder_id'] = stakeholderId;
    if (dateFrom != null) args['date_from'] = dateFrom;
    if (dateTo != null) args['date_to'] = dateTo;
    if (limit != null) args['limit'] = limit;
    if (offset != null) args['offset'] = offset;

    final result = await _convexClient.query<List<dynamic>>(
      ApiConfig.shiftNotesList,
      args: args,
    );

    return result.cast<Map<String, dynamic>>();
  }
}

/// Dashboard data model
class DashboardData {
  final int totalClients;
  final int activeClients;
  final int totalGoals;
  final int activeGoals;
  final List<Map<String, dynamic>> goalsAtRisk;
  final List<Activity> recentActivities;
  final List<Map<String, dynamic>> recentShiftNotes;
  final DashboardStatistics statistics;

  DashboardData({
    required this.totalClients,
    required this.activeClients,
    required this.totalGoals,
    required this.activeGoals,
    required this.goalsAtRisk,
    required this.recentActivities,
    required this.recentShiftNotes,
    required this.statistics,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalClients: json['total_clients'] as int,
      activeClients: json['active_clients'] as int,
      totalGoals: json['total_goals'] as int,
      activeGoals: json['active_goals'] as int,
      goalsAtRisk: (json['goals_at_risk'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      recentActivities: (json['recent_activities'] as List?)
              ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentShiftNotes: (json['recent_shift_notes'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      statistics:
          DashboardStatistics.fromJson(json['statistics'] as Map<String, dynamic>),
    );
  }
}

/// Dashboard statistics
class DashboardStatistics {
  final Map<String, int> goalsByStatus;
  final Map<String, int> activitiesByType;

  DashboardStatistics({
    required this.goalsByStatus,
    required this.activitiesByType,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      goalsByStatus: (json['goals_by_status'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      activitiesByType: (json['activities_by_type'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }
}

/// Client summary for dashboard
class ClientSummary {
  final Client client;
  final List<Map<String, dynamic>> goals;
  final List<Activity> recentActivities;
  final Map<String, dynamic>? lastShiftNote;

  ClientSummary({
    required this.client,
    required this.goals,
    required this.recentActivities,
    this.lastShiftNote,
  });

  factory ClientSummary.fromJson(Map<String, dynamic> json) {
    return ClientSummary(
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
      goals:
          (json['goals'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      recentActivities: (json['recent_activities'] as List?)
              ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastShiftNote: json['last_shift_note'] as Map<String, dynamic>?,
    );
  }
}
