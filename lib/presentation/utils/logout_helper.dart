import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/service_providers.dart';
import '../providers/auth_provider.dart';
import '../providers/client_details_provider.dart';
import '../providers/guardian_dashboard_provider.dart';

/// Centralized logout flow to ensure session is fully terminated and caches cleared.
Future<void> performLogout(BuildContext context, WidgetRef ref,
    {bool navigateToLogin = true}) async {
  try {
    debugPrint('🚪 Logout: Starting full logout flow');

    // Stop auth background work and mark as logged out immediately.
    ref.read(authProvider.notifier).forceLogout();

    // Sign out from Clerk (primary auth session).
    final clerkAuth = ClerkAuth.of(context);
    await clerkAuth.signOut();
    debugPrint('✅ Logout: Clerk sign out completed');

    // Clear local database drafts.
    final database = ref.read(appDatabaseProvider);
    await database.clearAllDrafts();
    debugPrint('✅ Logout: Local database cleared');

    // Clear SharedPreferences cache.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('✅ Logout: SharedPreferences cleared');

    // Clear secure storage.
    final secureStorage = ref.read(secureStorageServiceProvider);
    await secureStorage.clearAll();
    debugPrint('✅ Logout: SecureStorage cleared');

    // Invalidate providers to reset app state.
    ref.invalidate(authProvider);
    ref.invalidate(appDatabaseProvider);
    ref.invalidate(guardianDashboardProvider);
    ref.invalidate(clientsListCachedProvider);
    debugPrint('✅ Logout: Providers invalidated');

    // Small delay to let invalidations settle.
    await Future.delayed(const Duration(milliseconds: 150));

    // Navigate back to the root/login screen.
    if (navigateToLogin && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      debugPrint('✅ Logout: Navigated to login screen');
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

