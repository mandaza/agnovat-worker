import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/client.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/activity.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/config/api_config.dart';
import '../../providers/auth_provider.dart';

/// Provider for client goals list
final _goalsListProvider = FutureProvider.autoDispose.family<List<Goal>, String>((ref, clientId) async {
  final convexClient = ref.watch(convexClientProvider);
  final result = await convexClient.query<List<dynamic>?>(
    ApiConfig.goalsList,
    args: {'client_id': clientId, 'archived': false},
  );
  return (result ?? []).map((json) => Goal.fromJson(json as Map<String, dynamic>)).toList();
});

/// Provider for client activities list
final _activitiesListProvider = FutureProvider.autoDispose.family<List<Activity>, String>((ref, clientId) async {
  final apiService = ref.watch(mcpApiServiceProvider);
  return await apiService.listActivities(clientId: clientId, limit: 20);
});

/// Provider for client shift notes list
final _shiftNotesListProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, clientId) async {
  final apiService = ref.watch(mcpApiServiceProvider);
  
  // Get current user ID from auth provider to filter shift notes
  final authState = ref.read(authProvider);
  final currentUserId = authState.user?.id;
  
  if (currentUserId == null) {
    // No user logged in, return empty list
    return [];
  }
  
  try {
    // Filter by both clientId and current user's ID (stakeholderId)
    final shiftNotes = await apiService.listShiftNotes(
      clientId: clientId,
      stakeholderId: currentUserId, // Filter by current user
      limit: 20,
    );
    
    // Return empty list if null or ensure it's a list
    return shiftNotes;
  } catch (e) {
    // Return empty list on error to prevent crashes
    print('Error loading shift notes: $e');
    return [];
  }
});

/// Client Details Screen
/// Displays limited client information for support workers
/// - Name and Age (NOT full DOB)
/// - Active goals
/// - Recent activities
/// - Does NOT show NDIS number or full DOB (privacy restriction)
class ClientDetailsScreen extends ConsumerStatefulWidget {
  final Client client;

  const ClientDetailsScreen({
    super.key,
    required this.client,
  });

  @override
  ConsumerState<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends ConsumerState<ClientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with Client Header
          _buildAppBar(context),

          // Client Info Card
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildClientInfoCard(context),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.deepBrown,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.deepBrown,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Goals'),
                  Tab(text: 'Activities'),
                  Tab(text: 'Notes'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildGoalsTab(),
                _buildActivitiesTab(),
                _buildNotesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// App Bar with gradient background
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.deepBrown,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.deepBrown, AppColors.burntOrange],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(widget.client.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Name
                Text(
                  widget.client.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Age
                Text(
                  'Age ${widget.client.age}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Client Info Card with quick stats
  Widget _buildClientInfoCard(BuildContext context) {
    final clientWithStats = widget.client is ClientWithStats
        ? widget.client as ClientWithStats
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.flag_outlined,
                    value: clientWithStats?.activeGoalsCount.toString() ?? '0',
                    label: 'Active Goals',
                    color: AppColors.deepBrown,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderLight,
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.event_note_outlined,
                    value: clientWithStats?.totalActivitiesCount.toString() ?? '0',
                    label: 'Activities',
                    color: AppColors.goldenAmber,
                  ),
                ),
              ],
            ),
            if (widget.client.active) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Active Client',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Stat Item Widget
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Overview Tab
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information Section
          _buildSectionTitle('Contact Information'),
          const SizedBox(height: 12),
          _buildInfoCard(
            children: [
              if (widget.client.primaryContact != null)
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Primary Contact',
                  value: widget.client.primaryContact!,
                )
              else
                _buildEmptyState('No contact information available'),
            ],
          ),
          const SizedBox(height: 24),

          // Support Notes Section
          _buildSectionTitle('Support Notes'),
          const SizedBox(height: 12),
          _buildInfoCard(
            children: [
              if (widget.client.supportNotes != null &&
                  widget.client.supportNotes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(17),
                  child: Text(
                    widget.client.supportNotes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                )
              else
                _buildEmptyState('No support notes available'),
            ],
          ),
          const SizedBox(height: 24),

          // Privacy Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Some client information is restricted for privacy.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Goals Tab
  Widget _buildGoalsTab() {
    // Fetch goals from Convex in real-time
    return Consumer(
      builder: (context, ref, child) {
        final goalsAsync = ref.watch(
          _goalsListProvider(widget.client.id),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Active Goals'),
              const SizedBox(height: 12),
              goalsAsync.when(
                data: (goals) {
                  if (goals.isEmpty) {
                    return _buildEmptyState('No active goals for this client.');
                  }
                  return Column(
                    children: goals.map((goal) => _buildGoalCard(goal)).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildEmptyState('Error loading goals: $error'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Activities Tab
  Widget _buildActivitiesTab() {
    // Fetch activities from Convex in real-time
    return Consumer(
      builder: (context, ref, child) {
        final activitiesAsync = ref.watch(
          _activitiesListProvider(widget.client.id),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Recent Activities'),
              const SizedBox(height: 12),
              activitiesAsync.when(
                data: (activities) {
                  if (activities.isEmpty) {
                    return _buildEmptyState('No activities recorded for this client.');
                  }
                  return Column(
                    children: activities.map((activity) => _buildActivityCard(activity)).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildEmptyState('Error loading activities: $error'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Notes Tab
  Widget _buildNotesTab() {
    // Fetch shift notes from Convex in real-time
    return Consumer(
      builder: (context, ref, child) {
        final notesAsync = ref.watch(
          _shiftNotesListProvider(widget.client.id),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Shift Notes'),
              const SizedBox(height: 12),
              notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return _buildEmptyState('No shift notes recorded for this client.');
                  }
                  return Column(
                    children: notes.map((note) => _buildShiftNoteCard(note)).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildEmptyState('Error loading notes: $error'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Info Card Container
  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Info Row
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
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
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State Widget
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  /// Build goal card
  Widget _buildGoalCard(Goal goal) {
    Color statusColor;
    switch (goal.status) {
      case GoalStatus.achieved:
        statusColor = AppColors.success;
        break;
      case GoalStatus.inProgress:
        statusColor = AppColors.goldenAmber;
        break;
      case GoalStatus.notStarted:
        statusColor = AppColors.textSecondary;
        break;
      case GoalStatus.onHold:
      case GoalStatus.discontinued:
        statusColor = AppColors.error;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${goal.progressPercentage}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goal.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Target: ${goal.targetDate}',
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

  /// Build activity card
  Widget _buildActivityCard(Activity activity) {
    Color statusColor;
    switch (activity.status) {
      case ActivityStatus.completed:
        statusColor = AppColors.success;
        break;
      case ActivityStatus.inProgress:
        statusColor = AppColors.goldenAmber;
        break;
      case ActivityStatus.scheduled:
        statusColor = AppColors.deepBrown;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (activity.description != null) ...[
            const SizedBox(height: 8),
            Text(
              activity.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.event, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                _formatDate(activity.createdAt),
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

  /// Build shift note card
  Widget _buildShiftNoteCard(Map<String, dynamic> note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.deepBrown),
              const SizedBox(width: 8),
              Text(
                note['shift_date'] as String? ?? 'Unknown date',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${note['start_time']} - ${note['end_time']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (note['raw_notes'] != null) ...[
            const SizedBox(height: 8),
            Text(
              note['raw_notes'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Sticky Tab Bar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
