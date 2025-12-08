import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agnovat_w/data/services/mcp_api_service.dart';
import 'package:agnovat_w/data/models/client.dart';
import 'package:agnovat_w/core/providers/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/test_helpers.dart';

import 'simple_provider_test.mocks.dart';

// Simple state class for testing
class CounterState {
  final int count;
  const CounterState(this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterState &&
          runtimeType == other.runtimeType &&
          count == other.count;

  @override
  int get hashCode => count.hashCode;
}

// Simple notifier for demonstration
class CounterNotifier extends AutoDisposeNotifier<CounterState> {
  @override
  CounterState build() {
    return const CounterState(0);
  }

  void increment() {
    state = CounterState(state.count + 1);
  }

  void decrement() {
    state = CounterState(state.count - 1);
  }
}

// Provider for testing
final counterProvider =
    AutoDisposeNotifierProvider<CounterNotifier, CounterState>(
  CounterNotifier.new,
);

@GenerateMocks([McpApiService])
void main() {
  group('Provider Testing Examples', () {
    late MockMcpApiService mockApiService;
    final testDateTime = DateTime(2024, 1, 15);

    setUp(() {
      mockApiService = MockMcpApiService();
    });

    group('Simple Provider Pattern', () {
      test('can override service provider with mock', () {
        final container = createContainer(
          overrides: [
            mcpApiServiceProvider.overrideWith((ref) => mockApiService),
          ],
        );

        final apiService = container.read(mcpApiServiceProvider);

        expect(apiService, equals(mockApiService));
      });

      test('service provider returns mocked data', () async {
        final testClient = Client(
          id: 'client_123',
          name: 'Test Client',
          dateOfBirth: '1990-01-01',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(mockApiService.getClient('client_123'))
            .thenAnswer((_) async => testClient);

        final container = createContainer(
          overrides: [
            mcpApiServiceProvider.overrideWith((ref) => mockApiService),
          ],
        );

        final apiService = container.read(mcpApiServiceProvider);
        final client = await apiService.getClient('client_123');

        expect(client.id, equals('client_123'));
        expect(client.name, equals('Test Client'));

        verify(mockApiService.getClient('client_123')).called(1);
      });
    });

    group('AsyncValue Provider Pattern', () {
      // Create a simple async provider for testing
      final simpleClientProvider =
          FutureProvider.autoDispose<Client>((ref) async {
        final apiService = ref.watch(mcpApiServiceProvider);
        return await apiService.getClient('test_id');
      });

      test('FutureProvider starts in loading state', () {
        when(mockApiService.getClient(any))
            .thenAnswer((_) => Future.delayed(const Duration(hours: 1)));

        final container = createContainer(
          overrides: [
            mcpApiServiceProvider.overrideWith((ref) => mockApiService),
          ],
        );

        final asyncValue = container.read(simpleClientProvider);

        asyncValue.when(
          data: (_) => fail('Should not be in data state'),
          loading: () => expect(true, isTrue),
          error: (_, __) => fail('Should not be in error state'),
        );
      });

      test('FutureProvider transitions to data state', () async {
        final testClient = Client(
          id: 'test_id',
          name: 'Async Client',
          dateOfBirth: '1990-01-01',
          active: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        when(mockApiService.getClient('test_id'))
            .thenAnswer((_) async => testClient);

        final container = createContainer(
          overrides: [
            mcpApiServiceProvider.overrideWith((ref) => mockApiService),
          ],
        );

        // Use .future to await the async value
        final client = await container.read(simpleClientProvider.future);

        expect(client.id, equals('test_id'));
        expect(client.name, equals('Async Client'));
      });

      test('FutureProvider handles errors', () async {
        when(mockApiService.getClient(any))
            .thenThrow(Exception('API Error'));

        final container = createContainer(
          overrides: [
            mcpApiServiceProvider.overrideWith((ref) => mockApiService),
          ],
        );

        expect(
          () => container.read(simpleClientProvider.future),
          throwsException,
        );
      });
    });

    group('StateNotifier Pattern Testing', () {
      test('notifier starts with initial state', () {
        final container = createContainer();

        final state = container.read(counterProvider);

        expect(state.count, equals(0));
      });

      test('notifier can update state', () {
        final container = createContainer();

        container.read(counterProvider.notifier).increment();

        final state = container.read(counterProvider);
        expect(state.count, equals(1));
      });

      test('notifier can update state multiple times', () {
        final container = createContainer();

        final notifier = container.read(counterProvider.notifier);
        notifier.increment();
        notifier.increment();
        notifier.increment();

        final state = container.read(counterProvider);
        expect(state.count, equals(3));
      });

      test('notifier decrement works', () {
        final container = createContainer();

        final notifier = container.read(counterProvider.notifier);
        notifier.increment();
        notifier.increment();
        notifier.decrement();

        final state = container.read(counterProvider);
        expect(state.count, equals(1));
      });
    });

    group('Provider Listening Pattern', () {
      test('can listen to provider changes', () {
        final container = createContainer();

        final states = <int>[];

        // Simple counter provider
        final counterProvider = StateProvider<int>((ref) => 0);

        container.listen(
          counterProvider,
          (previous, next) {
            states.add(next);
          },
        );

        // Update the state
        container.read(counterProvider.notifier).state = 1;
        container.read(counterProvider.notifier).state = 2;
        container.read(counterProvider.notifier).state = 3;

        expect(states, equals([1, 2, 3]));
      });
    });
  });
}
