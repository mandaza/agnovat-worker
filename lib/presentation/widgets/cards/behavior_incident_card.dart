import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/activity_session.dart';
import '../../providers/behavior_practitioner_provider.dart';
import '../../providers/behavior_incident_reviews_provider.dart';

/// Behavior Incident card widget matching app design system
class BehaviorIncidentCard extends ConsumerWidget {
  final BehaviorIncidentWithContext item;
  final VoidCallback? onTap;
  final VoidCallback? onReviewTap;

  const BehaviorIncidentCard({
    super.key,
    required this.item,
    this.onTap,
    this.onReviewTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incident = item.incident;
    final severityColor = _getSeverityColor(incident.severity);
    
    // Check if a review exists for this incident
    final reviewAsync = incident.convexId != null && incident.convexId!.isNotEmpty
        ? ref.watch(incidentReviewProvider(incident.convexId!))
        : null;

    return InkWell(
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
            // Date heading
            Text(
              _formatDate(item.shiftNote.shiftDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Description preview
            if (incident.description.isNotEmpty)
              Text(
                incident.description.length > 80
                    ? '${incident.description.substring(0, 80)}...'
                    : incident.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 12),

            // Badges row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Severity badge
                _buildSeverityBadge(incident.severity, severityColor),
                // Client badge
                if (item.clientName != null)
                  _buildClientBadge(item.clientName!),
                // Self-harm badge
                if (incident.selfHarm)
                  _buildSelfHarmBadge(),
                // Behaviors badge (count)
                if (incident.behaviorsDisplayed.isNotEmpty)
                  _buildBehaviorsBadge(incident.behaviorsDisplayed.length),
              ],
            ),

            // Review button - shows different text based on review status
            if (onReviewTap != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              reviewAsync == null
                  ? _buildReviewButton(
                      context: context,
                      label: 'Create Review',
                      icon: Icons.rate_review,
                      onTap: onReviewTap,
                    )
                  : reviewAsync.when(
                      data: (review) {
                        if (review == null) {
                          return _buildReviewButton(
                            context: context,
                            label: 'Create Review',
                            icon: Icons.rate_review,
                            onTap: onReviewTap,
                          );
                        }
                        
                        // Show appropriate button based on review status
                        if (review.isDraft) {
                          return _buildReviewButton(
                            context: context,
                            label: 'Edit Draft Review',
                            icon: Icons.edit,
                            onTap: onReviewTap,
                            color: AppColors.burntOrange,
                          );
                        } else if (review.isSubmitted) {
                          return _buildReviewButton(
                            context: context,
                            label: 'View Review',
                            icon: Icons.visibility,
                            onTap: onReviewTap,
                            color: AppColors.deepBrown,
                          );
                        } else {
                          return _buildReviewButton(
                            context: context,
                            label: 'View Review',
                            icon: Icons.visibility,
                            onTap: onReviewTap,
                            color: AppColors.deepBrown,
                          );
                        }
                      },
                      loading: () => _buildReviewButton(
                        context: context,
                        label: 'Loading...',
                        icon: Icons.rate_review,
                        onTap: null,
                        isLoading: true,
                      ),
                      error: (_, __) => _buildReviewButton(
                        context: context,
                        label: 'Create Review',
                        icon: Icons.rate_review,
                        onTap: onReviewTap,
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build severity badge
  Widget _buildSeverityBadge(BehaviorSeverity severity, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        severity.name.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Build client badge
  Widget _buildClientBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Build self-harm badge
  Widget _buildSelfHarmBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.warning_amber_rounded,
            size: 12,
            color: AppColors.error,
          ),
          SizedBox(width: 4),
          Text(
            'Self-Harm',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Build behaviors count badge
  Widget _buildBehaviorsBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.deepBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count ${count == 1 ? 'Behavior' : 'Behaviors'}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.deepBrown,
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

  /// Format date for display
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Build review button with customizable label and icon
  Widget _buildReviewButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    Color? color,
    bool isLoading = false,
  }) {
    final buttonColor = color ?? AppColors.deepBrown;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepBrown),
                ),
              )
            else
              Icon(
                icon,
                size: 16,
                color: buttonColor,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
