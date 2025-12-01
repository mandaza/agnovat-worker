import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user.dart';
import '../../providers/auth_provider.dart';
import 'worker_dashboard_screen.dart';
import 'guardian_dashboard_screen.dart';
import 'coordinator_dashboard_screen.dart';

/// Dashboard router that routes users to appropriate dashboard based on their role
class DashboardRouter extends ConsumerWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show loading while fetching user data
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error if authentication failed
    if (authState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  authState.error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // No user found - shouldn't happen as Clerk handles this
    if (authState.user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user found. Please sign in again.'),
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

      case UserRole.client:
        // Clients get worker dashboard for now (can be customized later)
        return const WorkerDashboardScreen();
    }
  }
}
