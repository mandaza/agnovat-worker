import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/activity.dart';

/// Activity card widget matching Figma design
/// Displays activity information with emojis and badges
class ActivityCard extends StatelessWidget {
  final Activity activity;
  final String? clientName;
  final String? goalDescription;
  final VoidCallback? onTap;
  final bool isCompleted;

  const ActivityCard({
    super.key,
    required this.activity,
    this.clientName,
    this.goalDescription,
    this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isCompleted ? 0.75 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Badges (Type and Status)
              Row(
                children: [
                  _buildBadge(
                    activity.activityType.displayName,
                    _getTypeColor(activity.activityType),
                    false,
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    activity.status.displayName,
                    _getStatusColor(activity.status),
                    true,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Details with emojis
              _buildDetailRow(
                '⏰',
                _formatDateTime(activity.createdAt),
              ),
              const SizedBox(height: 4),
              
              if (goalDescription != null)
                _buildDetailRow('🎯', goalDescription!),
              if (goalDescription != null)
                const SizedBox(height: 4),

              _buildDetailRow(
                '👤',
                clientName ?? 'No client assigned',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build badge widget
  Widget _buildBadge(String label, Color color, bool isStatus) {
    // Determine background and text colors based on type
    Color bgColor;
    Color textColor;

    if (isStatus) {
      // Status badges
      if (activity.status == ActivityStatus.completed) {
        bgColor = AppColors.deepBrown.withValues(alpha: 0.1);
        textColor = AppColors.deepBrown;
      } else if (activity.status == ActivityStatus.inProgress) {
        bgColor = AppColors.goldenAmber.withValues(alpha: 0.1);
        textColor = AppColors.goldenAmber;
      } else {
        // Scheduled or other statuses
        bgColor = AppColors.grey100;
        textColor = AppColors.textSecondary;
      }
    } else {
      // Activity type badges
      bgColor = color.withValues(alpha: 0.1);
      textColor = color;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Build detail row with emoji
  Widget _buildDetailRow(String emoji, String text) {
    return Text(
      '$emoji $text',
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  /// Format date time for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDay = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    final timeStr = DateFormat('h:mm a').format(dateTime);

    if (activityDay == today) {
      return timeStr;
    } else {
      return '${DateFormat('MMM d').format(dateTime)} • $timeStr';
    }
  }

  /// Get activity type color matching Figma design
  Color _getTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.communityAccess:
        return AppColors.goldenAmber; // Community Access - orange/amber
      case ActivityType.lifeSkills:
      case ActivityType.therapy:
        return AppColors.burntOrange; // Skills Development - burnt orange
      case ActivityType.socialRecreation:
      case ActivityType.personalCare:
        return AppColors.deepBrown; // Social Skills - deep brown
      case ActivityType.householdTasks:
        return AppColors.tealBlue; // Daily Living
      case ActivityType.employmentEducation:
        return AppColors.deepOcean;
      default:
        return AppColors.grey600;
    }
  }

  /// Get status color matching Figma design
  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return AppColors.deepBrown;
      case ActivityStatus.inProgress:
        return AppColors.goldenAmber;
      case ActivityStatus.scheduled:
        return AppColors.grey500;
      case ActivityStatus.cancelled:
        return AppColors.error;
      case ActivityStatus.noShow:
        return AppColors.warning;
    }
  }
}

