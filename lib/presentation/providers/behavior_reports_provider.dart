import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/behavior_report.dart';
import '../../data/models/user.dart';
import '../../data/services/providers.dart';
import '../providers/auth_provider.dart';

/// Behavior Report Filter
enum BehaviorReportFilter {
  all,
  draft,
  submitted;
}

/// Behavior reports state model
class BehaviorReportsState {
  final bool isLoading;
  final String? error;
  final List<BehaviorReport> reports;
  final String searchQuery;
  final BehaviorSeverity? severityFilter;
  final BehaviorType? typeFilter;
  final BehaviorReportFilter statusFilter;

  const BehaviorReportsState({
    this.isLoading = true,
    this.error,
    this.reports = const [],
    this.searchQuery = '',
    this.severityFilter,
    this.typeFilter,
    this.statusFilter = BehaviorReportFilter.all,
  });

  BehaviorReportsState copyWith({
    bool? isLoading,
    String? error,
    List<BehaviorReport>? reports,
    String? searchQuery,
    BehaviorSeverity? severityFilter,
    BehaviorType? typeFilter,
    BehaviorReportFilter? statusFilter,
    bool clearSeverityFilter = false,
    bool clearTypeFilter = false,
  }) {
    return BehaviorReportsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      reports: reports ?? this.reports,
      searchQuery: searchQuery ?? this.searchQuery,
      severityFilter: clearSeverityFilter ? null : (severityFilter ?? this.severityFilter),
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  /// Get filtered reports based on search query and filters
  List<BehaviorReport> get filteredReports {
    var filtered = reports;

    // Apply status filter
    switch (statusFilter) {
      case BehaviorReportFilter.draft:
        filtered = filtered.where((report) => report.isDraft).toList();
        break;
      case BehaviorReportFilter.submitted:
        filtered = filtered.where((report) => report.isSubmitted).toList();
        break;
      case BehaviorReportFilter.all:
        // Show all
        break;
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((report) {
        return report.clientName.toLowerCase().contains(query) ||
            report.behaviorType.displayName.toLowerCase().contains(query) ||
            report.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply severity filter
    if (severityFilter != null) {
      filtered = filtered.where((report) => report.severity == severityFilter).toList();
    }

    // Apply type filter
    if (typeFilter != null) {
      filtered = filtered.where((report) => report.behaviorType == typeFilter).toList();
    }

    return filtered;
  }

  /// Get count of draft reports
  int get draftReportsCount => reports.where((r) => r.isDraft).length;

  /// Get count of submitted reports
  int get submittedReportsCount => reports.where((r) => r.isSubmitted).length;
}

/// Behavior reports notifier
class BehaviorReportsNotifier extends AutoDisposeNotifier<BehaviorReportsState> {
  Timer? _refreshTimer;

  @override
  BehaviorReportsState build() {
    // Set up auto-refresh (every 60 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchReports();
    });

    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    // Initial data fetch
    _fetchReports();

    return const BehaviorReportsState();
  }

  /// Fetch behavior reports from Convex
  Future<void> _fetchReports({bool fetchAll = false}) async {
    try {
      // Get service
      final service = ref.read(behaviorReportsServiceProvider);

      // Get current user's ID and role for filtering
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      final userRole = authState.user?.role;

      // Determine if user should see all reports (admins) or just their own
      final isAdmin = userRole == UserRole.superAdmin ||
                      userRole == UserRole.manager;

      // Fetch reports from Convex
      final reports = await service.listReports(
        submittedBy: (fetchAll || isAdmin) ? null : userId, // Admins see all reports
        limit: 100,
      );

      state = state.copyWith(
        isLoading: false,
        error: null,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Manually refresh reports
  Future<void> refresh({bool fetchAll = false}) async {
    state = state.copyWith(isLoading: true);
    await _fetchReports(fetchAll: fetchAll);
  }

  /// Fetch all reports (for admins)
  Future<void> fetchAllReports() async {
    state = state.copyWith(isLoading: true);
    await _fetchReports(fetchAll: true);
  }

  /// Add a new behavior report to Convex
  Future<void> addReport(BehaviorReport report) async {
    try {
      final service = ref.read(behaviorReportsServiceProvider);

      print('📝 Creating behavior report...');
      
      // Create report on Convex
      final createdReport = await service.createReport(report);

      print('✅ Behavior report created successfully with ID: ${createdReport.id}');

      // Refresh the list to get the full data from backend
      await refresh();
    } catch (e) {
      print('❌ Error in addReport: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Update an existing behavior report
  Future<void> updateReport(String reportId, Map<String, dynamic> updates) async {
    try {
      final service = ref.read(behaviorReportsServiceProvider);

      final updatedReport = await service.updateReport(
        reportId: reportId,
        updates: updates,
      );

      // Update in local state
      final updatedList = state.reports.map((r) {
        return r.id == reportId ? updatedReport : r;
      }).toList();

      state = state.copyWith(reports: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Delete a behavior report
  Future<void> deleteReport(String reportId) async {
    try {
      final service = ref.read(behaviorReportsServiceProvider);

      await service.deleteReport(reportId);

      // Remove from local state
      final updatedList = state.reports.where((r) => r.id != reportId).toList();
      state = state.copyWith(reports: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Update severity filter
  void updateSeverityFilter(BehaviorSeverity? severity) {
    state = state.copyWith(
      severityFilter: severity,
      clearSeverityFilter: severity == null,
    );
  }

  /// Update type filter
  void updateTypeFilter(BehaviorType? type) {
    state = state.copyWith(
      typeFilter: type,
      clearTypeFilter: type == null,
    );
  }

  /// Update status filter
  void setStatusFilter(BehaviorReportFilter filter) {
    state = state.copyWith(statusFilter: filter);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: BehaviorReportFilter.all,
      clearSeverityFilter: true,
      clearTypeFilter: true,
    );
  }
}

/// Main behavior reports provider
final behaviorReportsProvider = AutoDisposeNotifierProvider<BehaviorReportsNotifier, BehaviorReportsState>(
  BehaviorReportsNotifier.new,
);

