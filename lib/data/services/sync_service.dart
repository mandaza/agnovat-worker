import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../database/drift_database.dart';
import '../services/activity_session_service.dart';
import '../models/activity_session.dart';
import '../models/activity_session_enums.dart';

/// Service for syncing offline draft sessions to Convex backend
class SyncService {
  final AppDatabase _db;
  final ActivitySessionService _sessionService;

  SyncService(this._db, this._sessionService);

  // ==================== SYNC OPERATIONS ====================

  /// Sync all pending draft sessions to backend
  /// Returns number of successfully synced sessions
  Future<int> syncPendingDrafts() async {
    final pendingDrafts = await _db.getDraftsByStatus(SyncStatus.pending);

    if (pendingDrafts.isEmpty) {
      debugPrint('✅ No pending drafts to sync');
      return 0;
    }

    debugPrint('🔄 Syncing ${pendingDrafts.length} pending draft sessions...');

    int successCount = 0;

    for (final draft in pendingDrafts) {
      try {
        // Mark as syncing
        await _db.updateDraftSyncStatus(draft.id, SyncStatus.syncing);

        // Validate draft has required fields
        if (draft.durationMinutes == null || draft.sessionNotes == null) {
          throw Exception('Draft session incomplete - missing required fields');
        }

        // TODO: This needs to be updated for the new embedded behavior architecture
        // Currently drafts use the old structure with behavior IDs
        // New structure requires full BehaviorIncident objects

        // Convert draft to ActivitySession
        // Calculate session times from performedAt and duration
        final sessionStartTime = draft.performedAt;
        final sessionEndTime = draft.performedAt.add(
          Duration(minutes: draft.durationMinutes ?? 0),
        );

        final session = ActivitySession(
          id: draft.id,
          activityId: draft.activityId,
          clientId: draft.clientId,
          stakeholderId: draft.stakeholderId,
          sessionStartTime: sessionStartTime,
          sessionEndTime: sessionEndTime,
          durationMinutes: draft.durationMinutes!,
          location: 'In the home', // TODO: Get from draft or user preference
          sessionNotes: draft.sessionNotes!,
          participantEngagement:
              draft.participantEngagement ?? ParticipantEngagement.moderate,
          goalProgress: draft.goalProgress,
          behaviorIncidents: const [], // TODO: Load full behavior incidents from behavior_incident_ids
          createdAt: draft.createdAt,
          updatedAt: draft.updatedAt,
        );

        // Sync to Convex backend
        await _sessionService.createSession(session);

        // Mark as synced (but don't delete yet - allow user to review)
        await _db.updateDraftSyncStatus(draft.id, SyncStatus.synced);

        successCount++;
        debugPrint('✅ Synced draft session: ${draft.id}');
      } catch (e) {
        debugPrint('❌ Failed to sync draft ${draft.id}: $e');
        await _db.updateDraftSyncStatus(draft.id, SyncStatus.failed);
      }
    }

    debugPrint('✅ Sync complete: $successCount/${pendingDrafts.length} successful');
    return successCount;
  }

  /// Retry failed syncs
  /// Returns number of successfully retried sessions
  Future<int> retryFailedSyncs() async {
    final failedDrafts = await _db.getDraftsByStatus(SyncStatus.failed);

    if (failedDrafts.isEmpty) {
      debugPrint('✅ No failed syncs to retry');
      return 0;
    }

    debugPrint('🔄 Retrying ${failedDrafts.length} failed syncs...');

    // Reset status to pending
    for (final draft in failedDrafts) {
      await _db.updateDraftSyncStatus(draft.id, SyncStatus.pending);
    }

    // Attempt sync again
    return await syncPendingDrafts();
  }

  /// Clean up synced drafts from local database
  /// Call this after user confirms data is in backend
  Future<int> deleteSyncedDrafts() async {
    final count = await _db.deleteSyncedDrafts();
    debugPrint('🗑️ Deleted $count synced draft sessions');
    return count;
  }

  // ==================== STATUS OPERATIONS ====================

  /// Get count of pending syncs
  Future<int> getPendingSyncCount() async {
    return await _db.getPendingSyncCount();
  }

  /// Get sync status summary
  Future<SyncStatusSummary> getSyncStatusSummary() async {
    final allDrafts = await _db.getAllDraftSessions();

    final pending =
        allDrafts.where((d) => d.syncStatus == SyncStatus.pending).length;
    final syncing =
        allDrafts.where((d) => d.syncStatus == SyncStatus.syncing).length;
    final synced =
        allDrafts.where((d) => d.syncStatus == SyncStatus.synced).length;
    final failed =
        allDrafts.where((d) => d.syncStatus == SyncStatus.failed).length;

    return SyncStatusSummary(
      total: allDrafts.length,
      pending: pending,
      syncing: syncing,
      synced: synced,
      failed: failed,
    );
  }

  /// Check if there are any pending syncs
  Future<bool> hasPendingSyncs() async {
    final count = await getPendingSyncCount();
    return count > 0;
  }

  // ==================== DRAFT OPERATIONS ====================

  /// Save a draft session locally
  Future<void> saveDraft(DraftActivitySession draft) async {
    await _db.insertDraftSession(draft);
    debugPrint('💾 Saved draft session locally: ${draft.id}');
  }

  /// Get all draft sessions
  Future<List<DraftActivitySession>> getAllDrafts() async {
    return await _db.getAllDraftSessions();
  }

  /// Delete a specific draft
  Future<void> deleteDraft(String id) async {
    await _db.deleteDraftSession(id);
    debugPrint('🗑️ Deleted draft session: $id');
  }

  // ==================== AUTO-SYNC ====================

  /// Auto-sync if network is available
  /// Call this periodically or on app resume
  Future<void> autoSyncIfNeeded() async {
    final hasPending = await hasPendingSyncs();

    if (!hasPending) {
      debugPrint('✅ No pending syncs needed');
      return;
    }

    // Check network availability (simplified - you can add connectivity_plus)
    // For now, we'll just attempt sync and handle errors
    try {
      await syncPendingDrafts();
    } catch (e) {
      debugPrint('❌ Auto-sync failed (likely offline): $e');
    }
  }
}

/// Summary of sync statuses
class SyncStatusSummary {
  final int total;
  final int pending;
  final int syncing;
  final int synced;
  final int failed;

  SyncStatusSummary({
    required this.total,
    required this.pending,
    required this.syncing,
    required this.synced,
    required this.failed,
  });

  /// Get user-friendly status message
  String get statusMessage {
    if (total == 0) return 'No sessions';
    if (failed > 0) return '$failed failed, $pending pending';
    if (pending > 0) return '$pending pending sync';
    if (synced > 0) return 'All synced ($synced)';
    return 'Unknown status';
  }

  /// Check if all synced
  bool get allSynced => total > 0 && synced == total && failed == 0;

  /// Check if any failures
  bool get hasFailures => failed > 0;

  /// Check if needs sync
  bool get needsSync => pending > 0 || failed > 0;
}
