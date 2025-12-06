import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user.dart';
import '../../providers/auth_provider.dart';
import 'worker_dashboard_screen.dart';
import 'guardian_dashboard_screen.dart';
import 'coordinator_dashboard_screen.dart';
import 'behavior_practitioner_dashboard_screen.dart';

/// Dashboard router that routes users to appropriate dashboard based on their role
class DashboardRouter extends ConsumerWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show loading while fetching user data
    // The auth provider will automatically retry in the background
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error if authentication failed (only after all retries are exhausted)
    // This should rarely happen as auth provider retries in background
    if (authState.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Authentication Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    authState.error!.contains('No authenticated user')
                        ? 'Please sign out and sign in again to sync your profile.'
                        : authState.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                // No retry button - auth provider handles retries automatically in background
                Text(
                  'If this persists, please sign out and sign in again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // No user found - check if this is a logout scenario or login issue
    // If user is not authenticated (logged out), don't try to refresh
    // If user IS authenticated but user data is null, trigger a refresh
    if (authState.user == null) {
      if (!authState.isAuthenticated) {
        // User is logged out - show a blank screen and let ClerkAuthBuilder switch to SignInScreen
        // This prevents the refresh loop during logout
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // User is authenticated but profile data is missing - trigger a refresh
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).refresh();
      });

      // Show loading spinner while refreshing
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Route to appropriate dashboard based on user role
    return _buildDashboardForRole(authState.user!);
  }

  /// Build dashboard widget based on user role
  Widget _buildDashboardForRole(User user) {
    switch (user.role) {
      case UserRole.superAdmin:
      case UserRole.manager:
        // Super admins and managers get guardian dashboard (web app will be separate)
        return const GuardianDashboardScreen();

      case UserRole.family:
        // Family/parents/guardians get guardian dashboard to view their client's data
        return const GuardianDashboardScreen();

      case UserRole.supportCoordinator:
        // Support coordinators get their own dashboard
        return const CoordinatorDashboardScreen();

      case UserRole.supportWorker:
        // Support workers get worker dashboard (existing)
        return const WorkerDashboardScreen();

      case UserRole.therapist:
        // Therapists get worker dashboard for now (can be customized later)
        return const WorkerDashboardScreen();

      case UserRole.behaviorPractitioner:
        // Behavior practitioners get their own dashboard
        return const BehaviorPractitionerDashboardScreen();

      case UserRole.client:
        // Clients get worker dashboard for now (can be customized later)
        return const WorkerDashboardScreen();
    }
  }
}
