import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/client.dart';

/// Client details provider with auto-refresh
/// Fetches real-time client data from Convex
class ClientDetailsNotifier extends AutoDisposeFamilyAsyncNotifier<Client, String> {
  Timer? _refreshTimer;

  @override
  Future<Client> build(String clientId) async {
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

/// Clients list state (for immediate, cached access)
class ClientsListState {
  final List<Client> clients;
  final bool isLoading;
  final String? error;

  const ClientsListState({
    this.clients = const [],
    this.isLoading = false,
    this.error,
  });

  ClientsListState copyWith({
    List<Client>? clients,
    bool? isLoading,
    String? error,
  }) {
    return ClientsListState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Optimized clients list notifier with caching for instant access
class ClientsListNotifier extends AutoDisposeNotifier<ClientsListState> {
  Timer? _refreshTimer;

  @override
  ClientsListState build() {
    // Set up auto-refresh (every 30 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchClients(silentRefresh: true);
    });

    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    // Schedule initial fetch after build completes
    Future.microtask(() => _fetchClients());

    // Return initial state (clients will load in background)
    return const ClientsListState(isLoading: true);
  }

  /// Fetch clients from API
  Future<void> _fetchClients({bool silentRefresh = false}) async {
    try {
      if (!silentRefresh) {
        state = state.copyWith(isLoading: true);
      }

      final apiService = ref.read(mcpApiServiceProvider);
      final clients = await apiService.listClients(active: true);

      state = state.copyWith(
        clients: clients,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Manually refresh clients list
  Future<void> refresh() async {
    await _fetchClients();
  }
}

/// Cached clients list provider (State-based for instant access)
final clientsListCachedProvider =
    AutoDisposeNotifierProvider<ClientsListNotifier, ClientsListState>(
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

