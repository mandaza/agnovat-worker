# Integration Tests

This directory contains end-to-end integration tests for the Agnovat Support Worker app.

## Overview

Integration tests verify complete user workflows by running the actual app and simulating user interactions. Unlike unit tests that test components in isolation, integration tests ensure all parts work together correctly.

## Test Structure

```
integration_test/
├── helpers/
│   ├── test_helpers.dart      # Test data creation helpers
│   └── mock_providers.dart    # Mock providers for testing
├── shift_note_workflow_test.dart    # Shift note user stories
├── error_handling_test.dart         # Error scenarios
└── README.md                         # This file
```

## Test Coverage

### User Story Tests (shift_note_workflow_test.dart)

**Support Worker Workflows:**
- ✅ Create shift note and save as draft
- ✅ Edit draft shift note
- ✅ Submit shift note
- ✅ View assigned client profiles, goals, and activities

**Access Control:**
- ✅ Behavior Practitioner can view but not create shift notes
- ✅ Coordinator can view all shift notes
- ✅ Cannot edit submitted shift notes

### Error Handling Tests (error_handling_test.dart)

**API Errors:**
- ✅ Null response handling
- ✅ Activity session creation failures
- ✅ Missing required fields
- ✅ Type casting errors (the current bug!)

**Network Errors:**
- ✅ Network request failures
- ✅ Timeout handling
- ✅ Retry mechanisms

**Data Validation:**
- ✅ Form validation
- ✅ Time range validation
- ✅ Required field checks

**State Management:**
- ✅ Draft recovery after restart
- ✅ Concurrent edit handling

## Running Integration Tests

### Run All Integration Tests
```bash
flutter test integration_test/
```

### Run Specific Test File
```bash
# Shift note workflow tests
flutter test integration_test/shift_note_workflow_test.dart

# Error handling tests
flutter test integration_test/error_handling_test.dart
```

### Run on Real Device/Emulator
```bash
# Start your emulator or connect a device first
flutter test integration_test/ --device-id=<device-id>
```

### Run with Verbose Output
```bash
flutter test integration_test/ --verbose
```

## How Integration Tests Work

### 1. Mock Authentication
Tests bypass real authentication by overriding auth providers:

```dart
final overrides = createTestProviderOverrides(
  currentUser: createTestSupportWorker(), // Simulate logged-in user
  clients: [createTestClient()],           // Mock data
);
```

### 2. Mock API Responses
API calls are intercepted and mocked:

```dart
onCreateShiftNote: () {
  return {
    '_id': 'test_shift_note_123',
    'status': 'draft',
    // ... mock response data
  };
}
```

### 3. Simulate User Actions
Tests interact with the app like a real user:

```dart
// Find and tap a button
await tester.tap(find.text('Create Shift Note'));
await tester.pumpAndSettle();

// Enter text in a field
await tester.enterText(find.byKey(Key('notes_field')), 'Test notes');

// Verify results
expect(find.text('Draft saved'), findsOneWidget);
```

## Test Helpers

### Creating Test Users
```dart
// Support Worker
final worker = createTestSupportWorker();

// Behavior Practitioner
final bp = createTestBehaviorPractitioner();

// Coordinator
final coordinator = createTestCoordinator();
```

### Creating Test Data
```dart
// Client
final client = createTestClient(name: 'John Doe');

// Goal
final goal = createTestGoal(
  clientId: client.id,
  title: 'Improve communication',
);

// Activity
final activity = createTestActivity(
  clientId: client.id,
  title: 'Speech therapy',
);
```

## Debugging Tests

### View Test Output
All test output is printed to console. Look for:
- ✅ Test passed indicators
- ❌ Error messages
- Widget tree dumps (on failure)

### Common Issues

**1. Test Timeout**
- Increase timeout: `await tester.pumpAndSettle(Duration(seconds: 10));`
- Or use: `await pumpAndSettleWithTimeout(tester);`

**2. Widget Not Found**
- Check if widget is visible on screen
- Wait for animations: `await tester.pumpAndSettle();`
- Use retry logic: `await findTextWithRetry(tester, 'Button Text');`

**3. State Not Updating**
- Ensure `pumpAndSettle()` is called after actions
- Check provider overrides are correct

## Adding New Tests

### 1. Define User Story
```dart
testWidgets('User can complete specific workflow', (tester) async {
  // Arrange: Set up test data
  final user = createTestSupportWorker();
  final client = createTestClient();

  // Act: Perform user actions
  // ...

  // Assert: Verify results
  expect(find.text('Success'), findsOneWidget);
});
```

### 2. Mock Required APIs
```dart
final overrides = createTestProviderOverrides(
  currentUser: user,
  clients: [client],
  onCreateShiftNote: () {
    // Return mock response
  },
);
```

### 3. Simulate User Flow
```dart
// Navigate to screen
await tester.tap(find.text('Menu Item'));
await tester.pumpAndSettle();

// Fill form
await tester.enterText(find.byKey(Key('field')), 'value');

// Submit
await tester.tap(find.text('Submit'));
await tester.pumpAndSettle();

// Verify
expect(find.text('Saved'), findsOneWidget);
```

## Best Practices

1. **Test User Stories, Not Implementation**
   - Focus on what users can do, not how it's coded
   - Example: "Worker can save draft" not "DraftProvider updates state"

2. **Use Descriptive Test Names**
   - ✅ `'Support worker can create and save shift note as draft'`
   - ❌ `'Test shift note creation'`

3. **Arrange-Act-Assert Pattern**
   - Arrange: Set up test data
   - Act: Perform user actions
   - Assert: Verify expected results

4. **Independent Tests**
   - Each test should work independently
   - Don't rely on test execution order
   - Use `setUp()` for common initialization

5. **Mock External Dependencies**
   - Never call real APIs in tests
   - Mock authentication
   - Use test data

## CI/CD Integration

Integration tests are included in the GitHub Actions workflow but commented out by default (they're slower than unit tests).

To enable in CI/CD:
1. Uncomment integration test job in `.github/workflows/test.yml`
2. Ensure device/emulator is available in CI environment

## Next Steps

1. **Complete TODO items** in test files (marked with `// TODO:`)
2. **Add screen navigation** once you know the app's navigation structure
3. **Expand coverage** to more user stories
4. **Add golden tests** for visual regression testing

## Questions?

See the main `test/README.md` for general testing information, or check the [Flutter Integration Testing docs](https://docs.flutter.dev/testing/integration-tests).
