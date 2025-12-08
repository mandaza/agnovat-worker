import '../../core/config/api_config.dart';
import '../../core/services/convex_client_service.dart';
import '../models/client.dart';
import '../models/activity.dart';
import '../models/goal.dart';
import '../models/user.dart';
import '../models/shift_note.dart';

/// MCP API Service (Convex Backend)
/// Handles all communication with Convex functions
class McpApiService {
  final ConvexClientService _convexClient;

  McpApiService(this._convexClient);

  // ==================== AUTH / USERS ====================

  /// Get current user profile from Convex
  /// Calls Convex function: auth:getCurrentUser
  /// Requires clerk_id (stored locally after login)
  Future<User> getCurrentUser({required String clerkId}) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.authGetCurrentUser,
      args: {'clerk_id': clerkId},
    );

    return User.fromJson(result);
  }

  /// Get user by ID
  /// Calls Convex function: users:get
  Future<User> getUserById(String userId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.usersGet,
      args: {'id': userId},
    );

    return User.fromJson(result);
  }

  /// List all users
  /// Calls Convex function: users:list
  Future<List<User>> listUsers({
    String? role,
    bool? active,
    int? limit,
    int? offset,
  }) async {
    final args = <String, dynamic>{};
    if (role != null) args['role'] = role;
    if (active != null) args['active'] = active;
    if (limit != null) args['limit'] = limit;
    if (offset != null) args['offset'] = offset;

    final result = await _convexClient.query<List<dynamic>?>(
      ApiConfig.usersList,
      args: args,
    );

    return (result ?? [])
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get user profile with stakeholder details
  /// Calls Convex function: auth:getUserProfile
  /// Requires clerk_id (stored locally after login)
  Future<User> getUserProfile({required String clerkId}) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.authGetUserProfile,
      args: {'clerk_id': clerkId},
    );

    return User.fromJson(result);
  }

  /// Sync user from Clerk to Convex
  /// Calls Convex function: auth:syncUserFromClerk
  /// Call this after successful Clerk login
  Future<User> syncUserFromClerk({
    required String clerkId,
    required String email,
    required String name,
    String? imageUrl,
  }) async {
    final result = await _convexClient.mutation<Map<String, dynamic>>(
      ApiConfig.authSyncUserFromClerk,
      args: {
        'clerk_id': clerkId,
        'email': email,
        'name': name,
        if (imageUrl != null) 'image_url': imageUrl,
      },
    );

    return User.fromJson(result);
  }

  /// Update user profile
  /// Calls Convex function: auth:updateProfile
  Future<User> updateUserProfile({
    required String clerkId,
    String? name,
    String? imageUrl,
  }) async {
    final args = {
      'clerk_id': clerkId,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
    };

    final result = await _convexClient.mutation<Map<String, dynamic>>(
      ApiConfig.authUpdateProfile,
      args: args,
    );

    return User.fromJson(result);
  }

  /// Update last login timestamp
  /// Calls Convex function: auth:updateLastLogin
  Future<void> updateLastLogin(String clerkId) async {
    await _convexClient.mutation(
      ApiConfig.authUpdateLastLogin,
      args: {'clerk_id': clerkId},
    );
  }

  // ==================== STAKEHOLDERS ====================

  /// List all stakeholders with optional filtering
  /// Calls Convex function: stakeholders:list
  Future<List<dynamic>> listStakeholders({
    String? role,
    bool? active,
    int? limit,
    int? offset,
  }) async {
    final args = <String, dynamic>{};
    if (role != null) args['role'] = role;
    if (active != null) args['active'] = active;
    if (limit != null) args['limit'] = limit;
    if (offset != null) args['offset'] = offset;

    final result = await _convexClient.query<List<dynamic>?>(
      ApiConfig.stakeholdersList,
      args: args,
    );

    return result ?? [];
  }

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

    final result = await _convexClient.query<List<dynamic>?>(
      ApiConfig.clientsList,
      args: args,
    );

    return (result ?? [])
        .map((json) {
          final jsonMap = json as Map<String, dynamic>;
          // If the data includes stats, return ClientWithStats
          if (jsonMap.containsKey('active_goals') || jsonMap.containsKey('total_activities')) {
            return ClientWithStats.fromJson(jsonMap);
          }
          return Client.fromJson(jsonMap);
        })
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
    final result = await _convexClient.query<List<dynamic>?>(
      ApiConfig.clientsSearch,
      args: {'search_term': searchTerm},
    );

    return (result ?? [])
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

    final result = await _convexClient.query<List<dynamic>?>(
      ApiConfig.activitiesList,
      args: args,
    );

    return (result ?? [])
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

  /// List goals
  /// Calls Convex function: goals:list
  Future<List<Goal>> listGoals({
    String? clientId,
    String? status,
    String? category,
    bool? archived,
    int? limit,
    int? offset,
  }) async {
    final args = <String, dynamic>{};
    if (clientId != null) args['client_id'] = clientId;
    if (status != null) args['status'] = status;
    if (category != null) args['category'] = category;
    if (archived != null) args['archived'] = archived;
    if (limit != null) args['limit'] = limit;
    if (offset != null) args['offset'] = offset;

    final result = await _convexClient.query<List<dynamic>?>(
      ApiConfig.goalsList,
      args: args,
    );

    return (result ?? [])
        .map((json) => Goal.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get goal by ID
  /// Calls Convex function: goals:get
  Future<Goal> getGoal(String goalId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.goalsGet,
      args: {'id': goalId},
    );

    return Goal.fromJson(result);
  }

  /// Create new activity
  /// Calls Convex function: activities:create
  Future<Activity> createActivity({
    required String clientId,
    String? stakeholderId,
    required String title,
    String? description,
    required ActivityType activityType,
    ActivityStatus? status,
    List<String>? goalIds,
    String? outcomeNotes,
  }) async {
    final args = {
      'client_id': clientId,
      if (stakeholderId != null) 'stakeholder_id': stakeholderId,
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

  /// Get shift note by ID
  /// Calls Convex function: shiftNotes:get
  Future<ShiftNote> getShiftNote(String shiftNoteId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.shiftNotesGet,
      args: {'id': shiftNoteId},
    );

    return ShiftNote.fromJson(result);
  }

  /// Get recent shift notes
  /// Calls Convex function: shiftNotes:getRecent
  Future<List<Map<String, dynamic>>> getRecentShiftNotes({
    int? limit,
    String? clientId,
  }) async {
    final args = <String, dynamic>{};
    if (limit != null) args['limit'] = limit;
    if (clientId != null) args['client_id'] = clientId;

    final result = await _convexClient.query<List<dynamic>?>(
      ApiConfig.shiftNotesGetRecent,
      args: args,
    );

    return (result ?? []).cast<Map<String, dynamic>>();
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
    if (stakeholderId != null) args['user_id'] = stakeholderId; // Backend expects user_id, not stakeholder_id
    if (dateFrom != null) args['date_from'] = dateFrom;
    if (dateTo != null) args['date_to'] = dateTo;
    if (limit != null) args['limit'] = limit;
    if (offset != null) args['offset'] = offset;

    final result = await _convexClient.query(
      ApiConfig.shiftNotesList,
      args: args,
    );

    // Handle null or non-list results
    if (result == null) {
      return [];
    }
    
    // Check if result is a list
    if (result is! List) {
      return [];
    }

    return result.cast<Map<String, dynamic>>();
  }

  /// Create a new shift note
  /// Calls Convex function: shiftNotes:create
  Future<Map<String, dynamic>> createShiftNote({
    required String clientId,
    required String userId,
    required String shiftDate, // YYYY-MM-DD
    required String startTime, // HH:MM
    required String endTime, // HH:MM
    List<String>? primaryLocations,
    required String rawNotes,
    List<String>? activityIds,
    List<Map<String, dynamic>>? goalsProgress,
  }) async {
    try {
      final args = <String, dynamic>{
        'client_id': clientId,
        'user_id': userId,
        'shift_date': shiftDate,
        'start_time': startTime,
        'end_time': endTime,
        'raw_notes': rawNotes,
      };

      if (primaryLocations != null && primaryLocations.isNotEmpty) {
        args['primary_locations'] = primaryLocations;
      }
      if (activityIds != null && activityIds.isNotEmpty) {
        args['activity_ids'] = activityIds;
      }
      if (goalsProgress != null && goalsProgress.isNotEmpty) {
        args['goals_progress'] = goalsProgress;
      }

      final result = await _convexClient.mutation<dynamic>(
        ApiConfig.shiftNotesCreate,
        args: args,
      );

      // Handle null response
      if (result == null) {
        throw Exception('Convex returned null. Make sure your shiftNotes:create function exists and returns a value.');
      }

      // Handle non-map response
      if (result is! Map<String, dynamic>) {
        throw Exception('Convex returned unexpected type: ${result.runtimeType}. Expected Map<String, dynamic>.');
      }

      return result;
    } catch (e) {
      print('❌ Error in createShiftNote: $e');
      rethrow;
    }
  }

  /// Update an existing shift note
  /// Calls Convex function: shiftNotes:update
  Future<Map<String, dynamic>> updateShiftNote({
    required String shiftNoteId,
    String? userId,
    String? shiftDate,
    String? startTime,
    String? endTime,
    List<String>? primaryLocations,
    String? rawNotes,
    List<String>? activityIds,
    List<Map<String, dynamic>>? goalsProgress,
  }) async {
    final args = <String, dynamic>{
      'id': shiftNoteId, // Changed from 'shift_note_id' to 'id' to match Convex validator
    };

    if (userId != null) args['user_id'] = userId;
    if (shiftDate != null) args['shift_date'] = shiftDate;
    if (startTime != null) args['start_time'] = startTime;
    if (endTime != null) args['end_time'] = endTime;
    if (primaryLocations != null) args['primary_locations'] = primaryLocations;
    if (rawNotes != null) args['raw_notes'] = rawNotes;
    if (activityIds != null) args['activity_ids'] = activityIds;
    if (goalsProgress != null) args['goals_progress'] = goalsProgress;

    final result = await _convexClient.mutation<Map<String, dynamic>>(
      ApiConfig.shiftNotesUpdate,
      args: args,
    );

    return result;
  }

  /// Delete a shift note
  /// Calls Convex function: shiftNotes:remove
  Future<void> deleteShiftNote(String shiftNoteId) async {
    await _convexClient.mutation(
      ApiConfig.shiftNotesDelete,
      args: {'id': shiftNoteId},
    );
  }

  /// Submit a shift note (transition from draft to submitted)
  /// Calls Convex function: shiftNotes:submit
  Future<Map<String, dynamic>> submitShiftNote(String shiftNoteId) async {
    final result = await _convexClient.mutation<Map<String, dynamic>>(
      ApiConfig.shiftNotesSubmit,
      args: {'id': shiftNoteId},
    );

    return result;
  }

  /// Add activity session to shift note
  /// Links an activity session to a shift note
  /// Calls Convex function: shiftNotes:addActivitySession
  Future<Map<String, dynamic>> addActivitySessionToShiftNote({
    required String shiftNoteId,
    required String activitySessionId,
  }) async {
    final result = await _convexClient.mutation<Map<String, dynamic>>(
      ApiConfig.shiftNotesAddActivitySession,
      args: {
        'shift_note_id': shiftNoteId,
        'activity_session_id': activitySessionId,
      },
    );

    return result;
  }

  /// Get shift note with all activity sessions
  /// Returns complete shift note with embedded sessions and behaviors
  /// Calls Convex function: shiftNotes:getWithSessions
  Future<Map<String, dynamic>> getShiftNoteWithSessions(String shiftNoteId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      ApiConfig.shiftNotesGetWithSessions,
      args: {'id': shiftNoteId},
    );

    return result;
  }

  // ==================== MEDIA UPLOAD METHODS ====================

  /// Generate upload URL for media files
  /// Returns a URL that can be used to upload files to Convex storage
  /// Calls Convex function: activitySessions:generateUploadUrl
  Future<String> generateMediaUploadUrl() async {
    final result = await _convexClient.mutation<String>(
      ApiConfig.activitySessionsGenerateUploadUrl,
      args: {},
    );

    return result;
  }

  /// Add media to an activity session
  /// Links uploaded media (photo/video) to an activity session
  /// Calls Convex function: activitySessions:addMedia
  Future<Map<String, dynamic>> addMediaToSession({
    required String sessionId,
    required String storageId,
    required String type, // 'photo' or 'video'
    required String fileName,
    required int fileSize,
    required String mimeType,
  }) async {
    final result = await _convexClient.mutation<Map<String, dynamic>>(
      ApiConfig.activitySessionsAddMedia,
      args: {
        'session_id': sessionId,
        'storage_id': storageId,
        'type': type,
        'file_name': fileName,
        'file_size': fileSize,
        'mime_type': mimeType,
      },
    );

    return result;
  }

  /// Get file URL for displaying media
  /// Returns a URL that can be used to display/download the media file
  /// Calls Convex function: activitySessions:getFileUrl
  Future<String> getMediaFileUrl(String storageId) async {
    final result = await _convexClient.query<String>(
      ApiConfig.activitySessionsGetFileUrl,
      args: {'storage_id': storageId},
    );

    return result;
  }

  /// Remove media from an activity session
  /// Deletes the media file and removes it from the session
  /// Calls Convex function: activitySessions:removeMedia
  Future<Map<String, dynamic>> removeMediaFromSession({
    required String sessionId,
    required String mediaId,
  }) async {
    final result = await _convexClient.mutation<Map<String, dynamic>>(
      ApiConfig.activitySessionsRemoveMedia,
      args: {
        'session_id': sessionId,
        'media_id': mediaId,
      },
    );

    return result;
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
      totalClients: (json['total_clients'] as num).toInt(),
      activeClients: (json['active_clients'] as num).toInt(),
      totalGoals: (json['total_goals'] as num).toInt(),
      activeGoals: (json['active_goals'] as num).toInt(),
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
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      activitiesByType: (json['activities_by_type'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
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
