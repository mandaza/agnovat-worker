import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Test helper utilities for the Agnovat app tests

/// Creates a ProviderContainer for testing with optional overrides
///
/// Usage:
/// ```dart
/// final container = createContainer(
///   overrides: [
///     myProvider.overrideWith((ref) => mockValue),
///   ],
/// );
/// ```
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    overrides: overrides,
  );

  addTearDown(container.dispose);

  return container;
}

/// Wait for async providers to complete
///
/// Usage:
/// ```dart
/// await waitForAsync();
/// ```
Future<void> waitForAsync() async {
  await Future.delayed(Duration.zero);
}

/// Pump frames multiple times to ensure all async operations complete
Future<void> pumpAndSettle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await waitForAsync();
  await tester.pump();
}
