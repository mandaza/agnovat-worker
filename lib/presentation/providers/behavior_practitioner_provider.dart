import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/shift_note.dart';
import '../../../data/models/activity_session.dart';
import '../../../data/models/activity_session_enums.dart';
import '../../../core/providers/service_providers.dart';
import '../../../data/services/providers.dart';

/// Behavior incident with context (shift note and session info)
class BehaviorIncidentWithContext {
  final BehaviorIncident incident;
  final ShiftNote shiftNote;
  final ActivitySession session;
  final String? clientName;
  final String? workerName;

  BehaviorIncidentWithContext({
    required this.incident,
    required this.shiftNote,
    required this.session,
    this.clientName,
    this.workerName,
  });
}

/// Behavior Practitioner Dashboard State
class BehaviorPractitionerState {
  final bool isLoading;
  final String? error;
  final List<ShiftNote> shiftNotes;
  final List<BehaviorIncidentWithContext> behaviorIncidents;
  final int totalIncidentsCount;
  final int highSeverityCount;
  final int recentIncidentsCount; // Last 7 days

  const BehaviorPractitionerState({
    this.isLoading = true,
    this.error,
    this.shiftNotes = const [],
    this.behaviorIncidents = const [],
    this.totalIncidentsCount = 0,
    this.highSeverityCount = 0,
    this.recentIncidentsCount = 0,
  });

  BehaviorPractitionerState copyWith({
    bool? isLoading,
    String? error,
    List<ShiftNote>? shiftNotes,
    List<BehaviorIncidentWithContext>? behaviorIncidents,
    int? totalIncidentsCount,
    int? highSeverityCount,
    int? recentIncidentsCount,
  }) {
    return BehaviorPractitionerState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      shiftNotes: shiftNotes ?? this.shiftNotes,
      behaviorIncidents: behaviorIncidents ?? this.behaviorIncidents,
      totalIncidentsCount: totalIncidentsCount ?? this.totalIncidentsCount,
      highSeverityCount: highSeverityCount ?? this.highSeverityCount,
      recentIncidentsCount: recentIncidentsCount ?? this.recentIncidentsCount,
    );
  }
}

/// Behavior Practitioner Provider
final behaviorPractitionerProvider =
    AutoDisposeNotifierProvider<BehaviorPractitionerNotifier, BehaviorPractitionerState>(
  BehaviorPractitionerNotifier.new,
);

/// Behavior Practitioner Notifier
class BehaviorPractitionerNotifier extends AutoDisposeNotifier<BehaviorPractitionerState> {
  @override
  BehaviorPractitionerState build() {
    // Schedule fetch after initialization to avoid accessing state before it's ready
    Future.microtask(() => _fetchData());
    return const BehaviorPractitionerState();
  }

