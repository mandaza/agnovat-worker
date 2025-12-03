import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'behavior_reports_service.dart';
import 'behavior_incident_reviews_service.dart';
import '../../core/services/convex_client_service.dart';

/// Provider for ConvexClientService
final convexClientServiceProvider = Provider<ConvexClientService>((ref) {
  return ConvexClientService();
});

/// Provider for BehaviorReportsService
final behaviorReportsServiceProvider = Provider<BehaviorReportsService>((ref) {
  final convexClient = ref.watch(convexClientServiceProvider);
  return BehaviorReportsService(convexClient);
});

/// Provider for BehaviorIncidentReviewsService
final behaviorIncidentReviewsServiceProvider = Provider<BehaviorIncidentReviewsService>((ref) {
  final convexClient = ref.watch(convexClientServiceProvider);
  return BehaviorIncidentReviewsService(convexClient);
});
