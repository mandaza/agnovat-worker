import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/shift_note.dart';

/// Shift Note filter options
enum BehaviorPractitionerShiftNoteFilter {
  all,
  draft,
  submitted,
}

/// Behavior Practitioner Shift Notes state model
class BehaviorPractitionerShiftNotesState {
  final bool isLoading;
  final String? error;
  final List<ShiftNote> shiftNotes;
  final List<ShiftNote> filteredShiftNotes;
  final BehaviorPractitionerShiftNoteFilter statusFilter;
  final String searchQuery;

  const BehaviorPractitionerShiftNotesState({
    this.isLoading = true,
    this.error,
    this.shiftNotes = const [],
    this.filteredShiftNotes = const [],
    this.statusFilter = BehaviorPractitionerShiftNoteFilter.all,
    this.searchQuery = '',
  });

  BehaviorPractitionerShiftNotesState copyWith({
    bool? isLoading,
    String? error,
    List<ShiftNote>? shiftNotes,
    List<ShiftNote>? filteredShiftNotes,
    BehaviorPractitionerShiftNoteFilter? statusFilter,
    String? searchQuery,
  }) {
    return BehaviorPractitionerShiftNotesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      shiftNotes: shiftNotes ?? this.shiftNotes,
      filteredShiftNotes: filteredShiftNotes ?? this.filteredShiftNotes,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Get shift notes grouped by recency
  Map<String, List<ShiftNote>> get groupedShiftNotes {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(Duration(days: now.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    final Map<String, List<ShiftNote>> grouped = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'This Month': [],
      'Older': [],
    };

    for (final note in filteredShiftNotes) {
      final noteDate = DateTime.parse(note.shiftDate);
      final noteDay = DateTime(noteDate.year, noteDate.month, noteDate.day);

      if (noteDay == today) {
        grouped['Today']!.add(note);
      } else if (noteDay == yesterday) {
        grouped['Yesterday']!.add(note);
      } else if (noteDay.isAfter(thisWeek.subtract(const Duration(days: 1)))) {
        grouped['This Week']!.add(note);
      } else if (noteDay.isAfter(thisMonth.subtract(const Duration(days: 1)))) {
        grouped['This Month']!.add(note);
      } else {
        grouped['Older']!.add(note);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }
}

/// Behavior Practitioner Shift Notes Provider
final behaviorPractitionerShiftNotesProvider =
    AutoDisposeNotifierProvider<BehaviorPractitionerShiftNotesNotifier, BehaviorPractitionerShiftNotesState>(
  BehaviorPractitionerShiftNotesNotifier.new,
);

/// Behavior Practitioner Shift Notes Notifier
class BehaviorPractitionerShiftNotesNotifier extends AutoDisposeNotifier<BehaviorPractitionerShiftNotesState> {
  Timer? _refreshTimer;

  @override
  BehaviorPractitionerShiftNotesState build() {
    // Set up auto-refresh (every 60 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchShiftNotes();
    });

    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    // Initial data fetch
    Future.microtask(() => _fetchShiftNotes());

    return const BehaviorPractitionerShiftNotesState();
  }

  /// Fetch shift notes from API (all shift notes, not filtered by user)
  Future<void> _fetchShiftNotes() async {
    try {
      final apiService = ref.read(mcpApiServiceProvider);

      // Set loading state
      state = const BehaviorPractitionerShiftNotesState(isLoading: true);

      // Fetch ALL shift notes (behavior practitioners see all submitted notes)
      // Don't pass stakeholderId to get all notes
      final shiftNotesJson = await apiService.listShiftNotes(
        limit: 200, // Increased to get more notes
      );

      // Handle null or empty results
      if (shiftNotesJson.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          shiftNotes: [],
          filteredShiftNotes: [],
        );
        return;
      }

      // Convert JSON to ShiftNote objects and FILTER OUT DRAFTS
      // Behavior practitioners should NEVER see drafts - only submitted notes
      final shiftNotes = shiftNotesJson
          .map((json) => ShiftNote.fromJson(json))
          .where((note) => note.isSubmitted) // Only show submitted notes, never drafts
          .toList();

      // Apply filters
      final filtered = _applyFiltersAndSearch(
        shiftNotes,
        state.statusFilter,
        state.searchQuery,
      );

      state = state.copyWith(
        isLoading: false,
        error: null,
        shiftNotes: shiftNotes,
        filteredShiftNotes: filtered,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Apply filters and search
  List<ShiftNote> _applyFiltersAndSearch(
    List<ShiftNote> notes,
    BehaviorPractitionerShiftNoteFilter statusFilter,
    String searchQuery,
  ) {
    // All notes here are already filtered to be submitted only
    // Behavior practitioners should NEVER see drafts
    var filtered = notes.where((note) => note.isSubmitted).toList();

    // Apply status filter (but drafts filter should never match since we filtered them out)
    if (statusFilter != BehaviorPractitionerShiftNoteFilter.all) {
      filtered = filtered.where((note) {
        switch (statusFilter) {
          case BehaviorPractitionerShiftNoteFilter.draft:
            // This should never match - behavior practitioners don't see drafts
            return false;
          case BehaviorPractitionerShiftNoteFilter.submitted:
            return note.isSubmitted;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((note) {
        return note.rawNotes.toLowerCase().contains(query) ||
            note.shiftDate.contains(query);
      }).toList();
    }

    // Sort by date (most recent first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  /// Update status filter
  void setStatusFilter(BehaviorPractitionerShiftNoteFilter filter) {
    state = state.copyWith(
      statusFilter: filter,
      filteredShiftNotes: _applyFiltersAndSearch(
        state.shiftNotes,
        filter,
        state.searchQuery,
      ),
    );
  }

  /// Update search query
  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredShiftNotes: _applyFiltersAndSearch(
        state.shiftNotes,
        state.statusFilter,
        query,
      ),
    );
  }

  /// Refresh shift notes
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _fetchShiftNotes();
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      statusFilter: BehaviorPractitionerShiftNoteFilter.all,
      searchQuery: '',
      filteredShiftNotes: _applyFiltersAndSearch(
        state.shiftNotes,
        BehaviorPractitionerShiftNoteFilter.all,
        '',
      ),
    );
  }
}

