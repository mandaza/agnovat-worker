import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/convex_client_service.dart';
import '../services/claude_api_service.dart';
import '../services/secure_storage_service.dart';
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

/// Claude API Service Provider
/// Provides access to Claude AI for shift note formatting
///
/// To use:
/// 1. Get your API key from https://console.anthropic.com
/// 2. Set the CLAUDE_API_KEY environment variable
/// 3. Or update the apiKey parameter below (not recommended for production)
final claudeApiServiceProvider = Provider<ClaudeApiService>((ref) {
  // TODO: Load from environment variable or secure storage
  // For now, using a placeholder - replace with your actual API key
  const apiKey = String.fromEnvironment(
    'CLAUDE_API_KEY',
    defaultValue: 'YOUR_CLAUDE_API_KEY',
  );

  return ClaudeApiService(apiKey: apiKey);
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
