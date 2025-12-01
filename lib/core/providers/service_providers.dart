import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/convex_client_service.dart';
import '../services/secure_storage_service.dart';
import '../../data/services/mcp_api_service.dart';
import '../../data/services/activity_session_service.dart';
import '../../data/services/sync_service.dart';
import '../../data/database/drift_database.dart';
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

/// Secure Storage Service Provider
/// Provides encrypted storage for sensitive user data
/// Uses iOS Keychain and Android EncryptedSharedPreferences
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final service = SecureStorageService();
  service.initialize();
  return service;
});

/// Dashboard Repository Provider
/// Provides access to dashboard data
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiService = ref.watch(mcpApiServiceProvider);
  return DashboardRepository(apiService);
});

/// App Database Provider (Drift)
/// Provides access to local SQLite database for offline storage
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Activity Session Service Provider
/// Provides access to Activity Sessions Convex backend functions
final activitySessionServiceProvider = Provider<ActivitySessionService>((ref) {
  final convexClient = ref.watch(convexClientProvider);
  return ActivitySessionService(convexClient);
});

/// Sync Service Provider
/// Provides offline-first sync functionality for Activity Sessions
final syncServiceProvider = Provider<SyncService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final sessionService = ref.watch(activitySessionServiceProvider);
  return SyncService(database, sessionService);
});
