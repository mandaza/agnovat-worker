import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../data/models/client.dart';

/// Client details provider with auto-refresh
/// Fetches real-time client data from Convex
class ClientDetailsNotifier extends AutoDisposeAsyncNotifier<Client> {
  late String _clientId;
  Timer? _refreshTimer;
  
  @override
  Future<Client> build() async {
    throw UnimplementedError('Use clientDetailsProvider(clientId) instead');
  }
  
  Future<Client> _initialize(String clientId) async {
    _clientId = clientId;
    
    // Set up auto-refresh (every 15 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      refresh();
    });
    
    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });
    
    return _fetchClient();
  }
  
  Future<Client> _fetchClient() async {
    final apiService = ref.read(mcpApiServiceProvider);
    return await apiService.getClient(_clientId);
  }
  
  /// Manually refresh client data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchClient());
  }
}

/// Client details provider family (parameterized by client ID)
/// Usage: ref.watch(clientDetailsProvider(clientId))
final clientDetailsProvider = AutoDisposeAsyncNotifierProviderFamily<ClientDetailsNotifier, Client, String>(
  () => ClientDetailsNotifier(),
);

/// Extension to properly initialize the provider
extension ClientDetailsProviderExt on AutoDisposeAsyncNotifierProviderFamily<ClientDetailsNotifier, Client, String> {
  AutoDisposeAsyncNotifierProvider<ClientDetailsNotifier, Client> call(String clientId) {
    return AutoDisposeAsyncNotifierProvider<ClientDetailsNotifier, Client>(() {
      return ClientDetailsNotifier().._initialize(clientId);
    });
  }
}

/// Client summary provider (for dashboard assigned client card)
class ClientSummaryNotifier extends AutoDisposeAsyncNotifier<Map<String, dynamic>> {
  late String _clientId;
  Timer? _refreshTimer;
  
  @override
  Future<Map<String, dynamic>> build() async {
    throw UnimplementedError('Use clientSummaryProvider(clientId) instead');
  }
  
  Future<Map<String, dynamic>> _initialize(String clientId) async {
    _clientId = clientId;
    
    // Set up auto-refresh (every 20 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      refresh();
    });
    
    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });
    
    return _fetchSummary();
  }
  
  Future<Map<String, dynamic>> _fetchSummary() async {
    final apiService = ref.read(mcpApiServiceProvider);
    final summary = await apiService.getClientSummary(_clientId);
    
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
    state = await AsyncValue.guard(() => _fetchSummary());
  }
}

/// Client summary provider family
final clientSummaryProvider = AutoDisposeAsyncNotifierProviderFamily<ClientSummaryNotifier, Map<String, dynamic>, String>(
  () => ClientSummaryNotifier(),
);

/// Manual refresh trigger for client details
final refreshClientProvider = Provider.family<void Function(), String>((ref, clientId) {
  return () {
    ref.invalidate(clientDetailsProvider(clientId));
  };
});

/// Clients list provider with auto-refresh
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

