import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/activity_session.dart';
import '../../data/models/shift_note.dart';
import '../../data/models/goal.dart';
import '../../data/models/client.dart';

/// Matrix statistics for the shift note
class ShiftNoteStats {
  final int totalActivities;
  final int totalGoals;
  final int totalBehaviors;
  final int totalMedia;

  const ShiftNoteStats({
    required this.totalActivities,
    required this.totalGoals,
    required this.totalBehaviors,
    required this.totalMedia,
  });
}

/// Complete shift note data with activity sessions and goals
class ShiftNoteDetail {
  final ShiftNote shiftNote;
  final List<ActivitySession> activitySessions;
  final Map<String, Goal> goalsMap; // goal_id -> Goal
  final Client? client; // Client information
  final ShiftNoteStats stats; // Pre-calculated statistics

  const ShiftNoteDetail({
    required this.shiftNote,
    required this.activitySessions,
    required this.goalsMap,
    this.client,
    required this.stats,
  });
}

/// State for shift note details
class ShiftNoteDetailState {
  final bool isLoading;
  final String? error;
  final ShiftNoteDetail? data;

  const ShiftNoteDetailState({
    this.isLoading = true,
    this.error,
    this.data,
  });

  ShiftNoteDetailState copyWith({
    bool? isLoading,
    String? error,
    ShiftNoteDetail? data,
  }) {
    return ShiftNoteDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}

/// Shift note detail notifier
class ShiftNoteDetailNotifier extends FamilyNotifier<ShiftNoteDetailState, String> {
  @override
  ShiftNoteDetailState build(String shiftNoteId) {
    _fetchShiftNoteWithSessions(shiftNoteId);
    return const ShiftNoteDetailState();
  }

