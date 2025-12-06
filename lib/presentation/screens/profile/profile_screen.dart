import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/logout_helper.dart';

/// Profile Screen
/// Displays user information, settings, and account options
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // If not authenticated (e.g., just logged out), immediately return to root/login.
    if (!authState.isAuthenticated || authState.isLoggingOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show loading state
    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
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
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (authState.error != null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
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
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authState.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).refresh();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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

              // Show warning if no user data
              if (user == null || user.email.isEmpty || user.email == 'No email')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.goldenAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.goldenAmber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.goldenAmber,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Profile Sync Required',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Please sign out and sign in again to sync your profile data.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (user == null || user.email.isEmpty || user.email == 'No email')
                const SizedBox(height: 16),

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
          // Avatar with image support
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepBrown.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                  ? Image.network(
                      user.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to initials if image fails to load
                        return Center(
                          child: Text(
                            _getInitials(user.name),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        );
                      },
                    )
                  : Center(
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? 'No email',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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

          // Account Info
          if (user != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Account Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Member Since
                _buildInfoColumn(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member Since',
                  value: _formatDate(user.createdAt),
                ),
                // Divider
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderLight,
                ),
                // Last Login
                _buildInfoColumn(
                  icon: Icons.access_time_outlined,
                  label: 'Last Login',
                  value: user.lastLogin != null
                      ? _formatLastLogin(user.lastLogin!)
                      : 'Never',
                ),
                // Divider
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderLight,
                ),
                // Account Status
                _buildInfoColumn(
                  icon: user.active
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  label: 'Status',
                  value: user.active ? 'Active' : 'Inactive',
                  valueColor: user.active ? AppColors.success : AppColors.error,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build info column for account details
  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: valueColor ?? AppColors.deepBrown,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Format date to readable format
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Format last login to relative time
  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastLogin.day}/${lastLogin.month}/${lastLogin.year}';
    }
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
                  await _handleSignOut(context, ref);
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
  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    await performLogout(context, ref);
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
      case UserRole.behaviorPractitioner:
        return 'Behavior Practitioner';
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

}
