import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/activity_session.dart';
import '../../data/models/activity_session_enums.dart';
import '../../data/services/activity_session_service.dart';
import '../../data/services/sync_service.dart';
import '../../data/database/drift_database.dart';

// ==================== STATE CLASSES ====================

/// Activity Sessions state model
class ActivitySessionsState {
  final bool isLoading;
  final String? error;
  final List<ActivitySession> sessions;
  final String? selectedClientId;

  const ActivitySessionsState({
    this.isLoading = true,
    this.error,
    this.sessions = const [],
    this.selectedClientId,
  });

  ActivitySessionsState copyWith({
    bool? isLoading,
    String? error,
    List<ActivitySession>? sessions,
    String? selectedClientId,
  }) {
    return ActivitySessionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sessions: sessions ?? this.sessions,
      selectedClientId: selectedClientId ?? this.selectedClientId,
    );
  }
}

/// Form state for creating/editing activity sessions
class SessionFormState {
  final bool isSubmitting;
  final String? error;
  final ActivitySession? savedSession;

  const SessionFormState({
    this.isSubmitting = false,
    this.error,
    this.savedSession,
  });

  SessionFormState copyWith({
    bool? isSubmitting,
    String? error,
    ActivitySession? savedSession,
  }) {
    return SessionFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      savedSession: savedSession,
    );
  }
}

// ==================== PROVIDERS ====================

/// List sessions for a specific client
final sessionListProvider = FutureProvider.family<List<ActivitySession>, String>(
  (ref, clientId) async {
    final service = ref.watch(activitySessionServiceProvider);
    return service.listSessions(clientId: clientId, limit: 100);
  },
);

/// Single session provider
final sessionProvider = FutureProvider.family<ActivitySession, String>(
  (ref, sessionId) async {
    final service = ref.watch(activitySessionServiceProvider);
    return service.getSessionById(sessionId);
  },
);

/// Draft sessions stream (for real-time offline updates)
final draftSessionsStreamProvider = StreamProvider<List<DraftActivitySession>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchDraftSessions();
});

/// Pending drafts stream
final pendingDraftsStreamProvider = StreamProvider<List<DraftActivitySession>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchPendingDrafts();
});

/// Sync status summary provider
final syncStatusSummaryProvider = FutureProvider<SyncStatusSummary>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.getSyncStatusSummary();
});

/// Pending sync count provider
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.getPendingSyncCount();
});

// ==================== STATE NOTIFIERS ====================

/// Activity Sessions Notifier
class ActivitySessionsNotifier extends StateNotifier<ActivitySessionsState> {
  final ActivitySessionService _service;

  ActivitySessionsNotifier(this._service) : super(const ActivitySessionsState());

  /// Load sessions for a specific client
  Future<void> loadSessions(String clientId) async {
    state = state.copyWith(isLoading: true, error: null, selectedClientId: clientId);

    try {
      final sessions = await _service.listSessions(clientId: clientId, limit: 100);
      state = state.copyWith(
        isLoading: false,
        sessions: sessions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh sessions
  Future<void> refresh() async {
    if (state.selectedClientId != null) {
      await loadSessions(state.selectedClientId!);
    }
  }

  /// Delete a session
  Future<bool> deleteSession(String sessionId) async {
    try {
      await _service.deleteSession(sessionId);

      // Remove from local state
      state = state.copyWith(
        sessions: state.sessions.where((s) => s.id != sessionId).toList(),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Provider for Activity Sessions Notifier
final activitySessionsProvider = StateNotifierProvider<ActivitySessionsNotifier, ActivitySessionsState>((ref) {
  final service = ref.watch(activitySessionServiceProvider);
  return ActivitySessionsNotifier(service);
});

/// Session Form Notifier
class SessionFormNotifier extends StateNotifier<SessionFormState> {
  final ActivitySessionService _service;
  final AppDatabase _db;

  SessionFormNotifier(this._service, this._db) : super(const SessionFormState());

  /// Save as draft (offline)
  Future<bool> saveDraft(DraftActivitySession draft) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      await _db.insertDraftSession(draft);
      state = const SessionFormState(); // Reset
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Submit session directly (online)
  Future<bool> submitSession(ActivitySession session) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final created = await _service.createSession(session);
      state = SessionFormState(savedSession: created);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update existing session
  Future<bool> updateSession(String sessionId, Map<String, dynamic> updates) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final updated = await _service.updateSession(sessionId, updates);
      state = SessionFormState(savedSession: updated);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset form state
  void reset() {
    state = const SessionFormState();
  }
}

/// Provider for Session Form Notifier
final sessionFormProvider = StateNotifierProvider<SessionFormNotifier, SessionFormState>((ref) {
  final service = ref.watch(activitySessionServiceProvider);
  final db = ref.watch(appDatabaseProvider);
  return SessionFormNotifier(service, db);
});

/// Sync Notifier
class SyncNotifier extends StateNotifier<AsyncValue<int>> {
  final SyncService _syncService;

  SyncNotifier(this._syncService) : super(const AsyncValue.data(0));

  /// Trigger manual sync
  Future<void> syncNow() async {
    state = const AsyncValue.loading();

    try {
      final count = await _syncService.syncPendingDrafts();
      state = AsyncValue.data(count);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Retry failed syncs
  Future<void> retryFailed() async {
    state = const AsyncValue.loading();

    try {
      final count = await _syncService.retryFailedSyncs();
      state = AsyncValue.data(count);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Clean up synced drafts
  Future<void> cleanupSynced() async {
    try {
      await _syncService.deleteSyncedDrafts();
    } catch (e) {
      // Ignore errors during cleanup
    }
  }
}

/// Provider for Sync Notifier
final syncNotifierProvider = StateNotifierProvider<SyncNotifier, AsyncValue<int>>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncNotifier(syncService);
});
