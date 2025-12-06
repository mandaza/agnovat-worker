import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guardian_dashboard_provider.dart';
import '../profile/profile_screen.dart';
import '../guardian/guardian_shift_notes_screen.dart';
import '../../utils/logout_helper.dart';

/// Guardian Dashboard Screen for Super Guardians and Managers
class GuardianDashboardScreen extends ConsumerStatefulWidget {
  const GuardianDashboardScreen({super.key});

  @override
  ConsumerState<GuardianDashboardScreen> createState() =>
      _GuardianDashboardScreenState();
}

class _GuardianDashboardScreenState extends ConsumerState<GuardianDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final dashboardState = ref.watch(guardianDashboardProvider);

    // If user is logged out or logging out, return to login immediately.
    if (!authState.isAuthenticated || authState.isLoggingOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user found')),
      );
    }

    // Show loading state
    if (dashboardState.isLoading && dashboardState.data == null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: Column(
          children: [
            _buildHeader(context, user),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      );
    }

    // Show error state
    if (dashboardState.error != null && dashboardState.data == null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: Column(
          children: [
            _buildHeader(context, user),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        dashboardState.error!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(guardianDashboardProvider.notifier).refresh();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final data = dashboardState.data!;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(guardianDashboardProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Keep existing
              _buildHeader(context, user),

              const SizedBox(height: 24),

              // System Overview Stats (Top 3 cards)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildTopStats(data),
              ),

              const SizedBox(height: 24),

              // Goals Progress Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildGoalsProgress(data),
              ),

              const SizedBox(height: 24),

              // Activities Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildActivitiesSection(data),
              ),

              const SizedBox(height: 24),

              // Reports Overview Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildReportsOverview(data),
              ),

              const SizedBox(height: 24),

              // Recent Activity Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildRecentActivity(data),
              ),

              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showGuardianMenu(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
        label: const Text(
          'Guardian',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // EXISTING HEADER - Keep as is
  Widget _buildHeader(BuildContext context, User user) {
    // Prefer Convex user image, but fall back to Clerk profile image if missing.
    final clerkUser = ClerkAuth.of(context).user;
    final profileImageUrl = user.imageUrl ?? clerkUser?.imageUrl;
    final firstName = user.name.split(' ').first;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
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
                  const Text(
                    'Agnovat',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
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
                      backgroundColor: AppColors.goldenAmber,
                      backgroundImage:
                          profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                      child: profileImageUrl == null
                          ? Text(
                              firstName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
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
              Text(
                'Welcome back, $firstName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldenAmber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getRoleDisplayName(user.role),
                      style: const TextStyle(
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

  // Top 3 Stats Cards
  Widget _buildTopStats(GuardianDashboardData data) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard(
            value: '${data.activeGoals}',
            label: 'Active Goals',
            color: Colors.white,
            textColor: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallStatCard(
            value: '${data.supportWorkers}',
            label: 'Support Workers',
            color: AppColors.secondary,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallStatCard(
            value: '${data.pendingReports}',
            label: 'Pending Reports',
            color: AppColors.goldenAmber,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
    required String value,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: color == Colors.white
            ? Border.all(color: AppColors.borderLight)
            : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Goals Progress Section
  Widget _buildGoalsProgress(GuardianDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.flag_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Goals Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(fontSize: 14, color: AppColors.deepBrown),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.deepBrown),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Weekly Goal Completion Chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weekly Goal Completion',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${data.goalsOnTrack} On Track',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${data.goalsBehind} Behind',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 8,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withValues(alpha: 0.2),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: 8,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                            if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  weeks[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 3,
                    minY: 0,
                    maxY: 32,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.weeklyProgress
                            .map((w) => FlSpot(w.week.toDouble(), w.onTrack))
                            .toList(),
                        isCurved: true,
                        color: AppColors.success,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.success,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.success.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Individual Goal Cards from real data
        ...data.clientGoals.map((clientGoal) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildIndividualGoalCard(
              name: clientGoal.clientName,
              goals: clientGoal.goals
                  .map((g) => {
                        'title': g.title,
                        'sessions': g.progress,
                      })
                  .toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIndividualGoalCard({
    required String name,
    required List<Map<String, String>> goals,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...goals.map((goal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      goal['title']!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    goal['sessions']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Activities Section
  Widget _buildActivitiesSection(GuardianDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Activities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Activity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity Distribution',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child:                       PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: _buildPieSections(data),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildActivityLegends(data),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Build pie chart sections from real data
  List<PieChartSectionData> _buildPieSections(GuardianDashboardData data) {
    final colors = [
      AppColors.deepBrown,
      AppColors.burntOrange,
      AppColors.goldenAmber,
      AppColors.secondary,
      AppColors.textSecondary,
    ];

    final total = data.activityDistribution.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return [];

    int colorIndex = 0;
    return data.activityDistribution.entries.map((entry) {
      final percentage = ((entry.value / total) * 100).round();
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // Helper: Build activity legends from real data
  List<Widget> _buildActivityLegends(GuardianDashboardData data) {
    final colors = [
      AppColors.deepBrown,
      AppColors.burntOrange,
      AppColors.goldenAmber,
      AppColors.secondary,
      AppColors.textSecondary,
    ];

    final total = data.activityDistribution.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return [const Text('No activities')];

    int colorIndex = 0;
    return data.activityDistribution.entries.map((entry) {
      final percentage = ((entry.value / total) * 100).round();
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      // Format activity type name
      String label = entry.key;
      if (label.contains('_')) {
        label = label.split('_').map((word) => 
          word[0].toUpperCase() + word.substring(1)
        ).join(' ');
      } else {
        label = label[0].toUpperCase() + label.substring(1);
      }

      return _buildLegendItem(label, percentage, color);
    }).toList();
  }

  // Reports Overview Section
  Widget _buildReportsOverview(GuardianDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.description_outlined, size: 20),
            SizedBox(width: 8),
            Text(
              'Reports Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shift Reports & Behavior Incidents',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 70,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.monthlyReports.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  data.monthlyReports[index].month,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: 20,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: data.monthlyReports.asMap().entries.map((entry) {
                      return _buildBarGroup(
                        entry.key,
                        entry.value.shiftReports.toDouble(),
                        entry.value.behaviorIncidents.toDouble(),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBarLegend('Shift Reports', AppColors.secondary),
                  const SizedBox(width: 20),
                  _buildBarLegend('Behavior Incidents', AppColors.error),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double shiftReports, double incidents) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: shiftReports,
          color: AppColors.secondary,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        BarChartRodData(
          toY: incidents,
          color: AppColors.error,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildBarLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  // Recent Activity Section
  Widget _buildRecentActivity(GuardianDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.history, size: 20),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GuardianShiftNotesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.description, size: 16),
              label: const Text('View All Notes'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (data.recentActivities.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Center(
              child: Text('No recent activity'),
            ),
          )
        else
          ...data.recentActivities.map((activity) {
            // Map activity type to icon and color
            IconData icon;
            Color color;
            Color badgeColor;

            switch (activity.type) {
              case 'report':
                icon = Icons.description;
                color = AppColors.textSecondary;
                badgeColor = activity.status == 'submitted' 
                    ? AppColors.textSecondary 
                    : AppColors.goldenAmber;
                break;
              case 'goal':
                icon = Icons.check_circle;
                color = AppColors.success;
                badgeColor = AppColors.success;
                break;
              case 'incident':
                icon = Icons.warning_amber_rounded;
                color = AppColors.error;
                badgeColor = AppColors.error;
                break;
              default:
                icon = Icons.info;
                color = AppColors.primary;
                badgeColor = AppColors.primary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildActivityItem(
                icon: icon,
                title: activity.title,
                subtitle: activity.subtitle,
                time: activity.timeAgo,
                color: color,
                badge: activity.status,
                badgeColor: badgeColor,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bottom Navigation
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

          // Navigate based on index
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              // Shift Notes
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GuardianShiftNotesScreen(),
                ),
              );
              break;
            case 2:
              // Settings - coming soon
              _showComingSoon(context, 'Settings');
              break;
          }
        },
        selectedItemColor: AppColors.primary,
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
            icon: Icon(Icons.description),
            label: 'Shift Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showGuardianMenu(BuildContext context) {
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
              'Guardian Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.description, color: AppColors.primary),
              title: const Text('View Shift Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GuardianShiftNotesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: AppColors.primary),
              title: const Text('Access Control'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Access Control');
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup, color: AppColors.primary),
              title: const Text('System Backup'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'System Backup');
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

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Guardian';
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
        return 'Family Member';
      case UserRole.client:
        return 'Client';
    }
  }
}
