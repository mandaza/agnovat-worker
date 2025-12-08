import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper function to pump a widget wrapped with necessary providers
///
/// Usage:
/// ```dart
/// await tester.pumpApp(
///   MyWidget(),
///   overrides: [
///     myProvider.overrideWith((ref) => mockValue),
///   ],
/// );
/// ```
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          themeMode: themeMode,
          home: Scaffold(
            body: widget,
          ),
        ),
      ),
    );
  }

  /// Pump a route/screen for testing navigation
  Future<void> pumpRoute(
    Widget screen, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: screen,
        ),
      ),
    );
  }
}

/// Get the ProviderContainer from a widget test
extension GetContainer on WidgetTester {
  ProviderContainer container() {
    final element = this.element(find.byType(ProviderScope));
    final container = ProviderScope.containerOf(element);
    return container;
  }
}
