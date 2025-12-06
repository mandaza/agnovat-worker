import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../models/activity_session.dart';
import '../models/activity_session_enums.dart';

part 'drift_database.g.dart';

/// Local draft sessions table for offline storage (renamed to avoid conflict with Freezed model)
@DataClassName('LocalDraftSession')
class LocalDraftSessions extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text()();
  TextColumn get clientId => text()();
  TextColumn get stakeholderId => text()();
  DateTimeColumn get performedAt => dateTime()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get sessionNotes => text().nullable()();
  IntColumn get participantEngagement => integer().nullable()();
  TextColumn get goalProgress => text()(); // JSON string
  TextColumn get behaviorIncidentIds => text()(); // JSON array
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalDraftSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
      return NativeDatabase(file);
    });
  }

  // CRUD Operations for Draft Activity Sessions

  /// Get all draft sessions
  Future<List<DraftActivitySession>> getAllDraftSessions() async {
    final rows = await select(localDraftSessions).get();
    return rows.map(_draftFromRow).toList();
  }

  /// Get draft sessions by sync status
  Future<List<DraftActivitySession>> getDraftsByStatus(SyncStatus status) async {
    final query = select(localDraftSessions)
      ..where((tbl) => tbl.syncStatus.equals(status.value));
    final rows = await query.get();
    return rows.map(_draftFromRow).toList();
  }

  /// Insert a draft session
  Future<int> insertDraftSession(DraftActivitySession draft) {
    return into(localDraftSessions).insert(
      LocalDraftSessionsCompanion.insert(
        id: draft.id,
        activityId: draft.activityId,
        clientId: draft.clientId,
        stakeholderId: draft.stakeholderId,
        performedAt: draft.performedAt,
        durationMinutes: Value(draft.durationMinutes),
        sessionNotes: Value(draft.sessionNotes),
        participantEngagement: Value(draft.participantEngagement?.value),
        goalProgress: jsonEncode(draft.goalProgress.map((e) => {
          'goal_id': e.goalId,
          'progress_observed': e.progressObserved,
          'evidence_notes': e.evidenceNotes,
        }).toList()),
        behaviorIncidentIds: jsonEncode(draft.behaviorIncidentIds),
        createdAt: draft.createdAt,
        updatedAt: draft.updatedAt,
        syncStatus: draft.syncStatus.value,
      ),
    );
  }

  /// Update draft session sync status
  Future<int> updateDraftSyncStatus(String id, SyncStatus status) {
    return (update(localDraftSessions)..where((tbl) => tbl.id.equals(id)))
        .write(LocalDraftSessionsCompanion(
      syncStatus: Value(status.value),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Delete a draft session
  Future<int> deleteDraftSession(String id) {
    return (delete(localDraftSessions)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  /// Delete all synced drafts
  Future<int> deleteSyncedDrafts() {
    return (delete(localDraftSessions)
          ..where((tbl) => tbl.syncStatus.equals(SyncStatus.synced.value)))
        .go();
  }

  /// Watch draft sessions (for real-time updates)
  Stream<List<DraftActivitySession>> watchDraftSessions() {
    return select(localDraftSessions)
        .watch()
        .map((rows) => rows.map(_draftFromRow).toList());
  }

  /// Watch pending draft sessions
  Stream<List<DraftActivitySession>> watchPendingDrafts() {
    return (select(localDraftSessions)
          ..where((tbl) => tbl.syncStatus.equals(SyncStatus.pending.value)))
        .watch()
        .map((rows) => rows.map(_draftFromRow).toList());
  }

  /// Get count of pending syncs
  Future<int> getPendingSyncCount() async {
    final query = selectOnly(localDraftSessions)
      ..addColumns([localDraftSessions.id.count()])
      ..where(localDraftSessions.syncStatus.equals(SyncStatus.pending.value));

    final result = await query.getSingle();
    return result.read(localDraftSessions.id.count()) ?? 0;
  }

  /// Clear all draft sessions (used on sign-out to prevent data leakage)
  Future<int> clearAllDrafts() async {
    return delete(localDraftSessions).go();
  }

  /// Convert database row to DraftActivitySession model
  DraftActivitySession _draftFromRow(LocalDraftSession row) {
    try {
      final goalProgressList = jsonDecode(row.goalProgress) as List;
      final behaviorIds = jsonDecode(row.behaviorIncidentIds) as List;

      return DraftActivitySession(
        id: row.id,
        activityId: row.activityId,
        clientId: row.clientId,
        stakeholderId: row.stakeholderId,
        performedAt: row.performedAt,
        durationMinutes: row.durationMinutes,
        sessionNotes: row.sessionNotes,
        participantEngagement: row.participantEngagement != null
            ? ParticipantEngagement.fromValue(row.participantEngagement!)
            : null,
        goalProgress: goalProgressList
            .map((e) => GoalProgressEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        behaviorIncidentIds: behaviorIds.cast<String>(),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        syncStatus: SyncStatus.fromString(row.syncStatus),
      );
    } catch (e) {
      // If parsing fails, return a basic DraftActivitySession with defaults
      return DraftActivitySession(
        id: row.id,
        activityId: row.activityId,
        clientId: row.clientId,
        stakeholderId: row.stakeholderId,
        performedAt: row.performedAt,
        durationMinutes: row.durationMinutes,
        sessionNotes: row.sessionNotes,
        participantEngagement: null,
        goalProgress: const [],
        behaviorIncidentIds: const [],
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        syncStatus: SyncStatus.pending,
      );
    }
  }
}
