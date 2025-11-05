import '../models/client.dart';
import '../models/activity.dart';
import '../services/mcp_api_service.dart';

/// Dashboard repository
/// Manages data fetching and caching for dashboard screen
class DashboardRepository {
  final McpApiService _apiService;

  DashboardRepository(this._apiService);

  /// Get complete dashboard data
  Future<DashboardData> getDashboardData() async {
    try {
      return await _apiService.getDashboard();
    } catch (e) {
      rethrow;
    }
  }

  /// Get assigned clients for support worker
  /// For now, returns all active clients - will be filtered by support worker ID later
  Future<List<Client>> getAssignedClients() async {
    try {
      return await _apiService.listClients(active: true, limit: 10);
    } catch (e) {
      rethrow;
    }
  }

  /// Get today's activities for support worker
  /// For now, returns recent activities - will be filtered by date and support worker ID later
  Future<List<Activity>> getTodaysActivities() async {
    try {
      // TODO: Filter by today's date and support worker ID when authentication is integrated
      return await _apiService.listActivities(
        status: ActivityStatus.scheduled.name,
        limit: 10,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get client summary for assigned client card
  Future<ClientSummary> getClientSummary(String clientId) async {
    try {
      return await _apiService.getClientSummary(clientId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get recent shift notes
  Future<List<Map<String, dynamic>>> getRecentShiftNotes({int limit = 5}) async {
    try {
      return await _apiService.getRecentShiftNotes(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  /// Get pending shift notes count
  /// Shift notes without formatted_note are considered pending
  Future<int> getPendingShiftNotesCount() async {
    try {
      final recentNotes = await _apiService.getRecentShiftNotes(limit: 50);
      // Count notes without formatted_note field
      return recentNotes.where((note) => note['formatted_note'] == null).length;
    } catch (e) {
      rethrow;
    }
  }

  /// Get this week's shift count
  Future<int> getShiftsThisWeekCount() async {
    try {
      // Calculate week start (Monday)
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';

      final notes = await _apiService.listShiftNotes(
        dateFrom: weekStartStr,
        limit: 100,
      );

      return notes.length;
    } catch (e) {
      rethrow;
    }
  }
}
