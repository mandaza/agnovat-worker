import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/shift_note.dart';
import '../providers/auth_provider.dart';

/// Shift Note filter options
enum ShiftNoteFilter {
  all,
  draft,
  submitted,
}

/// Shift Notes state model
class ShiftNotesState {
  final bool isLoading;
  final String? error;
  final List<ShiftNote> shiftNotes;
  final List<ShiftNote> filteredShiftNotes;
  final ShiftNoteFilter statusFilter;
  final String searchQuery;

  const ShiftNotesState({
    this.isLoading = true,
    this.error,
    this.shiftNotes = const [],
    this.filteredShiftNotes = const [],
    this.statusFilter = ShiftNoteFilter.all,
    this.searchQuery = '',
  });

  ShiftNotesState copyWith({
    bool? isLoading,
    String? error,
    List<ShiftNote>? shiftNotes,
    List<ShiftNote>? filteredShiftNotes,
    ShiftNoteFilter? statusFilter,
    String? searchQuery,
  }) {
    return ShiftNotesState(
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
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<ShiftNote>> grouped = {
      'RECENT NOTES': [],
      'THIS WEEK': [],
      'OLDER': [],
    };

    for (final note in filteredShiftNotes) {
      final noteDate = note.createdAt;
      final noteDay = DateTime(noteDate.year, noteDate.month, noteDate.day);

      if (noteDay.isAfter(weekAgo.subtract(const Duration(days: 1)))) {
        grouped['RECENT NOTES']!.add(note);
      } else {
        grouped['OLDER']!.add(note);
      }
    }

    // Remove empty sections
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  /// Check if there are any draft notes
  bool get hasDraftNotes {
    return filteredShiftNotes.any((note) => note.isDraft);
  }

  /// Get count of draft notes
  int get draftNotesCount {
    return shiftNotes.where((note) => note.isDraft).length;
  }

  /// Get count of submitted notes
  int get submittedNotesCount {
    return shiftNotes.where((note) => note.isSubmitted).length;
  }
}

/// Shift Notes state notifier
class ShiftNotesNotifier extends AutoDisposeNotifier<ShiftNotesState> {
  Timer? _refreshTimer;

  @override
  ShiftNotesState build() {
    // Set up auto-refresh (every 60 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchShiftNotes();
    });

    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    // Initial data fetch
    _fetchShiftNotes();

    return const ShiftNotesState();
  }

  /// Fetch shift notes from API
  Future<void> _fetchShiftNotes() async {
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      
      // Get current user ID from auth provider to filter shift notes
      final authState = ref.read(authProvider);
      final currentUserId = authState.user?.id;
      
      if (currentUserId == null) {
        // No user logged in, return empty list
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
          shiftNotes: [],
          filteredShiftNotes: [],
        );
        return;
      }

      // Fetch shift notes as JSON, filtered by current user's ID
      final shiftNotesJson = await apiService.listShiftNotes(
        limit: 50,
        stakeholderId: currentUserId, // Filter by current user
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

      // Convert JSON to ShiftNote objects
      final shiftNotes = shiftNotesJson
          .map((json) => ShiftNote.fromJson(json))
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
    ShiftNoteFilter statusFilter,
    String searchQuery,
  ) {
    var filtered = notes;

    // Apply status filter
    if (statusFilter != ShiftNoteFilter.all) {
      filtered = filtered.where((note) {
        switch (statusFilter) {
          case ShiftNoteFilter.draft:
            return note.isDraft;
          case ShiftNoteFilter.submitted:
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
  void setStatusFilter(ShiftNoteFilter filter) {
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
      statusFilter: ShiftNoteFilter.all,
      searchQuery: '',
      filteredShiftNotes: state.shiftNotes,
    );
  }

  /// Delete a shift note
  Future<void> deleteShiftNote(String shiftNoteId) async {
    try {
      // Delete from API
      final apiService = ref.read(mcpApiServiceProvider);
      await apiService.deleteShiftNote(shiftNoteId);

      // Remove from local state
      final updatedNotes = state.shiftNotes
          .where((note) => note.id != shiftNoteId)
          .toList();

      final filtered = _applyFiltersAndSearch(
        updatedNotes,
        state.statusFilter,
        state.searchQuery,
      );

      state = state.copyWith(
        shiftNotes: updatedNotes,
        filteredShiftNotes: filtered,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow; // Rethrow so UI can handle the error
    }
  }

  /// Submit a shift note (transition from draft to submitted)
  Future<ShiftNote> submitShiftNote(String shiftNoteId) async {
    try {
      // Submit via API
      final apiService = ref.read(mcpApiServiceProvider);
      final result = await apiService.submitShiftNote(shiftNoteId);

      // Parse the updated shift note
      final updatedShiftNote = ShiftNote.fromJson(result);

      // Update local state
      final updatedNotes = state.shiftNotes.map((note) {
        return note.id == shiftNoteId ? updatedShiftNote : note;
      }).toList();

      final filtered = _applyFiltersAndSearch(
        updatedNotes,
        state.statusFilter,
        state.searchQuery,
      );

      state = state.copyWith(
        shiftNotes: updatedNotes,
        filteredShiftNotes: filtered,
      );

      return updatedShiftNote;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow; // Rethrow so UI can handle the error
    }
  }
}

/// Shift Notes provider
final shiftNotesProvider =
    AutoDisposeNotifierProvider<ShiftNotesNotifier, ShiftNotesState>(
  ShiftNotesNotifier.new,
);

/// Extension for filter display names
extension ShiftNoteFilterExtension on ShiftNoteFilter {
  String get displayName {
    switch (this) {
      case ShiftNoteFilter.all:
        return 'All Notes';
      case ShiftNoteFilter.draft:
        return 'Drafts';
      case ShiftNoteFilter.submitted:
        return 'Submitted';
    }
  }
}

