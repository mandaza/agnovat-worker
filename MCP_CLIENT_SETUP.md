# MCP Client Setup Guide

This document explains how to configure and use the MCP (Model Context Protocol) client in the Agnovat Flutter app.

## Architecture Overview

The MCP client follows a clean architecture pattern with three layers:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Providers, UI State Management)       │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Repository Layer                │
│   (Business Logic, Data Coordination)   │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Data Layer                      │
│  (API Services, HTTP Client)            │
└─────────────────────────────────────────┘
```

## File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── api_config.dart          # API configuration (base URL, endpoints)
│   ├── services/
│   │   └── http_client_service.dart # HTTP client with Dio
│   └── providers/
│       └── service_providers.dart   # Riverpod service providers
│
├── data/
│   ├── models/                      # Data models (Client, Activity, etc.)
│   ├── services/
│   │   └── mcp_api_service.dart     # MCP API endpoints wrapper
│   └── repositories/
│       └── dashboard_repository.dart # Dashboard data repository
│
└── presentation/
    └── providers/
        └── dashboard_provider.dart   # Dashboard UI state provider
```

## Configuration

### 1. Set Backend URL

Update the base URL in `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000', // Change this to your production URL
);
```

Or set it at runtime:

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://localhost:3000

# Production
flutter run --dart-define=API_BASE_URL=https://api.agnovat.com
```

### 2. Update API Version (if needed)

```dart
static const String apiVersion = 'v1'; // Change if your API uses different versioning
```

### 3. Configure Timeouts

Adjust timeouts in `api_config.dart`:

```dart
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
static const Duration sendTimeout = Duration(seconds: 30);
```

## Usage Examples

### Accessing Dashboard Data

The dashboard provider automatically fetches data on initialization:

```dart
// In your widget
class WorkerDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    if (dashboardState.isLoading) {
      return CircularProgressIndicator();
    }

    if (dashboardState.error != null) {
      return ErrorWidget(dashboardState.error!);
    }

    // Access data
    final clients = dashboardState.assignedClients;
    final activities = dashboardState.todaysActivities;
    // ...
  }
}
```

### Manual Refresh

```dart
// Trigger manual refresh
ref.read(dashboardProvider.notifier).refresh();
```

### Direct API Calls (Advanced)

If you need to make custom API calls:

```dart
// Get the API service
final apiService = ref.read(mcpApiServiceProvider);

// Call specific endpoints
final clients = await apiService.listClients(active: true, limit: 10);
final activity = await apiService.getActivity('activity-id');
```

### Creating New Services

To add new functionality:

1. **Add endpoint to API config**:
```dart
// lib/core/config/api_config.dart
static const String goalsEndpoint = '/goals';
```

2. **Add method to API service**:
```dart
// lib/data/services/mcp_api_service.dart
Future<List<Goal>> listGoals({String? clientId}) async {
  final response = await _httpClient.get<List<dynamic>>(
    ApiConfig.goalsEndpoint,
    queryParameters: {'client_id': clientId},
  );

  return (response.data as List)
      .map((json) => Goal.fromJson(json))
      .toList();
}
```

3. **Create repository**:
```dart
// lib/data/repositories/goals_repository.dart
class GoalsRepository {
  final McpApiService _apiService;

  GoalsRepository(this._apiService);

