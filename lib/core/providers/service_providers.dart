import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/convex_client_service.dart';
import '../../data/services/mcp_api_service.dart';
import '../../data/repositories/dashboard_repository.dart';

/// Convex Client Service Provider
/// Singleton instance of the Convex client
final convexClientProvider = Provider<ConvexClientService>((ref) {
  return ConvexClientService();
});

/// MCP API Service Provider
/// Provides access to Convex backend functions
final mcpApiServiceProvider = Provider<McpApiService>((ref) {
  final convexClient = ref.watch(convexClientProvider);
  return McpApiService(convexClient);
});

/// Dashboard Repository Provider
/// Provides access to dashboard data
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiService = ref.watch(mcpApiServiceProvider);
  return DashboardRepository(apiService);
});
