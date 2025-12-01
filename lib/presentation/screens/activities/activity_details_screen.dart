import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../data/models/activity.dart';
import '../../providers/dashboard_provider.dart';
import '../shift_notes/unified_shift_note_wizard.dart';

/// Activity Details Screen
/// Displays detailed information about a specific activity
class ActivityDetailsScreen extends ConsumerStatefulWidget {
  final Activity activity;

  const ActivityDetailsScreen({
    super.key,
    required this.activity,
  });

  @override
  ConsumerState<ActivityDetailsScreen> createState() =>
      _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState
    extends ConsumerState<ActivityDetailsScreen> {
  late Activity _activity;

  @override
  void initState() {
    super.initState();
    _activity = widget.activity;
  }

  @override
  Widget build(BuildContext context) {
    // Get client name from dashboard provider
    final dashboardState = ref.watch(dashboardProvider);
    String clientName = 'Unknown Client';

    try {
      final client = dashboardState.assignedClients.firstWhere(
        (c) => c.id == _activity.clientId,
      );
      clientName = client.name;
    } catch (e) {
      // Client not found, use default name or first available
      if (dashboardState.assignedClients.isNotEmpty) {
        clientName = dashboardState.assignedClients.first.name;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildActivityHeader(context),
            const SizedBox(height: 24),
            _buildActivityInfoCard(context, clientName),
            const SizedBox(height: 24),
            _buildActivityDescriptionCard(context),
            if (_activity.description != null && _activity.description!.isNotEmpty)
              const SizedBox(height: 24),
            _buildOutcomeNotesCard(context),
            if (_activity.outcomeNotes != null && _activity.outcomeNotes!.isNotEmpty)
              const SizedBox(height: 24),
            _buildActionButtons(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 24),
        child: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: const Text(
        'Activity Details',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  /// Build activity header with title and badges
  Widget _buildActivityHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _activity.title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildBadge(
                _activity.activityType.displayName,
                _getActivityTypeColor(_activity.activityType),
              ),
              const SizedBox(width: 8),
              _buildBadge(
                _activity.status.displayName,
                _getActivityTypeColor(_activity.activityType),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build badge widget
  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Build activity info card
  Widget _buildActivityInfoCard(BuildContext context, String clientName) {
    // Format created date
    final createdDate = DateFormat('MMM d, yyyy').format(_activity.createdAt);
    final createdTime = DateFormat('h:mm a').format(_activity.createdAt);

    // Format updated date
    final updatedDate = DateFormat('MMM d, yyyy').format(_activity.updatedAt);
    final updatedTime = DateFormat('h:mm a').format(_activity.updatedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.person_outline,
              iconColor: const Color(0xFF5A3111),
              iconBackgroundColor: const Color(0xFF5A3111).withOpacity(0.1),
              label: 'Client',
              value: clientName,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              iconColor: const Color(0xFFD68630),
              iconBackgroundColor: const Color(0xFFD68630).withOpacity(0.1),
              label: 'Created',
              value: createdDate,
              subtitle: 'at $createdTime',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.update,
              iconColor: const Color(0xFF954406),
              iconBackgroundColor: const Color(0xFF954406).withOpacity(0.1),
              label: 'Last Updated',
              value: updatedDate,
              subtitle: 'at $updatedTime',
            ),
            if (_activity.goalIds != null && _activity.goalIds!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.flag_outlined,
                iconColor: const Color(0xFF5A3111),
                iconBackgroundColor: const Color(0xFF5A3111).withOpacity(0.1),
                label: 'Linked Goals',
                value: '${_activity.goalIds!.length} goal${_activity.goalIds!.length > 1 ? 's' : ''} linked',
                subtitle: _activity.goalIds!.take(2).join(', ') +
                         (_activity.goalIds!.length > 2 ? '...' : ''),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build info row with icon
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.33,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.43,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build activity description card
  Widget _buildActivityDescriptionCard(BuildContext context) {
    // Only show if description exists
    if (_activity.description == null || _activity.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Description',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _activity.description!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.625,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build outcome notes card (only if outcome notes exist)
  Widget _buildOutcomeNotesCard(BuildContext context) {
    // Only show if outcome notes exist
    if (_activity.outcomeNotes == null || _activity.outcomeNotes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A3111).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.note_outlined,
                    color: Color(0xFF5A3111),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Outcome Notes',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _activity.outcomeNotes!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.625,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Build action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Show different buttons based on activity status
          if (_activity.status == ActivityStatus.scheduled) ...[
            // Start Activity button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _markAsInProgress(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A3111),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Start Activity',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else if (_activity.status == ActivityStatus.inProgress) ...[
            // Complete Activity button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _completeActivityAndCreateShiftNote(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A3111),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Complete Activity & Create Shift Note',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else if (_activity.status == ActivityStatus.completed) ...[
            // View Shift Notes button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _viewShiftNotes(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A3111),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'View Shift Notes',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Complete activity and navigate to create shift note
  Future<void> _completeActivityAndCreateShiftNote(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Update activity status to completed
      final apiService = ref.read(mcpApiServiceProvider);
      final updatedActivity = await apiService.updateActivity(
        activityId: _activity.id,
        status: ActivityStatus.completed,
      );

      setState(() {
        _activity = updatedActivity;
      });

      // Close loading
      if (context.mounted) Navigator.of(context).pop();

      // Navigate to create shift note
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const UnifiedShiftNoteWizard(),
          ),
        );
      }

      // Refresh dashboard to update activities list
      ref.invalidate(dashboardDataProvider);
    } catch (e) {
      // Close loading
      if (context.mounted) Navigator.of(context).pop();

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete activity: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Mark activity as in progress
  Future<void> _markAsInProgress(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Update activity status via API
      final apiService = ref.read(mcpApiServiceProvider);
      final updatedActivity = await apiService.updateActivity(
        activityId: _activity.id,
        status: ActivityStatus.inProgress,
      );

      setState(() {
        _activity = updatedActivity;
      });

      // Close loading
      if (context.mounted) Navigator.of(context).pop();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity started'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Refresh dashboard to update activities list
      ref.invalidate(dashboardDataProvider);
    } catch (e) {
      // Close loading
      if (context.mounted) Navigator.of(context).pop();

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start activity: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// View shift notes for this activity
  void _viewShiftNotes(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shift notes feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Get activity type color
  Color _getActivityTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.communityAccess:
        return AppColors.goldenAmber;
      case ActivityType.lifeSkills:
      case ActivityType.therapy:
        return AppColors.burntOrange;
      case ActivityType.socialRecreation:
      case ActivityType.personalCare:
        return AppColors.deepBrown;
      case ActivityType.householdTasks:
        return AppColors.tealBlue;
      case ActivityType.employmentEducation:
        return AppColors.deepOcean;
      default:
        return AppColors.grey600;
    }
  }
}
