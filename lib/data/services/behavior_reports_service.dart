import '../models/behavior_report.dart';
import '../../core/services/convex_client_service.dart';

/// Service for behavior reports using Convex directly
/// Calls behaviorIncidents Convex functions
class BehaviorReportsService {
  final ConvexClientService _convexClient;

  BehaviorReportsService(this._convexClient);

  /// List behavior reports with optional filtering
  /// Calls: behaviorIncidents:list
  Future<List<BehaviorReport>> listReports({
    String? clientId,
    String? submittedBy, // user_id from users table
    String? severity,
    String? dateFrom,
    String? dateTo,
    int? limit,
  }) async {
    final args = <String, dynamic>{};
    if (clientId != null) args['client_id'] = clientId;
    if (submittedBy != null) args['submitted_by'] = submittedBy;
    if (severity != null) args['severity'] = severity;
    if (dateFrom != null) args['date_from'] = dateFrom;
    if (dateTo != null) args['date_to'] = dateTo;
    if (limit != null) args['limit'] = limit;

    final result = await _convexClient.query<List<dynamic>>(
      'behaviorIncidents:list',
      args: args,
    );

    return result
        .map((json) => BehaviorReport.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get behavior report by ID (with enriched data)
  /// Calls: behaviorIncidents:getById
  Future<BehaviorReport> getReport(String reportId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      'behaviorIncidents:getById',
      args: {'id': reportId},
    );

    return BehaviorReport.fromJson(result);
  }

  /// Create new behavior report
  /// Calls: behaviorIncidents:create
  Future<BehaviorReport> createReport(BehaviorReport report) async {
    try {
      final result = await _convexClient.mutation<dynamic>(
        'behaviorIncidents:create',
        args: report.toJson(),
      );

      // Handle null response
      if (result == null) {
        throw Exception('Backend returned null response when creating behavior report');
      }

      // If result is a String (likely an ID), fetch the full report
      if (result is String) {
        print('📝 Created behavior report with ID: $result');
        // Return a temporary report with the ID
        // The list will refresh and get the full data
        return report.copyWith(id: result);
      }

      // If result is a Map, parse it
      if (result is Map<String, dynamic>) {
        return BehaviorReport.fromJson(result);
      }

      throw Exception('Unexpected response type from backend: ${result.runtimeType}');
    } catch (e) {
      print('❌ Error creating behavior report: $e');
      rethrow;
    }
  }

  /// Update behavior report
  /// Calls: behaviorIncidents:update
  Future<BehaviorReport> updateReport({
    required String reportId,
    Map<String, dynamic>? updates,
  }) async {
    final args = <String, dynamic>{
      'id': reportId,
      if (updates != null) ...updates,
    };

    final result = await _convexClient.mutation<Map<String, dynamic>>(
      'behaviorIncidents:update',
      args: args,
    );

    return BehaviorReport.fromJson(result);
  }

  /// Delete behavior report
  /// Calls: behaviorIncidents:remove
  Future<void> deleteReport(String reportId) async {
    await _convexClient.mutation(
      'behaviorIncidents:remove',
      args: {'id': reportId},
    );
  }

  /// Get statistics
  /// Calls: behaviorIncidents:getStats
  Future<Map<String, dynamic>> getStats({String? clientId}) async {
    final args = <String, dynamic>{};
    if (clientId != null) args['client_id'] = clientId;

    final result = await _convexClient.query<Map<String, dynamic>>(
      'behaviorIncidents:getStats',
      args: args,
    );

    return result;
  }

  /// Get recent high severity incidents
  /// Calls: behaviorIncidents:getRecentHighSeverity
  Future<List<BehaviorReport>> getRecentHighSeverity({
    int days = 30,
    int limit = 10,
  }) async {
    final result = await _convexClient.query<List<dynamic>>(
      'behaviorIncidents:getRecentHighSeverity',
      args: {'days': days, 'limit': limit},
    );

    return result
        .map((json) => BehaviorReport.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
