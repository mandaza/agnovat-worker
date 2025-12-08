import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agnovat_w/data/models/user.dart';
import 'package:agnovat_w/data/models/client.dart';
import 'package:agnovat_w/data/models/goal.dart';
import 'package:agnovat_w/data/models/activity.dart';

/// Test data helpers for integration tests

/// Create a test support worker user
User createTestSupportWorker({
  String id = 'test_support_worker_1',
  String clerkId = 'clerk_support_worker_1',
  String email = 'worker@test.com',
  String name = 'Test Support Worker',
}) {
  return User(
    id: id,
    clerkId: clerkId,
    email: email,
    name: name,
    role: UserRole.supportWorker,
    active: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );
}

/// Create a test behavior practitioner user
User createTestBehaviorPractitioner({
  String id = 'test_bp_1',
  String clerkId = 'clerk_bp_1',
  String email = 'bp@test.com',
  String name = 'Test Behavior Practitioner',
}) {
  return User(
    id: id,
    clerkId: clerkId,
    email: email,
    name: name,
    role: UserRole.behaviorPractitioner,
    active: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );
}

/// Create a test support coordinator user
User createTestCoordinator({
  String id = 'test_coordinator_1',
  String clerkId = 'clerk_coordinator_1',
  String email = 'coordinator@test.com',
  String name = 'Test Coordinator',
}) {
  return User(
    id: id,
    clerkId: clerkId,
    email: email,
    name: name,
    role: UserRole.supportCoordinator,
    active: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );
}

/// Create a test client
Client createTestClient({
  String id = 'test_client_1',
  String name = 'John Test Client',
  String dateOfBirth = '2000-01-15',
  bool active = true,
}) {
  return Client(
    id: id,
    name: name,
    dateOfBirth: dateOfBirth,
    active: active,
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now(),
  );
}

/// Create a test goal
Goal createTestGoal({
  String id = 'test_goal_1',
  String clientId = 'test_client_1',
  String title = 'Test Goal',
  String description = 'Test goal description',
  GoalStatus status = GoalStatus.inProgress,
  bool archived = false,
}) {
  final targetDate = DateTime.now().add(const Duration(days: 90));
  return Goal(
    id: id,
    clientId: clientId,
    title: title,
    description: description,
    status: status,
    category: GoalCategory.healthWellbeing,
    targetDate: targetDate.toIso8601String().split('T')[0], // ISO format YYYY-MM-DD
    progressPercentage: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
    archived: archived,
  );
}

/// Create a test activity
Activity createTestActivity({
  String id = 'test_activity_1',
  String clientId = 'test_client_1',
  String stakeholderId = 'test_support_worker_1',
  String title = 'Test Activity',
  ActivityType activityType = ActivityType.therapy,
  ActivityStatus status = ActivityStatus.completed,
}) {
  return Activity(
    id: id,
    clientId: clientId,
    stakeholderId: stakeholderId,
    title: title,
    activityType: activityType,
    status: status,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Pump and settle with a timeout to avoid infinite animations
Future<void> pumpAndSettleWithTimeout(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.pumpAndSettle(timeout);
}

/// Find a widget by text with retry logic
Future<Finder> findTextWithRetry(
  WidgetTester tester,
  String text, {
  int maxRetries = 5,
  Duration retryDelay = const Duration(milliseconds: 500),
}) async {
  for (int i = 0; i < maxRetries; i++) {
    await tester.pump(retryDelay);
    final finder = find.text(text);
    if (finder.evaluate().isNotEmpty) {
      return finder;
    }
  }
  return find.text(text);
}

/// Scroll until a widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder item,
  Finder scrollable, {
  double delta = 100.0,
  int maxScrolls = 50,
}) async {
  for (int i = 0; i < maxScrolls; i++) {
    if (item.evaluate().isNotEmpty) {
      await tester.ensureVisible(item);
      return;
    }
    await tester.drag(scrollable, Offset(0, -delta));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
