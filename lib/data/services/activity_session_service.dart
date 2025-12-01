import '../../core/config/api_config.dart';
import '../../core/services/convex_client_service.dart';
import '../models/activity_session.dart';

/// Activity Session Service (Convex Backend)
/// Handles all communication with Convex activitySessions functions
class ActivitySessionService {
  final ConvexClientService _convexClient;

  ActivitySessionService(this._convexClient);

  // ==================== CREATE ====================

  /// Create a new activity session
  /// Calls Convex function: activitySessions:create
  Future<ActivitySession> createSession(ActivitySession session) async {
    try {
      final result = await _convexClient.mutation<Map<String, dynamic>>(
        ApiConfig.activitySessionsCreate,
        args: {
          'activity_id': session.activityId,
          'client_id': session.clientId,
          'user_id': session.stakeholderId,
          if (session.shiftNoteId != null) 'shift_note_id': session.shiftNoteId,
          'session_start_time': session.sessionStartTime.toIso8601String(),
          'session_end_time': session.sessionEndTime.toIso8601String(),
          'duration_minutes': session.durationMinutes,
          'location': session.location,
          'session_notes': session.sessionNotes,
          'participant_engagement': session.participantEngagement.value,
          'goal_progress': session.goalProgress
              .map((gp) => {
                    'goal_id': gp.goalId,
                    'progress_observed': gp.progressObserved,
                    'evidence_notes': gp.evidenceNotes,
                  })
              .toList(),
          'behavior_incidents': session.behaviorIncidents
              .map((incident) => {
                    'id': incident.id,
                    'behaviors_displayed': incident.behaviorsDisplayed,
                    'duration': incident.duration,
                    'severity': incident.severity.name,
                    'self_harm': incident.selfHarm,
                    'self_harm_types': incident.selfHarmTypes,
                    'self_harm_count': incident.selfHarmCount,
                    'initial_intervention': incident.initialIntervention,
                    if (incident.interventionDescription != null)
                      'intervention_description': incident.interventionDescription,
                    'second_support_needed': incident.secondSupportNeeded,
                    if (incident.secondSupportDescription != null)
                      'second_support_description': incident.secondSupportDescription,
                    'description': incident.description,
                  })
              .toList(),
        },
      );

      if (result == null) {
        throw Exception(
          'Backend returned null. The activitySessions:create function may not be returning the created document. '
          'Check SHIFT_NOTES_BACKEND_INTEGRATION.md for required backend changes.'
        );
      }

      return ActivitySession.fromJson(result);
    } catch (e) {
      print('❌ Error creating activity session: $e');
      throw Exception('Failed to create activity session: $e');
    }
  }

  // ==================== READ ====================

  /// Get session by ID with enriched details
  /// Calls Convex function: activitySessions:getById
  Future<ActivitySession> getSessionById(String id) async {
    try {
      final result = await _convexClient.query<Map<String, dynamic>>(
        ApiConfig.activitySessionsGet,
        args: {'session_id': id},
      );

      return ActivitySession.fromJson(result);
    } catch (e) {
      throw Exception('Failed to get activity session: $e');
    }
  }

  /// List sessions with filters
  /// Calls Convex function: activitySessions:list
  Future<List<ActivitySession>> listSessions({
    String? clientId,
    String? activityId,
    String? stakeholderId,
    String? shiftNoteId,
    String? goalId,
    String? dateFrom,
    String? dateTo,
    int? minEngagement,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final args = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (clientId != null) args['client_id'] = clientId;
      if (activityId != null) args['activity_id'] = activityId;
      if (stakeholderId != null) args['user_id'] = stakeholderId;
      if (shiftNoteId != null) args['shift_note_id'] = shiftNoteId;
      if (goalId != null) args['goal_id'] = goalId;
      if (dateFrom != null) args['date_from'] = dateFrom;
      if (dateTo != null) args['date_to'] = dateTo;
      if (minEngagement != null) args['min_engagement'] = minEngagement;

      final result = await _convexClient.query<List<dynamic>>(
        ApiConfig.activitySessionsList,
        args: args,
      );

      return result
          .map((json) => ActivitySession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to list activity sessions: $e');
    }
  }

  // ==================== UPDATE ====================

  /// Update an existing session
  /// Calls Convex function: activitySessions:update
  Future<ActivitySession> updateSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final args = {'session_id': sessionId, ...updates};
      
      // Try to get the result, but handle null case
      try {
        final result = await _convexClient.mutation<Map<String, dynamic>>(
          ApiConfig.activitySessionsUpdate,
          args: args,
        );
        
        return ActivitySession.fromJson(result);
      } on TypeError catch (e) {
        // If the mutation returns null, the cast will fail with TypeError
        // The update likely succeeded but returned null
        // Fetch the updated session to return it
        if (e.toString().contains("type 'Null' is not a subtype") ||
            e.toString().contains('type cast')) {
          return await getSessionById(sessionId);
        }
        // Re-throw other TypeErrors
        rethrow;
      } catch (e) {
        // Check if it's a type cast error from null return
        if (e.toString().contains("type 'Null' is not a subtype") ||
            e.toString().contains('type cast')) {
          // Update was successful but returned null, fetch the updated session
          return await getSessionById(sessionId);
        }
        // Re-throw other errors
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to update activity session: $e');
    }
  }

  // ==================== DELETE ====================

  /// Delete a session
  /// Calls Convex function: activitySessions:delete
  Future<void> deleteSession(String sessionId) async {
    try {
      await _convexClient.mutation<void>(
        ApiConfig.activitySessionsDelete,
        args: {'session_id': sessionId},
      );
    } catch (e) {
      throw Exception('Failed to delete activity session: $e');
    }
  }

  // ==================== REPORTS ====================

  /// Get activity effectiveness report for a goal
  /// Calls Convex function: activitySessions:getActivityEffectivenessReport
  /// Returns analytics showing which activities are most effective for a specific goal
  Future<Map<String, dynamic>> getActivityEffectivenessReport(
      String goalId) async {
    try {
      final result = await _convexClient.query<Map<String, dynamic>>(
        ApiConfig.activitySessionsGetActivityEffectivenessReport,
        args: {'goal_id': goalId},
      );

      return result;
    } catch (e) {
      throw Exception('Failed to get activity effectiveness report: $e');
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Create multiple sessions in batch (for bulk sync)
  /// This is useful when syncing multiple draft sessions from offline storage
  Future<List<ActivitySession>> createSessionsBatch(
      List<ActivitySession> sessions) async {
    final results = <ActivitySession>[];

    for (final session in sessions) {
      try {
        final created = await createSession(session);
        results.add(created);
      } catch (e) {
        // Log error but continue with other sessions
        print('Failed to create session ${session.id}: $e');
        rethrow;
      }
    }

    return results;
  }
}