  /// Fetch shift note with all activity sessions
  Future<void> _fetchShiftNoteWithSessions(String shiftNoteId) async {
    try {
      final apiService = ref.read(mcpApiServiceProvider);

      // Fetch shift note with all sessions using the new backend method
      final result = await apiService.getShiftNoteWithSessions(shiftNoteId);

      // Parse shift note
      ShiftNote? shiftNote;
      try {
        shiftNote = ShiftNote.fromJson(result);
      } catch (e) {
        rethrow;
      }

      // Parse activity sessions if present
      final sessionsList = result['activity_sessions'] as List<dynamic>?;
      List<ActivitySession> activitySessions = [];

      if (sessionsList != null) {
        for (int i = 0; i < sessionsList.length; i++) {
          try {
            final sessionJson = sessionsList[i] as Map<String, dynamic>;
            final session = ActivitySession.fromJson(sessionJson);
            activitySessions.add(session);
          } catch (e) {
            // Continue with other sessions instead of failing completely
          }
        }
      }

      // Load client and goals in parallel for better performance
      Client? client;
      List<Goal> goals = [];
      
      try {
        final results = await Future.wait([
          // Fetch client information
          apiService.getClient(shiftNote.clientId),
          // Fetch goals for this client to enrich goal progress entries
          apiService.listGoals(clientId: shiftNote.clientId),
        ]);
        client = results[0] as Client;
        goals = results[1] as List<Goal>;
      } catch (e) {
        // If client fetch fails, try to get it from a fallback or leave as null
        // Goals will be empty if fetch fails
        try {
          client = await apiService.getClient(shiftNote.clientId);
        } catch (_) {
          // Client fetch failed, will use null
        }
      }
      final goalsMap = {for (var goal in goals) goal.id: goal};

      // Calculate statistics upfront
      final stats = _calculateStats(shiftNote, activitySessions);

      final detail = ShiftNoteDetail(
        shiftNote: shiftNote,
        activitySessions: activitySessions,
        goalsMap: goalsMap,
        client: client,
        stats: stats,
      );

      state = state.copyWith(
        isLoading: false,
        error: null,
        data: detail,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Calculate statistics for the shift note
  ShiftNoteStats _calculateStats(ShiftNote shiftNote, List<ActivitySession> sessions) {
    // If we have linked sessions, use them
    if (sessions.isNotEmpty) {
      return ShiftNoteStats(
        totalActivities: sessions.length,
        totalGoals: sessions.fold<int>(0, (sum, s) => sum + s.goalProgress.length),
        totalBehaviors: sessions.fold<int>(0, (sum, s) => sum + s.behaviorIncidents.length),
        totalMedia: sessions.fold<int>(0, (sum, s) => sum + s.media.length),
      );
    }

    // Otherwise, parse from raw notes
    final parsedSessions = _parseActivitySessionsFromRawNotes(shiftNote.rawNotes);
    int totalActivities = parsedSessions.length;
    int totalGoals = 0;
    int totalBehaviors = 0;

    // First check structured data from shift note
    if (shiftNote.goalsProgress != null && shiftNote.goalsProgress!.isNotEmpty) {
      totalGoals = shiftNote.goalsProgress!.length;
    } else {
      // Count goals from parsed sessions
      for (final session in parsedSessions) {
        final goals = session['goals'] as List<String>;
        totalGoals += goals.length;
      }
    }

    // Count behaviors from parsed sessions
    for (final session in parsedSessions) {
      final behaviors = session['behaviors'] as List<String>;
      totalBehaviors += behaviors.length;
    }

    return ShiftNoteStats(
      totalActivities: totalActivities,
      totalGoals: totalGoals,
      totalBehaviors: totalBehaviors,
      totalMedia: 0, // Media not available in parsed notes
    );
  }

  /// Parse activity sessions from raw notes (helper method)
  List<Map<String, dynamic>> _parseActivitySessionsFromRawNotes(String rawNotes) {
    final sessions = <Map<String, dynamic>>[];
    final lines = rawNotes.split('\n');
    
    Map<String, dynamic>? currentSession;
    String currentField = '';
    int? goalCount;
    int? behaviorCount;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // Detect start of a new activity
      if (trimmedLine.toLowerCase().startsWith('activity ')) {
        // Save previous session if exists
        if (currentSession != null) {
          if ((currentSession['goals'] as List<String>).isEmpty && goalCount != null && goalCount > 0) {
            (currentSession['goals'] as List<String>).add('$goalCount goal(s) worked on during this session');
          }
          if ((currentSession['behaviors'] as List<String>).isEmpty && behaviorCount != null && behaviorCount > 0) {
            (currentSession['behaviors'] as List<String>).add('$behaviorCount behavior(s) recorded during this session');
          }
          sessions.add(currentSession);
        }
        // Start new session
        currentSession = {
          'name': trimmedLine.replaceFirst(RegExp(r'Activity \d+:\s*', caseSensitive: false), ''),
          'time': '',
          'location': '',
          'engagement': '',
          'goals': <String>[],
          'behaviors': <String>[],
          'notes': '',
        };
        currentField = '';
        goalCount = null;
        behaviorCount = null;
      } else if (currentSession != null) {
        final lowerLine = trimmedLine.toLowerCase();
        
        if (lowerLine.startsWith('goals worked on:') || lowerLine.startsWith('goals:')) {
          final goalsText = trimmedLine.replaceFirst(RegExp(r'Goals worked on:\s*|Goals:\s*', caseSensitive: false), '');
          currentField = 'goals';
          
          if (RegExp(r'^\d+$').hasMatch(goalsText)) {
            goalCount = int.tryParse(goalsText);
          } else if (goalsText.isNotEmpty) {
            (currentSession['goals'] as List<String>).add(goalsText);
          }
        } else if (lowerLine.startsWith('behaviors recorded:') || 
                   lowerLine.startsWith('behaviours recorded:') ||
                   lowerLine.startsWith('behaviors:') ||
                   lowerLine.startsWith('behaviours:')) {
          final behaviorsText = trimmedLine.replaceFirst(RegExp(r'Behaviors? recorded:\s*|Behaviours? recorded:\s*|Behaviors?:\s*|Behaviours?:\s*', caseSensitive: false), '');
          currentField = 'behaviors';
          
          if (RegExp(r'^\d+$').hasMatch(behaviorsText)) {
            behaviorCount = int.tryParse(behaviorsText);
          } else if (behaviorsText.isNotEmpty) {
            (currentSession['behaviors'] as List<String>).add(behaviorsText);
          }
        } else if (currentField == 'goals') {
          if (trimmedLine.startsWith('-') || trimmedLine.startsWith('•') || 
              trimmedLine.startsWith('*') || (trimmedLine.length > 5 && !RegExp(r'^\d+$').hasMatch(trimmedLine))) {
            final goalText = trimmedLine.replaceFirst(RegExp(r'^[-•*]\s*'), '');
            if (goalText.isNotEmpty) {
              (currentSession['goals'] as List<String>).add(goalText);
            }
          }
        } else if (currentField == 'behaviors') {
          if (trimmedLine.startsWith('-') || trimmedLine.startsWith('•') || 
              trimmedLine.startsWith('*') || (trimmedLine.length > 5 && !RegExp(r'^\d+$').hasMatch(trimmedLine))) {
            final behaviorText = trimmedLine.replaceFirst(RegExp(r'^[-•*]\s*'), '');
            if (behaviorText.isNotEmpty) {
              (currentSession['behaviors'] as List<String>).add(behaviorText);
            }
          }
        }
      }
    }
    
    // Add last session
    if (currentSession != null) {
      if ((currentSession['goals'] as List<String>).isEmpty && goalCount != null && goalCount > 0) {
        (currentSession['goals'] as List<String>).add('$goalCount goal(s) worked on during this session');
      }
      if ((currentSession['behaviors'] as List<String>).isEmpty && behaviorCount != null && behaviorCount > 0) {
        (currentSession['behaviors'] as List<String>).add('$behaviorCount behavior(s) recorded during this session');
      }
      sessions.add(currentSession);
    }
    
    return sessions;
  }

  /// Refresh the data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _fetchShiftNoteWithSessions(arg);
  }
}

/// Shift note detail provider
/// Usage: ref.watch(shiftNoteDetailProvider(shiftNoteId))
final shiftNoteDetailProvider =
    NotifierProvider.family<ShiftNoteDetailNotifier, ShiftNoteDetailState, String>(
  ShiftNoteDetailNotifier.new,
);
