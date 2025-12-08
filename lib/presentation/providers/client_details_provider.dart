import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/client.dart';
import 'dashboard_provider.dart';
import 'auth_provider.dart';

/// Client details provider with auto-refresh
/// Fetches real-time client data from Convex
class ClientDetailsNotifier extends AutoDisposeFamilyAsyncNotifier<Client, String> {
  Timer? _refreshTimer;

  @override
  Future<Client> build(String clientId) async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.isLoggingOut) {
      throw Exception('Not authenticated');
    }

    // Set up auto-refresh (every 15 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      refresh();
    });

    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return _fetchClient(clientId);
  }

  Future<Client> _fetchClient(String clientId) async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.isLoggingOut) {
      throw Exception('Not authenticated');
    }
    final apiService = ref.read(mcpApiServiceProvider);
    return await apiService.getClient(clientId);
  }

  /// Manually refresh client data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchClient(arg));
  }
}

/// Client details provider family (parameterized by client ID)
/// Usage: ref.watch(clientDetailsProvider(clientId))
final clientDetailsProvider = AutoDisposeAsyncNotifierProviderFamily<ClientDetailsNotifier, Client, String>(
  ClientDetailsNotifier.new,
);

/// Client summary provider (for dashboard assigned client card)
class ClientSummaryNotifier extends AutoDisposeFamilyAsyncNotifier<Map<String, dynamic>, String> {
  Timer? _refreshTimer;

  @override
  Future<Map<String, dynamic>> build(String clientId) async {
    // Set up auto-refresh (every 20 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      refresh();
    });

    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return _fetchSummary(clientId);
  }

  Future<Map<String, dynamic>> _fetchSummary(String clientId) async {
    final apiService = ref.read(mcpApiServiceProvider);
    final summary = await apiService.getClientSummary(clientId);

    return {
      'client': summary.client,
      'goals': summary.goals,
      'recent_activities': summary.recentActivities,
      'last_shift_note': summary.lastShiftNote,
    };
  }

  /// Manually refresh client summary
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSummary(arg));
  }
}

/// Client summary provider family
final clientSummaryProvider = AutoDisposeAsyncNotifierProviderFamily<ClientSummaryNotifier, Map<String, dynamic>, String>(
  ClientSummaryNotifier.new,
);

/// Manual refresh trigger for client details
final refreshClientProvider = Provider.family<void Function(), String>((ref, clientId) {
  return () {
    ref.invalidate(clientDetailsProvider(clientId));
  };
});

/// Clients list state (for immediate, cached access with pagination)
class ClientsListState {
  final List<Client> clients;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentPage;
  static const int pageSize = 20;

  const ClientsListState({
    this.clients = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  ClientsListState copyWith({
    List<Client>? clients,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return ClientsListState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Optimized clients list notifier with caching for instant access
/// Uses keepAlive to maintain cache across navigation
class ClientsListNotifier extends Notifier<ClientsListState> {
  Timer? _refreshTimer;

  @override
  ClientsListState build() {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.isLoggingOut) {
      return const ClientsListState(
        clients: [],
        isLoading: false,
        hasMore: false,
      );
    }

    // Set up auto-refresh (every 30 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      state = state.copyWith(currentPage: 0, hasMore: true);
      _fetchClients(silentRefresh: true);
    });

    // Try to get cached clients from dashboard provider first
    try {
      final dashboardState = ref.read(dashboardProvider);
      if (dashboardState.assignedClients.isNotEmpty && !dashboardState.isLoading) {
        // Use cached data from dashboard immediately, but still fetch fresh data
        final cachedState = ClientsListState(
          clients: dashboardState.assignedClients,
          isLoading: false,
          currentPage: 0,
          hasMore: true,
        );
        // Start background refresh to get fresh data
        Future.microtask(() {
          state = state.copyWith(currentPage: 0, hasMore: true);
          _fetchClients(silentRefresh: true);
        });
        return cachedState;
      }
    } catch (e) {
      // Dashboard provider not available, continue with normal flow
    }

    // Start fetching after build completes
    Future.microtask(() => _fetchClients());

    // Return initial loading state
    return const ClientsListState(isLoading: true);
  }

  /// Fetch clients from API with pagination
  Future<void> _fetchClients({bool silentRefresh = false, bool loadMore = false}) async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.isLoggingOut) {
      // Stop any pending timers and return safe state
      _refreshTimer?.cancel();
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        clients: const [],
        hasMore: false,
        error: null,
      );
      return;
    }

    try {
      if (loadMore) {
        state = state.copyWith(isLoadingMore: true);
      } else if (!silentRefresh) {
        state = state.copyWith(isLoading: true);
      }

      final apiService = ref.read(mcpApiServiceProvider);
      final offset = loadMore ? state.currentPage * ClientsListState.pageSize : 0;
      final limit = ClientsListState.pageSize;
      
      final clients = await apiService.listClients(
        active: true,
        limit: limit,
        offset: offset,
      );

      // Determine if there are more clients to load
      final hasMore = clients.length == limit;

      if (loadMore) {
        // Append to existing list
        state = state.copyWith(
          clients: [...state.clients, ...clients],
          isLoadingMore: false,
          hasMore: hasMore,
          currentPage: state.currentPage + 1,
          error: null,
        );
      } else {
        // Replace list (initial load or refresh)
        state = state.copyWith(
          clients: clients,
          isLoading: false,
          hasMore: hasMore,
          currentPage: hasMore ? 1 : 0,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Load more clients (for infinite scroll)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }
    await _fetchClients(loadMore: true);
  }

  /// Manually refresh clients list (resets pagination)
  Future<void> refresh() async {
    state = state.copyWith(currentPage: 0, hasMore: true);
    await _fetchClients();
  }
}

/// Cached clients list provider (State-based for instant access)
/// Uses keepAlive to maintain cache across navigation for seamless experience
final clientsListCachedProvider =
    NotifierProvider<ClientsListNotifier, ClientsListState>(
  ClientsListNotifier.new,
);

/// Clients list provider with auto-refresh (Stream-based, kept for compatibility)
final clientsListProvider = StreamProvider.autoDispose<List<Client>>((ref) {
  final apiService = ref.watch(mcpApiServiceProvider);
  final controller = StreamController<List<Client>>();

  // Auto-refresh interval (every 30 seconds)
  Timer? timer;

  void fetchData() async {
    try {
      final clients = await apiService.listClients(active: true);
      if (!controller.isClosed) {
        controller.add(clients);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }

  // Initial fetch
  fetchData();

  // Set up periodic refresh
  timer = Timer.periodic(const Duration(seconds: 30), (_) {
    fetchData();
  });

  // Clean up
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

