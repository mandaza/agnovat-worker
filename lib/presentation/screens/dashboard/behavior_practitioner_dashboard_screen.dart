import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/activity_session.dart';
import '../../../data/models/shift_note.dart';
import '../../../data/models/behavior_incident_review.dart';
import '../../../data/models/user.dart';
import '../../../core/providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/behavior_practitioner_provider.dart';
import '../../providers/behavior_incident_reviews_provider.dart';
import '../shift_notes/shift_note_details_screen.dart';
import '../shift_notes/behavior_practitioner_shift_notes_list_screen.dart';
import '../profile/profile_screen.dart';
import '../reviews/create_review_screen.dart';
import '../reviews/review_detail_screen.dart';
import '../behavior_incidents/behavior_incidents_list_screen.dart';
import '../behavior_incidents/unacknowledged_incidents_screen.dart';

/// Behavior Practitioner Dashboard Screen
/// Shows shift notes and behavior incidents submitted by support workers
class BehaviorPractitionerDashboardScreen extends ConsumerWidget {
  const BehaviorPractitionerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(behaviorPractitionerProvider);

    // Show loading while initializing auth
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
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

    // Show error if auth failed
    if (authState.error != null && !authState.isAuthenticated) {
      return Scaffold(
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
                Text(
                  'Authentication Error',
                  style: Theme.of(context).textTheme.titleLarge,
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

    // Debug: Check if user role is correct
    if (authState.user != null) {
      print('🔍 Behavior Practitioner Dashboard - User role: ${authState.user!.role.name}');
      if (authState.user!.role != UserRole.behaviorPractitioner) {
        print('⚠️ WARNING: User role is ${authState.user!.role.name}, expected behaviorPractitioner');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: dashboardState.error != null
          ? _buildError(context, ref, dashboardState.error!)
          : _buildDashboardContent(
              context,
              ref,
              dashboardState,
              authState.user?.name ?? 'User',
            ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    BehaviorPractitionerState state,
    String? userName,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(behaviorPractitionerProvider.notifier).refresh(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, userName),

            const SizedBox(height: 24),

            // Stats Cards - Show immediately even while loading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: state.isLoading && state.totalIncidentsCount == 0
                  ? _buildStatsGridSkeleton(context)
                  : _buildStatsGrid(context, state),
            ),

            const SizedBox(height: 32),

            // Recent Behavior Incidents
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: const Text(
                          'Recent Behavior Incidents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BehaviorIncidentsListScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.deepBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.isLoading && state.behaviorIncidents.isEmpty)
                    _buildIncidentsSkeleton(context)
                  else if (state.behaviorIncidents.isEmpty)
                    _buildEmptyIncidentsState(context)
                  else
                    _buildRecentIncidentsList(context, ref, state),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  /// Build skeleton loader for stats grid
  Widget _buildStatsGridSkeleton(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCardSkeleton()),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCardSkeleton()),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCardSkeleton()),
      ],
    );
  }

  /// Build skeleton loader for stat card
  Widget _buildStatCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// Build skeleton loader for incidents list
  Widget _buildIncidentsSkeleton(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Header with user details and profile avatar
  Widget _buildHeader(BuildContext context, String? userName) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agnovat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, ${userName?.split(' ').first ?? 'User'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.deepBrown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Behavior Practitioner',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // Notification Bell
                _buildNotificationBell(context),
                const SizedBox(width: 12),
                // Profile Avatar
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.deepBrown, AppColors.burntOrange],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Notification bell with unacknowledged incidents count badge
  Widget _buildNotificationBell(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final unacknowledgedCountAsync = ref.watch(unacknowledgedIncidentsCountProvider);

        return unacknowledgedCountAsync.when(
          data: (count) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UnacknowledgedIncidentsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.deepBrown,
                    size: 28,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => IconButton(
            onPressed: null,
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.deepBrown,
              size: 28,
            ),
          ),
          error: (_, __) => IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UnacknowledgedIncidentsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.deepBrown,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  /// Build stats grid
  Widget _buildStatsGrid(BuildContext context, BehaviorPractitionerState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Incidents',
            '${state.totalIncidentsCount}',
            Icons.warning_amber_rounded,
            AppColors.deepBrown,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'High Severity',
            '${state.highSeverityCount}',
            Icons.priority_high,
            AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Last 7 Days',
            '${state.recentIncidentsCount}',
            Icons.calendar_today,
            AppColors.burntOrange,
          ),
        ),
      ],
    );
  }

  /// Build stat card
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
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
          ),
        ],
      ),
    );
  }

  /// Build recent incidents list
  Widget _buildRecentIncidentsList(
    BuildContext context,
    WidgetRef ref,
    BehaviorPractitionerState state,
  ) {
    // Show most recent 10 incidents
    final recentIncidents = state.behaviorIncidents.take(10).toList();

    return Column(
      children: recentIncidents.map((item) {
        return _buildIncidentCard(context, ref, item);
      }).toList(),
    );
  }

  /// Build incident card
  Widget _buildIncidentCard(
    BuildContext context,
    WidgetRef ref,
    BehaviorIncidentWithContext item,
  ) {
    final incident = item.incident;
    final shiftNote = item.shiftNote;
    final severityColor = _getSeverityColor(incident.severity);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ShiftNoteDetailsScreen(shiftNoteId: shiftNote.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with date and severity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(shiftNote.shiftDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (item.clientName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.clientName!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Severity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    incident.severity.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Behaviors displayed
            if (incident.behaviorsDisplayed.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: incident.behaviorsDisplayed.take(3).map((behavior) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      behavior,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (incident.behaviorsDisplayed.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${incident.behaviorsDisplayed.length - 3} more',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
            // Description preview
            Text(
              incident.description.length > 100
                  ? '${incident.description.substring(0, 100)}...'
                  : incident.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Footer with worker and self-harm indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item.workerName != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.workerName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                if (incident.selfHarm)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Self-Harm',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Review Button - shows different text based on review status
            _buildReviewButton(context, ref, item, incident, shiftNote),
          ],
        ),
      ),
    );
  }

  /// Get severity color
  Color _getSeverityColor(BehaviorSeverity severity) {
    switch (severity) {
      case BehaviorSeverity.low:
        return AppColors.goldenAmber;
      case BehaviorSeverity.medium:
        return AppColors.burntOrange;
      case BehaviorSeverity.high:
        return AppColors.error;
    }
  }

  /// Format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Build review button that shows appropriate action based on review status
  Widget _buildReviewButton(
    BuildContext context,
    WidgetRef ref,
    BehaviorIncidentWithContext item,
    BehaviorIncident incident,
    ShiftNote shiftNote,
  ) {
    // Check if a review exists for this incident
    final reviewAsync = incident.convexId != null && incident.convexId!.isNotEmpty
        ? ref.watch(incidentReviewProvider(incident.convexId!))
        : null;

    return reviewAsync == null
        ? _buildReviewButtonWidget(
            context: context,
            label: 'Create Review',
            icon: Icons.rate_review,
            onTap: () => _handleReviewNavigation(context, ref, item, incident, shiftNote),
          )
        : reviewAsync.when(
            data: (review) {
              if (review == null) {
                return _buildReviewButtonWidget(
                  context: context,
                  label: 'Create Review',
                  icon: Icons.rate_review,
                  onTap: () => _handleReviewNavigation(context, ref, item, incident, shiftNote),
                );
              }

              // Show appropriate button based on review status
              if (review.isDraft) {
                return _buildReviewButtonWidget(
                  context: context,
                  label: 'Edit Draft Review',
                  icon: Icons.edit,
                  onTap: () => _handleReviewNavigation(context, ref, item, incident, shiftNote, review),
                  color: AppColors.burntOrange,
                );
              } else {
                return _buildReviewButtonWidget(
                  context: context,
                  label: 'View Review',
                  icon: Icons.visibility,
                  onTap: () => _handleReviewNavigation(context, ref, item, incident, shiftNote, review),
                  color: AppColors.deepBrown,
                );
              }
            },
            loading: () => _buildReviewButtonWidget(
              context: context,
              label: 'Loading...',
              icon: Icons.rate_review,
              onTap: null,
              isLoading: true,
            ),
            error: (_, __) => _buildReviewButtonWidget(
              context: context,
              label: 'Create Review',
              icon: Icons.rate_review,
              onTap: () => _handleReviewNavigation(context, ref, item, incident, shiftNote),
            ),
          );
  }

  /// Build review button widget
  Widget _buildReviewButtonWidget({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    Color? color,
    bool isLoading = false,
  }) {
    final buttonColor = color ?? AppColors.deepBrown;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepBrown),
                ),
              )
            : Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  /// Handle review navigation - routes to appropriate screen based on review status
  void _handleReviewNavigation(
    BuildContext context,
    WidgetRef ref,
    BehaviorIncidentWithContext item,
    BehaviorIncident incident,
    ShiftNote shiftNote, [
    BehaviorIncidentReview? review,
  ]) async {
    // First, try to fetch the convexId if missing
    String? convexId = incident.convexId;

    if (convexId == null || convexId.isEmpty) {
      // Try to fetch it
      try {
        final apiService = ref.read(mcpApiServiceProvider);
        final result = await apiService.getShiftNoteWithSessions(shiftNote.id);

        final sessionsList = result['activity_sessions'];
        if (sessionsList is List) {
          for (final sessionJson in sessionsList) {
            if (sessionJson is! Map<String, dynamic>) continue;
            try {
              final session = ActivitySession.fromJson(sessionJson);
              for (final incidentItem in session.behaviorIncidents) {
                if (incidentItem.id == incident.id) {
                  convexId = incidentItem.convexId;
                  break;
                }
              }
              if (convexId != null) break;
            } catch (e) {
              continue;
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching convexId: $e');
      }
    }

    if (convexId == null || convexId.isEmpty) {
      // No convexId available, show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This incident has not been synced yet. Please wait for the shift note to be fully synced.',
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // If review was passed, use it; otherwise fetch it
    BehaviorIncidentReview? existingReview = review;
    if (existingReview == null) {
      try {
        final reviewAsync = ref.read(incidentReviewProvider(convexId));
        final reviewData = await reviewAsync.when(
          data: (data) => Future.value(data),
          loading: () => Future.value(null),
          error: (_, __) => Future.value(null),
        );
        existingReview = reviewData;
      } catch (e) {
        debugPrint('Error fetching review: $e');
        existingReview = null;
      }
    }

    if (existingReview == null) {
      // No review exists - navigate to create screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreateReviewScreen(
            incident: incident,
            shiftNote: shiftNote,
            clientId: shiftNote.clientId,
            clientName: item.clientName,
          ),
        ),
      );
    } else if (existingReview.isDraft) {
      // Draft review exists - navigate to edit screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreateReviewScreen(
            incident: incident,
            shiftNote: shiftNote,
            clientId: shiftNote.clientId,
            clientName: item.clientName,
            existingReview: existingReview,
          ),
        ),
      );
    } else {
      // Submitted review exists - navigate to view screen
      // existingReview is guaranteed to be non-null here due to the if-else structure
      final reviewToView = existingReview;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReviewDetailScreen(
            reviewId: reviewToView.id,
            canAcknowledge: false, // Practitioners can't acknowledge their own reviews
          ),
        ),
      );
    }
  }

  /// Build empty incidents state
  Widget _buildEmptyIncidentsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No behavior incidents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'All clear! No behavior incidents have been reported recently.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
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
              'Error loading dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(behaviorPractitionerProvider.notifier).refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBrown,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build bottom navigation
  Widget _buildBottomNavigation(BuildContext context) {
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
        currentIndex: 0, // Dashboard tab
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on Dashboard
              break;
            case 1:
              // Behavior Incidents
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const BehaviorIncidentsListScreen(),
                ),
              );
              break;
            case 2:
              // Shift Notes
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const BehaviorPractitionerShiftNotesListScreen(),
                ),
              );
              break;
          }
        },
        selectedItemColor: AppColors.deepBrown,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Incidents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Shift Notes',
          ),
        ],
      ),
    );
  }
}

