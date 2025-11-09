import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/activity.dart';

/// Activities filter options
enum ActivityStatusFilter {
  all,
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
}

enum ActivityTimeFilter {
  all,
  today,
  thisWeek,
  thisMonth,
  past,
}

/// Activities state model
class ActivitiesState {
  final bool isLoading;
  final String? error;
  final List<Activity> activities;
  final List<Activity> filteredActivities;
  final ActivityStatusFilter statusFilter;
  final ActivityTimeFilter timeFilter;
  final String searchQuery;

  const ActivitiesState({
    this.isLoading = true,
    this.error,
    this.activities = const [],
    this.filteredActivities = const [],
    this.statusFilter = ActivityStatusFilter.all,
    this.timeFilter = ActivityTimeFilter.all,
    this.searchQuery = '',
  });

  ActivitiesState copyWith({
    bool? isLoading,
    String? error,
    List<Activity>? activities,
    List<Activity>? filteredActivities,
    ActivityStatusFilter? statusFilter,
    ActivityTimeFilter? timeFilter,
    String? searchQuery,
  }) {
    return ActivitiesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activities: activities ?? this.activities,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      statusFilter: statusFilter ?? this.statusFilter,
      timeFilter: timeFilter ?? this.timeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Get activities grouped by time
  Map<String, List<Activity>> get groupedActivities {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    print('📅 Grouping ${filteredActivities.length} activities (today: $today)');

    final Map<String, List<Activity>> grouped = {
      'TODAY': [],
      'THIS WEEK': [],
      'COMPLETED': [],
      'OTHER': [], // Catch-all for activities that don't fit above
    };

    for (final activity in filteredActivities) {
      final activityDate = activity.createdAt;
      final activityDay = DateTime(
        activityDate.year,
        activityDate.month,
        activityDate.day,
      );

      print('  Activity: ${activity.title} | Date: $activityDay | Status: ${activity.status}');

      if (activity.status == ActivityStatus.completed) {
        grouped['COMPLETED']!.add(activity);
        print('    → COMPLETED');
      } else if (activityDay == today) {
        grouped['TODAY']!.add(activity);
        print('    → TODAY');
      } else if (activityDay.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          activityDay.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        grouped['THIS WEEK']!.add(activity);
        print('    → THIS WEEK');
      } else {
        // All other activities (past or future)
        grouped['OTHER']!.add(activity);
        print('    → OTHER');
      }
    }

    // Remove empty sections
    grouped.removeWhere((key, value) => value.isEmpty);

    print('📊 Final groups: ${grouped.keys.join(", ")}');
    grouped.forEach((key, value) {
      print('  $key: ${value.length} activities');
    });

    return grouped;
  }
}

/// Activities state notifier with filtering and search
class ActivitiesNotifier extends AutoDisposeNotifier<ActivitiesState> {
  Timer? _refreshTimer;

  @override
  ActivitiesState build() {
    // Set up auto-refresh (every 60 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchActivities();
    });

    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    // Initial data fetch
    _fetchActivities();

