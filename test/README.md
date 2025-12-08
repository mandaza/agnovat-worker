# Agnovat Testing Guide

This directory contains comprehensive tests for the Agnovat Support Worker application.

## Test Structure

```
test/
├── helpers/                    # Test utilities and helpers
│   ├── test_helpers.dart      # Common test utilities
│   └── pump_app.dart          # Widget testing helpers
├── unit/                       # Unit tests
│   ├── models/                # Model tests (data layer)
│   ├── services/              # Service tests with mocks
│   └── utils/                 # Utility function tests
├── widget/                     # Widget tests
│   ├── cards/                 # Card widget tests
│   ├── screens/               # Screen widget tests
│   └── common/                # Common widget tests
├── providers/                  # Riverpod provider tests
├── golden/                     # Golden test files
└── integration/                # Integration tests (future)

integration_test/               # Integration tests
└── flows/                     # End-to-end user flows
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/unit/models/user_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Generate coverage report (HTML)
```bash
# Install lcov first: brew install lcov (macOS)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Types Implemented

### ✅ Unit Tests (53 tests passing)

#### Model Tests (41 tests)
- **Client Model** (21 tests)
  - Object creation with all/optional fields
  - Age calculation logic
  - JSON serialization/deserialization
  - copyWith method
  - Equality (Equatable)
  - Round-trip serialization

- **ClientWithStats Model** (6 tests)
  - Stats object creation
  - JSON deserialization with defaults
  - Equality with stats

- **User Model** (20 tests)
  - All UserRole enum values
  - Object creation
  - JSON serialization/deserialization
  - Role normalization (snake_case → camelCase)
  - Unknown role fallback handling
  - copyWith method
  - Equality across all roles
  - Round-trip serialization

#### Service Tests (12 tests)
- **McpApiService** (12 tests)
  - getCurrentUser with Clerk ID
  - getUserById
  - listUsers with filters
  - syncUserFromClerk with/without imageUrl
  - getClient by ID
  - listClients with filters
  - createShiftNote
  - Error handling for queries and mutations

## Writing Tests

### Unit Tests for Models

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:agnovat_w/data/models/your_model.dart';

void main() {
  group('YourModel Tests', () {
    test('creates model correctly', () {
      final model = YourModel(id: '123', name: 'Test');

      expect(model.id, equals('123'));
      expect(model.name, equals('Test'));
    });

    test('JSON serialization works', () {
      final model = YourModel(id: '123', name: 'Test');
      final json = model.toJson();
      final deserialized = YourModel.fromJson(json);

      expect(deserialized, equals(model));
    });
  });
}
```

### Service Tests with Mocks

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agnovat_w/core/services/convex_client_service.dart';
import 'package:agnovat_w/data/services/your_service.dart';

import 'your_service_test.mocks.dart';

@GenerateMocks([ConvexClientService])
void main() {
  late MockConvexClientService mockClient;
  late YourService service;

  setUp(() {
    mockClient = MockConvexClientService();
    service = YourService(mockClient);
  });

  test('service method works', () async {
    when(mockClient.query<Map<String, dynamic>>(
      any,
      args: anyNamed('args'),
    )).thenAnswer((_) async => {'id': '123'});

    final result = await service.yourMethod();

    expect(result.id, equals('123'));
    verify(mockClient.query<Map<String, dynamic>>(
      'yourFunction',
      args: anyNamed('args'),
    )).called(1);
  });
}
```

### Provider Tests (Manual Riverpod)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('YourProvider Tests', () {
    test('initial state is correct', () {
      final container = createContainer();

      final state = container.read(yourProvider);

      expect(state.isLoading, isTrue);
      expect(state.data, isEmpty);
    });

    test('loading data updates state', () async {
      final container = createContainer(
        overrides: [
          apiServiceProvider.overrideWith((ref) => mockApiService),
        ],
      );

      await container.read(yourProvider.notifier).loadData();

      final state = container.read(yourProvider);
      expect(state.isLoading, isFalse);
      expect(state.data, isNotEmpty);
    });
  });
}
```

### Widget Tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('YourWidget displays correctly', (tester) async {
    await tester.pumpApp(
      YourWidget(data: testData),
      overrides: [
        yourProvider.overrideWith((ref) => mockValue),
      ],
    );

    expect(find.text('Expected Text'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('YourWidget handles tap', (tester) async {
    var tapped = false;

    await tester.pumpApp(
      YourWidget(onTap: () => tapped = true),
    );

    await tester.tap(find.byType(YourWidget));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
```

## Generating Mocks

After adding `@GenerateMocks([YourClass])` to a test file:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Test Coverage Goals

- **Unit Tests**: 80%+ code coverage
- **Widget Tests**: All reusable widgets covered
- **Provider Tests**: 100% provider coverage
- **Integration Tests**: Top 10 user flows

## Next Steps

The following test types are planned:

- [ ] Provider tests for all Riverpod providers
- [ ] Widget tests for cards and screens
- [ ] Integration tests for user flows
- [ ] Performance tests
- [ ] Accessibility tests
- [ ] Golden tests for UI regression
- [ ] CI/CD automation

## Best Practices

1. **Arrange-Act-Assert**: Structure tests clearly
2. **One assertion per test**: Keep tests focused
3. **Descriptive names**: Use clear test descriptions
4. **Isolated tests**: Each test should be independent
5. **Mock external dependencies**: Use Mockito for services
6. **Test edge cases**: Include null, empty, and error scenarios
7. **Use test helpers**: Leverage helpers for common setup

## Common Issues

### Mock not working
- Run `flutter pub run build_runner build`
- Check `@GenerateMocks` annotation
- Ensure mock file is imported

### Test timeout
- Increase timeout: `timeout: Timeout(Duration(seconds: 30))`
- Check for infinite loops or missing `await`

### Provider not found
- Ensure ProviderScope wraps widget
- Override providers in test setup
- Use `createContainer()` helper

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Riverpod Testing Guide](https://riverpod.dev/docs/how_to/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
