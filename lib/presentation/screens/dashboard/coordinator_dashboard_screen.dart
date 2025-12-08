import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/user.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_screen.dart';
import '../../utils/logout_helper.dart';

/// Support Coordinator Dashboard Screen
class CoordinatorDashboardScreen extends ConsumerStatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  ConsumerState<CoordinatorDashboardScreen> createState() =>
      _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState
    extends ConsumerState<CoordinatorDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, user),

              const SizedBox(height: 24),

              // Team Overview Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsGrid(),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Team Activity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Team Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCoordinatorMenu(context);
        },
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.supervisor_account, color: Colors.white),
        label: const Text(
          'Coordinate',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User user) {
    final firstName = user.name.split(' ').first;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.tertiary,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row - Logo and Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App branding
                  const Text(
                    'Agnovat',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  // Profile Avatar
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      backgroundImage: user.imageUrl != null
                          ? NetworkImage(user.imageUrl!)
                          : null,
                      child: user.imageUrl == null
                          ? Text(
                              firstName[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Welcome message
              Text(
                'Welcome back, $firstName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.supervisor_account,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Support Coordinator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.people_outline,
          label: 'Team Members',
          value: '8', // TODO: Replace with actual data
          color: AppColors.secondary,
        ),
        _buildStatCard(
          icon: Icons.person_outline,
          label: 'Assigned Clients',
          value: '15', // TODO: Replace with actual data
          color: AppColors.tertiary,
        ),
        _buildStatCard(
          icon: Icons.event_note,
          label: 'Active Activities',
          value: '42', // TODO: Replace with actual data
          color: AppColors.primary,
        ),
        _buildStatCard(
          icon: Icons.pending_actions,
          label: 'Pending Reviews',
          value: '5', // TODO: Replace with actual data
          color: AppColors.goldenAmber,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.assignment_ind,
                label: 'Assign Tasks',
                onTap: () {
                  _showComingSoon(context, 'Task Assignment');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.group,
                label: 'Team Management',
                onTap: () {
                  _showComingSoon(context, 'Team Management');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.schedule,
                label: 'Schedule',
                onTap: () {
                  _showComingSoon(context, 'Schedule Management');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.assessment,
                label: 'Reports',
                onTap: () {
                  _showComingSoon(context, 'Reports');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    // TODO: Replace with actual recent activity data
    final activities = [
      {
        'user': 'Jane Doe',
        'action': 'Completed shift with client',
        'time': '1 hour ago',
        'icon': Icons.check_circle,
      },
      {
        'user': 'Tom Brown',
        'action': 'Submitted shift notes',
        'time': '2 hours ago',
        'icon': Icons.note_add,
      },
      {
        'user': 'Mary Johnson',
        'action': 'Requested schedule change',
        'time': '4 hours ago',
        'icon': Icons.schedule,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.secondary.withOpacity(0.1),
              child: Icon(
                activity['icon'] as IconData,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            title: Text(
              activity['user'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              activity['action'] as String,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              activity['time'] as String,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // TODO: Implement navigation based on index
        },
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  void _showCoordinatorMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Coordinator Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.assignment, color: AppColors.secondary),
              title: const Text('Task Management'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Task Management');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.schedule_send, color: AppColors.secondary),
              title: const Text('Schedule Coordination'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Schedule Coordination');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.assessment, color: AppColors.secondary),
              title: const Text('Performance Review'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Performance Review');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sign Out'),
              onTap: () async {
                Navigator.pop(context);
                await performLogout(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