    return const ActivitiesState();
  }

  /// Fetch activities from API
  Future<void> _fetchActivities() async {
    try {
      print('🔄 ActivitiesProvider: Fetching activities from Convex...');

      final apiService = ref.read(mcpApiServiceProvider);

      // Fetch all activities (you can add clientId filter if needed)
      final activities = await apiService.listActivities(
        limit: 100,
        // Add clientId if filtering by specific client
      );

      print('✅ ActivitiesProvider: Fetched ${activities.length} activities');

      // Apply filters and search
      final filtered = _applyFiltersAndSearch(
        activities,
        state.statusFilter,
        state.timeFilter,
        state.searchQuery,
      );

      print('📊 ActivitiesProvider: After filters: ${filtered.length} activities');

      state = state.copyWith(
        isLoading: false,
        error: null,
        activities: activities,
        filteredActivities: filtered,
      );
    } catch (e) {
      print('❌ ActivitiesProvider: Error fetching activities: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Apply filters and search to activities list
  List<Activity> _applyFiltersAndSearch(
    List<Activity> activities,
    ActivityStatusFilter statusFilter,
    ActivityTimeFilter timeFilter,
    String searchQuery,
  ) {
    var filtered = activities;

    // Apply status filter
    if (statusFilter != ActivityStatusFilter.all) {
      filtered = filtered.where((activity) {
        switch (statusFilter) {
          case ActivityStatusFilter.scheduled:
            return activity.status == ActivityStatus.scheduled;
          case ActivityStatusFilter.inProgress:
            return activity.status == ActivityStatus.inProgress;
          case ActivityStatusFilter.completed:
            return activity.status == ActivityStatus.completed;
          case ActivityStatusFilter.cancelled:
            return activity.status == ActivityStatus.cancelled;
          case ActivityStatusFilter.noShow:
            return activity.status == ActivityStatus.noShow;
          default:
            return true;
        }
      }).toList();
    }

    // Apply time filter
    if (timeFilter != ActivityTimeFilter.all) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      filtered = filtered.where((activity) {
        final activityDate = activity.createdAt;
        final activityDay = DateTime(
          activityDate.year,
          activityDate.month,
          activityDate.day,
        );

        switch (timeFilter) {
          case ActivityTimeFilter.today:
            return activityDay == today;
          case ActivityTimeFilter.thisWeek:
            final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
            final endOfWeek = startOfWeek.add(const Duration(days: 6));
            return activityDay.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                activityDay.isBefore(endOfWeek.add(const Duration(days: 1)));
          case ActivityTimeFilter.thisMonth:
            return activityDate.year == now.year && activityDate.month == now.month;
          case ActivityTimeFilter.past:
            return activityDay.isBefore(today);
          default:
            return true;
        }
      }).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((activity) {
        return activity.title.toLowerCase().contains(query) ||
            (activity.description?.toLowerCase().contains(query) ?? false) ||
            activity.activityType.displayName.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by date (most recent first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  /// Update status filter
  void setStatusFilter(ActivityStatusFilter filter) {
    state = state.copyWith(
      statusFilter: filter,
      filteredActivities: _applyFiltersAndSearch(
        state.activities,
        filter,
        state.timeFilter,
        state.searchQuery,
      ),
    );
  }

  /// Update time filter
  void setTimeFilter(ActivityTimeFilter filter) {
    state = state.copyWith(
      timeFilter: filter,
      filteredActivities: _applyFiltersAndSearch(
        state.activities,
        state.statusFilter,
        filter,
        state.searchQuery,
      ),
    );
  }

  /// Update search query
  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredActivities: _applyFiltersAndSearch(
        state.activities,
        state.statusFilter,
        state.timeFilter,
        query,
      ),
    );
  }

  /// Refresh activities
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _fetchActivities();
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      statusFilter: ActivityStatusFilter.all,
      timeFilter: ActivityTimeFilter.all,
      searchQuery: '',
      filteredActivities: state.activities,
    );
  }
}

/// Activities provider
final activitiesProvider =
    AutoDisposeNotifierProvider<ActivitiesNotifier, ActivitiesState>(
  ActivitiesNotifier.new,
);

/// Extension for filter display names
extension ActivityStatusFilterExtension on ActivityStatusFilter {
  String get displayName {
    switch (this) {
      case ActivityStatusFilter.all:
        return 'All Status';
      case ActivityStatusFilter.scheduled:
        return 'Scheduled';
      case ActivityStatusFilter.inProgress:
        return 'In Progress';
      case ActivityStatusFilter.completed:
        return 'Completed';
      case ActivityStatusFilter.cancelled:
        return 'Cancelled';
      case ActivityStatusFilter.noShow:
        return 'No Show';
    }
  }
}

extension ActivityTimeFilterExtension on ActivityTimeFilter {
  String get displayName {
    switch (this) {
      case ActivityTimeFilter.all:
        return 'All Time';
      case ActivityTimeFilter.today:
        return 'Today';
      case ActivityTimeFilter.thisWeek:
        return 'This Week';
      case ActivityTimeFilter.thisMonth:
        return 'This Month';
      case ActivityTimeFilter.past:
        return 'Past';
    }
  }
}