  /// Fetch all shift notes and extract behavior incidents
  Future<void> _fetchData() async {
    try {
      // Set loading state directly without reading current state
      state = const BehaviorPractitionerState(isLoading: true);

      final apiService = ref.read(mcpApiServiceProvider);

      print('🔍 Behavior Practitioner: Fetching shift notes...');
      
      // Fetch only recent submitted shift notes for faster initial load
      final shiftNotesJson = await apiService.listShiftNotes(
        limit: 50, // Increased to get more incidents
      );

      print('📋 Found ${shiftNotesJson.length} shift notes');

      if (shiftNotesJson.isEmpty) {
        print('⚠️ No shift notes found');
        state = state.copyWith(
          isLoading: false,
          shiftNotes: [],
          behaviorIncidents: [],
        );
        return;
      }

      // Convert to ShiftNote objects and filter submitted
      final shiftNotes = shiftNotesJson
          .map((json) => ShiftNote.fromJson(json))
          .where((note) => note.isSubmitted)
          .toList();

      print('✅ Found ${shiftNotes.length} submitted shift notes');

      // Process more shift notes to get more incidents
      final notesToProcess = shiftNotes.take(20).toList(); // Increased from 10 to 20
      
      print('🔄 Processing ${notesToProcess.length} shift notes...');
      
      // Batch fetch all shift notes with sessions in parallel
      final List<Future<Map<String, dynamic>?>> sessionFutures = notesToProcess
          .map((note) => apiService.getShiftNoteWithSessions(note.id).then(
                (value) => value as Map<String, dynamic>?,
                onError: (e) {
                  print('❌ Error fetching sessions for shift note ${note.id}: $e');
                  return null as Map<String, dynamic>?;
                },
              ))
          .toList();

      final sessionResults = await Future.wait(sessionFutures);
      
      print('📊 Fetched ${sessionResults.where((r) => r != null).length}/${notesToProcess.length} shift notes with sessions');

      // Collect all unique client and user IDs for batch fetching
      final Set<String> clientIds = {};
      final Set<String> userIds = {};
      
      for (final shiftNote in notesToProcess) {
        clientIds.add(shiftNote.clientId);
        userIds.add(shiftNote.userId);
      }

      // Batch fetch all clients and users in parallel with error handling
      final List<Future<dynamic>> clientFutures = clientIds.map((id) async {
        try {
          return await apiService.getClient(id);
        } catch (e) {
          return null;
        }
      }).toList();
      
      final List<Future<dynamic>> userFutures = userIds.map((id) async {
        try {
          return await apiService.getUserById(id);
        } catch (e) {
          return null;
        }
      }).toList();

      final clientResults = await Future.wait(clientFutures);
      final userResults = await Future.wait(userFutures);

      // Create lookup maps
      final Map<String, String> clientNames = {};
      final Map<String, String> workerNames = {};
      
      for (int i = 0; i < clientIds.length && i < clientResults.length; i++) {
        final client = clientResults[i];
        if (client != null) {
          try {
            clientNames[clientIds.elementAt(i)] = (client as dynamic).name as String;
          } catch (e) {
            // Skip if name extraction fails
          }
        }
      }
      
      for (int i = 0; i < userIds.length && i < userResults.length; i++) {
        final user = userResults[i];
        if (user != null) {
          try {
            workerNames[userIds.elementAt(i)] = (user as dynamic).name as String;
          } catch (e) {
            // Skip if name extraction fails
          }
        }
      }

      // Extract behavior incidents
      List<BehaviorIncidentWithContext> allIncidents = [];
      int totalSessions = 0;
      int sessionsWithIncidents = 0;
      
      for (int i = 0; i < notesToProcess.length; i++) {
        final shiftNote = notesToProcess[i];
        final noteWithSessions = sessionResults[i];
        
        if (noteWithSessions == null) {
          print('⚠️ Shift note ${shiftNote.id} returned null sessions');
          continue;
        }
        
        final sessionsList = noteWithSessions['activity_sessions'];
        if (sessionsList is List) {
          totalSessions += sessionsList.length;
          
          for (final sessionJson in sessionsList) {
            try {
              if (sessionJson is! Map<String, dynamic>) continue;
              
              // Check if session has behavior incidents before parsing
              final behaviorIncidentsList = sessionJson['behavior_incidents'];
              if (behaviorIncidentsList == null || 
                  (behaviorIncidentsList is List && behaviorIncidentsList.isEmpty)) {
                continue; // Skip sessions without incidents
              }
              
              print('   🔍 Parsing session ${sessionJson['id']} with ${(behaviorIncidentsList as List).length} incident(s)...');
              
              final session = ActivitySession.fromJson(sessionJson);
              
              // Extract behavior incidents from this session
              if (session.behaviorIncidents.isNotEmpty) {
                sessionsWithIncidents++;
                print('   ✅ Session ${session.id} has ${session.behaviorIncidents.length} incident(s)');
                
                for (final incident in session.behaviorIncidents) {
                  print('      📝 Incident: ${incident.id}, convexId: ${incident.convexId ?? "null"}');
                  allIncidents.add(BehaviorIncidentWithContext(
                    incident: incident,
                    shiftNote: shiftNote,
                    session: session,
                    clientName: clientNames[shiftNote.clientId],
                    workerName: workerNames[shiftNote.userId],
                  ));
                }
              } else {
                print('   ⚠️ Session ${session.id} parsed but has no incidents');
              }
            } catch (e, stackTrace) {
              print('❌ Error parsing session: $e');
              print('   Stack trace: $stackTrace');
              
              // Try to parse incidents manually if session parsing fails
              try {
                final behaviorIncidentsList = (sessionJson as Map<String, dynamic>)['behavior_incidents'];
                if (behaviorIncidentsList is List && behaviorIncidentsList.isNotEmpty) {
                  print('   🔧 Attempting to parse incidents manually...');
                  for (final incidentJson in behaviorIncidentsList) {
                    if (incidentJson is Map<String, dynamic>) {
                      try {
                        // Create a safe incident with defaults for null values
                        final safeIncidentJson = Map<String, dynamic>.from(incidentJson);
                        safeIncidentJson['self_harm'] ??= false;
                        safeIncidentJson['self_harm_types'] ??= [];
                        safeIncidentJson['self_harm_count'] ??= 0;
                        safeIncidentJson['second_support_needed'] ??= [];
                        
                        final incident = BehaviorIncident.fromJson(safeIncidentJson);
                        print('      ✅ Manually parsed incident: ${incident.id}');
                        
                        // Create a minimal session for context
                        final minimalSession = ActivitySession(
                          id: sessionJson['id'] as String? ?? 'unknown',
                          activityId: sessionJson['activity_id'] as String? ?? '',
                          clientId: shiftNote.clientId,
                          stakeholderId: shiftNote.userId,
                          sessionStartTime: DateTime.now(),
                          sessionEndTime: DateTime.now(),
                          durationMinutes: 0,
                          location: '',
                          sessionNotes: '',
                          participantEngagement: ParticipantEngagement.moderate,
                          goalProgress: const [],
                          behaviorIncidents: [incident],
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        
                        allIncidents.add(BehaviorIncidentWithContext(
                          incident: incident,
                          shiftNote: shiftNote,
                          session: minimalSession,
                          clientName: clientNames[shiftNote.clientId],
                          workerName: workerNames[shiftNote.userId],
                        ));
                      } catch (incidentError) {
                        print('      ❌ Failed to parse individual incident: $incidentError');
                        print('      📋 Incident JSON: $incidentJson');
                      }
                    }
                  }
                }
              } catch (manualError) {
                print('   ❌ Manual parsing also failed: $manualError');
              }
              
              // Continue with other sessions
              continue;
            }
          }
        } else {
          print('⚠️ Shift note ${shiftNote.id} has no activity_sessions or invalid format');
        }
      }
      
      print('📊 Summary:');
      print('   - Total sessions processed: $totalSessions');
      print('   - Sessions with incidents: $sessionsWithIncidents');
      print('   - Total incidents found: ${allIncidents.length}');

      // Sort incidents by date (most recent first)
      allIncidents.sort((a, b) {
        final dateA = DateTime.parse(a.shiftNote.shiftDate);
        final dateB = DateTime.parse(b.shiftNote.shiftDate);
        return dateB.compareTo(dateA);
      });

      // Calculate stats
      final totalCount = allIncidents.length;
      final highSeverityCount = allIncidents
          .where((item) => item.incident.severity == BehaviorSeverity.high)
          .length;
      
      // Count incidents from last 7 days
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentCount = allIncidents.where((item) {
        final incidentDate = DateTime.parse(item.shiftNote.shiftDate);
        return incidentDate.isAfter(sevenDaysAgo);
      }).length;

      state = state.copyWith(
        isLoading: false,
        error: null,
        shiftNotes: shiftNotes,
        behaviorIncidents: allIncidents,
        totalIncidentsCount: totalCount,
        highSeverityCount: highSeverityCount,
        recentIncidentsCount: recentCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await _fetchData();
  }
}

/// Provider for unacknowledged behavior incidents (incidents without reviews)
/// For behavior practitioners - shows new incidents that need review
final unacknowledgedIncidentsProvider = FutureProvider.autoDispose<List<BehaviorIncidentWithContext>>((ref) async {
  try {
    final practitionerState = ref.watch(behaviorPractitionerProvider);
    final reviewsService = ref.watch(behaviorIncidentReviewsServiceProvider);
    
    // Get all incidents from practitioner state
    final allIncidents = practitionerState.behaviorIncidents;
    
    if (allIncidents.isEmpty) {
      return [];
    }
    
    // Filter incidents that have convexId (synced to backend) and don't have reviews
    final unacknowledgedIncidents = <BehaviorIncidentWithContext>[];
    
    for (final incidentWithContext in allIncidents) {
      final incident = incidentWithContext.incident;
      
      // Skip if incident doesn't have convexId (not synced yet)
      if (incident.convexId == null || incident.convexId!.isEmpty) {
        continue;
      }
      
      // Check if this incident has any reviews
      try {
        final reviews = await reviewsService.listReviews(
          behaviorIncidentId: incident.convexId!,
          limit: 1, // Just check if any review exists
        );
        
        // If no reviews exist, this incident is unacknowledged
        if (reviews.isEmpty) {
          unacknowledgedIncidents.add(incidentWithContext);
        }
      } catch (e) {
        // If error checking reviews, assume incident is unacknowledged
        debugPrint('⚠️ Error checking reviews for incident ${incident.id}: $e');
        unacknowledgedIncidents.add(incidentWithContext);
      }
    }
    
    // Sort by date (most recent first)
    unacknowledgedIncidents.sort((a, b) {
      final dateA = DateTime.parse(a.shiftNote.shiftDate);
      final dateB = DateTime.parse(b.shiftNote.shiftDate);
      return dateB.compareTo(dateA);
    });
    
    return unacknowledgedIncidents;
  } catch (e) {
    debugPrint('❌ Error fetching unacknowledged incidents: $e');
    return [];
  }
});

/// Provider for unacknowledged incidents count (notification badge)
final unacknowledgedIncidentsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final unacknowledgedIncidents = await ref.watch(unacknowledgedIncidentsProvider.future);
  return unacknowledgedIncidents.length;
});

