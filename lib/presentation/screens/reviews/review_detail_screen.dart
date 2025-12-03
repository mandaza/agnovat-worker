import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/behavior_incident_review.dart';
import '../../../data/services/providers.dart';
import '../../providers/behavior_incident_reviews_provider.dart';
import '../../providers/auth_provider.dart';

/// Screen for viewing review details
/// Support workers can acknowledge reviews here
class ReviewDetailScreen extends ConsumerStatefulWidget {
  final String reviewId;
  final bool canAcknowledge;

  const ReviewDetailScreen({
    super.key,
    required this.reviewId,
    this.canAcknowledge = false,
  });

  @override
  ConsumerState<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends ConsumerState<ReviewDetailScreen> {
  bool _isAcknowledging = false;

  Future<void> _acknowledgeReview(BehaviorIncidentReview review) async {
    if (!widget.canAcknowledge || review.isAcknowledged) {
      return;
    }

    setState(() {
      _isAcknowledging = true;
    });

    try {
      final authState = ref.read(authProvider);
      final clerkId = authState.user?.clerkId;

      if (clerkId == null) {
        throw Exception('User not authenticated - Clerk ID not found');
      }

      await ref
          .read(behaviorIncidentReviewsProvider.notifier)
          .acknowledgeReview(widget.reviewId, clerkId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review acknowledged'),
          backgroundColor: AppColors.deepBrown,
        ),
      );

      // Refresh the unacknowledged reviews list
      ref.refresh(unacknowledgedReviewsProvider);

      // Go back
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error acknowledging review: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAcknowledging = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Review Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<BehaviorIncidentReview>(
        future: ref.read(behaviorIncidentReviewsServiceProvider).getReview(widget.reviewId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Review not found'));
          }

          final review = snapshot.data!;
          return _buildContent(review);
        },
        ),
      ),
    );
  }

  Widget _buildContent(BehaviorIncidentReview review) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(review),

          const SizedBox(height: 16),

          // Comments Section
          _buildSection(
            'Comments',
            review.comments,
            Icons.comment_outlined,
          ),

          const SizedBox(height: 16),

          // Recommendations Section
          _buildSection(
            'Recommendations',
            review.recommendations,
            Icons.lightbulb_outline,
          ),

          const SizedBox(height: 16),

          // Follow-up Section
          if (review.followUpRequired) ...[
            _buildFollowUpSection(review),
            const SizedBox(height: 16),
          ],

          // Acknowledgment Section
          if (review.isAcknowledged)
            _buildAcknowledgmentInfo(review)
          else if (widget.canAcknowledge)
            _buildAcknowledgeButton(review),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BehaviorIncidentReview review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: review.isCritical ? AppColors.error : AppColors.borderLight,
          width: review.isCritical ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSeverityColor(review.severityAssessment).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSeverityIcon(review.severityAssessment),
                  color: _getSeverityColor(review.severityAssessment),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reviewed ${_formatDate(review.createdAt)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge(
                review.severityAssessment.displayName,
                _getSeverityColor(review.severityAssessment),
              ),
              const SizedBox(width: 8),
              _buildBadge(
                review.status.displayName,
                AppColors.deepBrown,
              ),
            ],
          ),
          if (review.isCritical) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.notification_important,
                    color: AppColors.error,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CRITICAL: Requires immediate attention',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
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
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.deepBrown),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpSection(BehaviorIncidentReview review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.burntOrange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.burntOrange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag, size: 20, color: AppColors.burntOrange),
              SizedBox(width: 8),
              Text(
                'Follow-up Required',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.burntOrange,
                ),
              ),
            ],
          ),
          if (review.followUpNotes != null) ...[
            const SizedBox(height: 12),
            Text(
              review.followUpNotes!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcknowledgmentInfo(BehaviorIncidentReview review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepBrown.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepBrown.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.deepBrown, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acknowledged',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepBrown,
                  ),
                ),
                if (review.acknowledgedByName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'By ${review.acknowledgedByName} on ${_formatDate(review.acknowledgedAt!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgeButton(BehaviorIncidentReview review) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isAcknowledging ? null : () => _acknowledgeReview(review),
        icon: _isAcknowledging
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: const Text(
          'Mark as Read',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildError(String error) {
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
              'Error loading review',
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
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(date);
  }

  IconData _getSeverityIcon(SeverityAssessment severity) {
    switch (severity) {
      case SeverityAssessment.low:
        return Icons.info_outline;
      case SeverityAssessment.medium:
        return Icons.warning_amber_outlined;
      case SeverityAssessment.high:
        return Icons.error_outline;
      case SeverityAssessment.critical:
        return Icons.notification_important;
    }
  }

  Color _getSeverityColor(SeverityAssessment severity) {
    switch (severity) {
      case SeverityAssessment.low:
        return AppColors.goldenAmber;
      case SeverityAssessment.medium:
        return AppColors.burntOrange;
      case SeverityAssessment.high:
        return AppColors.error;
      case SeverityAssessment.critical:
        return const Color(0xFF8B0000); // Dark red
    }
  }
}
