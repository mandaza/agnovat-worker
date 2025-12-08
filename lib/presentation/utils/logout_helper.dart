import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../core/providers/service_providers.dart';
import '../providers/auth_provider.dart';
import '../providers/client_details_provider.dart';
import '../providers/guardian_dashboard_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/behavior_incident_reviews_provider.dart';
import '../providers/behavior_practitioner_provider.dart';

/// Centralized logout flow that terminates the session, clears all local
/// data, and forcefully resets the navigation stack to the login screen.
Future<void> performLogout(BuildContext context, WidgetRef ref) async {
  // Use container to avoid ref disposal during async work
  final container = ProviderScope.containerOf(context, listen: false);
  try {
    debugPrint('🚪 Logout: Starting full logout flow');

    // Stop auth background work and mark as logged out immediately.
    container.read(authProvider.notifier).forceLogout();

    // Invalidate data providers IMMEDIATELY to prevent API calls during logout
    container.invalidate(guardianDashboardProvider);
    container.invalidate(clientsListCachedProvider);
    container.invalidate(dashboardProvider);
    container.invalidate(dashboardDataProvider);
    container.invalidate(behaviorIncidentReviewsProvider);
    container.invalidate(unacknowledgedReviewsProvider);
    container.invalidate(unacknowledgedReviewCountProvider);
    container.invalidate(behaviorPractitionerProvider);
    debugPrint('🚪 Logout: Data providers invalidated');

    // Sign out from Clerk (primary auth session).
    final clerkAuth = ClerkAuth.of(context);
    await clerkAuth.signOut();
    debugPrint('✅ Logout: Clerk sign out completed');

    // Clear local database drafts.
    final database = container.read(appDatabaseProvider);
    await database.clearAllDrafts();
    debugPrint('✅ Logout: Local database cleared');

    // Clear SharedPreferences cache.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('✅ Logout: SharedPreferences cleared');

    // Clear secure storage.
    final secureStorage = container.read(secureStorageServiceProvider);
    await secureStorage.clearAll();
    debugPrint('✅ Logout: SecureStorage cleared');

    // Invalidate remaining system providers to reset app state.
    container.invalidate(authProvider);
    container.invalidate(appDatabaseProvider);
    // Clear any cached auth tokens on Convex client (defensive).
    container.read(convexClientProvider).clearAuthToken();
    debugPrint('✅ Logout: System providers invalidated');

    // Small delay to let invalidations settle.
    await Future.delayed(const Duration(milliseconds: 50));

    // Forcefully reset the entire app navigation stack.
    // This is the most robust way to ensure the user lands on the login screen.
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AgnovatApp()),
        (route) => false,
      );
    }
  } catch (e) {
    debugPrint('❌ Logout: Error during logout - $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign out failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