  Future<List<Goal>> getClientGoals(String clientId) async {
    return await _apiService.listGoals(clientId: clientId);
  }
}
```

4. **Add provider**:
```dart
// lib/core/providers/service_providers.dart
final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  final apiService = ref.watch(mcpApiServiceProvider);
  return GoalsRepository(apiService);
});
```

## Error Handling

The HTTP client automatically converts API errors to `ApiException`:

```dart
try {
  final clients = await apiService.listClients();
} on ApiException catch (e) {
  if (e.isNetworkError) {
    // Handle network error
    showSnackbar('No internet connection');
  } else if (e.isNotFound) {
    // Handle not found
    showSnackbar('Resource not found');
  } else {
    // Handle other errors
    showSnackbar(e.message);
  }
}
```

### Error Types

- `isValidationError` - Input validation failures (400)
- `isNotFound` - Resource not found (404)
- `isUnauthorized` - Authentication required (401)
- `isConflict` - Business rule violation (409)
- `isAuthorizationError` - Permission denied (MCP specific)
- `isNetworkError` - Network connectivity issues

## MCP Backend Requirements

Your HTTP wrapper should expose these endpoints:

### Dashboard
- `GET /api/v1/dashboard` - Get dashboard data
- `GET /api/v1/dashboard/client/:id/summary` - Get client summary

### Clients
- `GET /api/v1/clients` - List clients
- `GET /api/v1/clients/:id` - Get client by ID
- `GET /api/v1/clients/search?search_term=...` - Search clients

### Activities
- `GET /api/v1/activities` - List activities
- `GET /api/v1/activities/:id` - Get activity by ID
- `POST /api/v1/activities` - Create activity
- `PATCH /api/v1/activities/:id` - Update activity

### Shift Notes
- `GET /api/v1/shift-notes/recent` - Get recent shift notes
- `GET /api/v1/shift-notes` - List shift notes with filters

## Development Mode

The dashboard provider includes a fallback to mock data when the API is unavailable:

```dart
// This happens automatically in DashboardNotifier.loadDashboard()
catch (e) {
  // Falls back to mock data
  _loadMockData();

  state = state.copyWith(
    error: 'Failed to load dashboard: ${e.toString()}',
  );
}
```

**Note**: Remove this fallback in production!

## Testing

### Unit Testing Services

```dart
void main() {
  test('McpApiService.listClients returns clients', () async {
    final mockHttpClient = MockHttpClientService();
    final apiService = McpApiService(mockHttpClient);

    when(mockHttpClient.get<List<dynamic>>(any))
        .thenAnswer((_) async => Response(data: [...]));

    final clients = await apiService.listClients();

    expect(clients, isA<List<Client>>());
  });
}
```

### Widget Testing with Providers

```dart
testWidgets('Dashboard shows clients', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(home: WorkerDashboardScreen()),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('John Smith'), findsOneWidget);
});
```

## Logging

Debug logging is enabled by default in `ApiConfig`:

```dart
static const bool enableLogging = true; // Set to false in production
```

Logs include:
- Request method, path, headers, and data
- Response status and data
- Error messages

## Authentication

When Clerk authentication is integrated, set the token:

```dart
final httpClient = ref.read(httpClientProvider);
httpClient.setAuthToken(clerkToken);
```

Clear token on sign out:

```dart
httpClient.clearAuthToken();
```

## Performance Tips

1. **Use pagination** for large lists:
```dart
final clients = await apiService.listClients(limit: 20, offset: 0);
```

2. **Cache data** in repositories:
```dart
class DashboardRepository {
  List<Client>? _cachedClients;
  DateTime? _lastFetch;

  Future<List<Client>> getClients() async {
    if (_cachedClients != null &&
        DateTime.now().difference(_lastFetch!) < Duration(minutes: 5)) {
      return _cachedClients!;
    }

    _cachedClients = await _apiService.listClients();
    _lastFetch = DateTime.now();
    return _cachedClients!;
  }
}
```

3. **Use pull-to-refresh** to give users control over data freshness

## Troubleshooting

### "Connection timeout" error
- Check if backend is running
- Verify `baseUrl` is correct
- Check network connectivity
- Increase timeout in `api_config.dart`

### "404 Not Found" errors
- Verify endpoint paths match backend routes
- Check API version in URL
- Confirm backend endpoints are implemented

### "Unauthorized" errors
- Ensure authentication token is set
- Verify token hasn't expired
- Check token format matches backend expectations

### Dashboard shows mock data
- Check console for error messages
- Verify backend URL is accessible
- Confirm endpoints return correct JSON structure

## Next Steps

- [ ] Configure production backend URL
- [ ] Integrate Clerk authentication
- [ ] Add error reporting (e.g., Sentry)
- [ ] Implement offline support with local caching
- [ ] Add API response caching layer
- [ ] Remove mock data fallbacks in production

## Support

For MCP server documentation, see `FLUTTER_MCP_INTEGRATION.md`.
