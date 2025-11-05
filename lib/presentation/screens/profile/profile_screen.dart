import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/user.dart';
import '../../providers/auth_provider.dart';

/// Profile Screen
/// Displays user information, settings, and account options
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildAppBar(context, ref),

          // Profile Content
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),

              // Profile Header Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildProfileHeader(context, user),
              ),

              const SizedBox(height: 24),

              // Account Section
              _buildSectionTitle('Account'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildAccountSection(context, user),
              ),

              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionTitle('Preferences'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildPreferencesSection(context),
              ),

              const SizedBox(height: 24),

              // Support Section
              _buildSectionTitle('Help & Support'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildSupportSection(context),
              ),

              const SizedBox(height: 24),

              // Sign Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildSignOutButton(context, ref, authState.isLoading),
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  /// App Bar with back button
  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      pinned: false,
      floating: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.borderLight,
        ),
      ),
    );
  }

  /// Profile Header with avatar and basic info
  Widget _buildProfileHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.deepBrown, AppColors.burntOrange],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLight,
                width: 4,
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(user?.name ?? 'User'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user?.name ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.deepBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleDisplayName(user?.role),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Account Section
  Widget _buildAccountSection(BuildContext context, User? user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Update your name and contact details',
            onTap: () {
              // TODO: Navigate to personal info screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Personal Information - Coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.badge_outlined,
            title: 'Professional Details',
            subtitle: user?.specialty ?? 'Add your specialty',
            onTap: () {
              // TODO: Navigate to professional details screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Professional Details - Coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Password & Security',
            subtitle: 'Change password and security settings',
            onTap: () {
              // TODO: Navigate to password screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password & Security - Coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Preferences Section
  Widget _buildPreferencesSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              // TODO: Navigate to notifications screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications - Coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // TODO: Navigate to language screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language - Coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: 'Light mode',
            onTap: () {
              // TODO: Navigate to theme screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme - Coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Support Section
  Widget _buildSupportSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Get help and support',
            onTap: () {
              // TODO: Navigate to help center
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help Center - Coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () {
              // TODO: Navigate to privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy - Coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'View our terms of service',
            onTap: () {
              // TODO: Navigate to terms of service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service - Coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// Sign Out Button
  Widget _buildSignOutButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading
            ? null
            : () async {
                // Show confirmation dialog
                final confirmed = await _showSignOutDialog(context);
                if (confirmed == true && context.mounted) {
                  // Sign out using Clerk
                  await _handleSignOut(context);
                }
              },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.error, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error,
                ),
              )
            : const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
      ),
    );
  }

  /// Handle sign out with Clerk
  Future<void> _handleSignOut(BuildContext context) async {
    try {
      // Get the Clerk auth from the widget tree
      final clerkAuth = ClerkAuth.of(context);
      
      // Sign out from Clerk
      await clerkAuth.signOut();
      
      // Pop all routes to go back to root - ClerkAuthBuilder will show sign-in screen
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// List Tile
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.deepBrown.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.deepBrown,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Divider
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Container(
        height: 1,
        color: AppColors.borderLight,
      ),
    );
  }

  /// Get initials from name
  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Get role display name
  String _getRoleDisplayName(UserRole? role) {
    if (role == null) return 'User';

    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.supportCoordinator:
        return 'Support Coordinator';
      case UserRole.supportWorker:
        return 'Support Worker';
      case UserRole.therapist:
        return 'Therapist';
      case UserRole.family:
        return 'Family';
      case UserRole.client:
        return 'Client';
    }
  }

  /// Show sign out confirmation dialog
  Future<bool?> _showSignOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Agnovat'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agnovat Support Worker', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Empowering support workers to provide exceptional NDIS care.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
