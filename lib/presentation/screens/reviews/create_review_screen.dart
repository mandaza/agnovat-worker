import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/behavior_incident_review.dart';
import '../../../data/models/activity_session.dart';
import '../../../data/models/shift_note.dart';
import '../../providers/behavior_incident_reviews_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';

/// Screen for creating or editing a behavior incident review
/// Used by behavior practitioners to review incidents
class CreateReviewScreen extends ConsumerStatefulWidget {
  final BehaviorIncident incident;
  final ShiftNote shiftNote;
  final String? clientId;
  final String? clientName;
  final BehaviorIncidentReview? existingReview; // For editing existing reviews

  const CreateReviewScreen({
    super.key,
    required this.incident,
    required this.shiftNote,
    this.clientId,
    this.clientName,
    this.existingReview,
  });

  @override
  ConsumerState<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends ConsumerState<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _followUpNotesController = TextEditingController();

  SeverityAssessment _severity = SeverityAssessment.medium;
  bool _followUpRequired = false;
  bool _isSubmitting = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // If editing an existing review, populate the form
    if (widget.existingReview != null) {
      _isEditing = true;
      final review = widget.existingReview!;
      _commentsController.text = review.comments;
      _recommendationsController.text = review.recommendations;
      _severity = review.severityAssessment;
      _followUpRequired = review.followUpRequired;
      if (review.followUpNotes != null) {
        _followUpNotesController.text = review.followUpNotes!;
      }
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _recommendationsController.dispose();
    _followUpNotesController.dispose();
    super.dispose();
  }

  /// Try to fetch the convexId for the incident by refreshing shift note data
  Future<String?> _fetchConvexId() async {
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final result = await apiService.getShiftNoteWithSessions(widget.shiftNote.id);
      
      final sessionsList = result['activity_sessions'];
      if (sessionsList is! List) {
        debugPrint('⚠️ No activity sessions found in shift note response');
        return null;
      }
      
      debugPrint('🔍 Searching for incident ${widget.incident.id} in ${sessionsList.length} sessions...');
      debugPrint('   📍 Called from: CreateReviewScreen._fetchConvexId()');
      debugPrint('   📋 Shift Note ID: ${widget.shiftNote.id}');
      
      bool incidentFound = false;
      
      // Search through all sessions to find the incident with matching UUID
      for (final sessionJson in sessionsList) {
        if (sessionJson is! Map<String, dynamic>) continue;
        
        try {
          final session = ActivitySession.fromJson(sessionJson);
          
          // Find the incident with matching UUID
          for (final incident in session.behaviorIncidents) {
            if (incident.id == widget.incident.id) {
              incidentFound = true;
              // Found the incident
              debugPrint('✅ Found incident ${incident.id} in session ${session.id}');
              debugPrint('   📊 Incident convexId: ${incident.convexId ?? "null"}');
              
              if (incident.convexId != null && incident.convexId!.isNotEmpty) {
                debugPrint('   ✅ convexId found, returning: ${incident.convexId}');
                return incident.convexId;
              } else {
                debugPrint('   ⚠️ Incident found but convexId is null/empty');
                debugPrint('   📋 This means:');
                debugPrint('      - Shift note may not be submitted yet');
                debugPrint('      - Incident may not have been extracted to behavior_incidents table yet');
                debugPrint('      - Incident extraction may have failed');
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing session: $e');
          continue;
        }
      }
      
      if (incidentFound) {
        debugPrint('❌ Incident ${widget.incident.id} was found but has no convexId');
        debugPrint('   📋 According to FRONTEND_REVIEW_GUIDE.md, convex_id is null when:');
        debugPrint('      - Shift note hasn\'t been submitted yet');
        debugPrint('      - Incident hasn\'t been extracted to behavior_incidents table yet');
        debugPrint('      - Incident doesn\'t exist in behavior_incidents table');
        debugPrint('   ✅ Solution: Ensure the shift note is submitted and incident is extracted');
      } else {
        debugPrint('❌ Incident ${widget.incident.id} not found in any session');
        debugPrint('   📋 This incident may not belong to this shift note');
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching convexId: $e');
      return null;
    }
  }

  Future<void> _saveReview({bool submit = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get or fetch the Convex ID
    String? convexId = widget.incident.convexId;
    
    // If convexId is missing, try to fetch it from the backend
    if (convexId == null || convexId.isEmpty) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        convexId = await _fetchConvexId();
      } catch (e) {
        debugPrint('Error fetching convexId: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
      
      // If still no convexId, show error with helpful guidance
      if (convexId == null || convexId.isEmpty) {
        if (mounted) {
          // Check if shift note is submitted
          final isSubmitted = widget.shiftNote.isSubmitted;
          
          final errorMessage = isSubmitted
              ? 'This incident has not been extracted yet. '
                'The shift note is submitted, but the incident needs to be processed. '
                'Please wait a moment and try again, or contact support if the issue persists.'
              : 'This incident cannot be reviewed yet because the shift note has not been submitted. '
                'Please submit the shift note first. Once submitted, the incident will be extracted '
                'and available for review.';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 7),
            ),
          );
        }
        return;
      }
    }

    // At this point, convexId is guaranteed to be non-null and non-empty
    // Flow analysis ensures convexId is non-null after the check above
    final finalConvexId = convexId;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      final userName = authState.user?.name ?? 'Unknown';

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if we're editing an existing review
      if (_isEditing && widget.existingReview != null) {
        // Update existing review content
        // Note: updated_at is automatically set by the backend - do not include it
        final updates = {
          'comments': _commentsController.text.trim(),
          'recommendations': _recommendationsController.text.trim(),
          'severity_assessment': _severity.name,
          'follow_up_required': _followUpRequired,
          'follow_up_notes': _followUpNotesController.text.trim(), // Send empty string instead of null
        };

        // If submitting, update content first, then submit using the dedicated submit mutation
        if (submit) {
          debugPrint('📝 Updating review content before submission...');
          // First update the review content
          await ref
              .read(behaviorIncidentReviewsProvider.notifier)
              .updateReview(widget.existingReview!.id, updates);
          
          debugPrint('✅ Review content updated, now submitting...');
          // Then submit the review using the dedicated submit mutation
          await ref
              .read(behaviorIncidentReviewsProvider.notifier)
              .submitReview(widget.existingReview!.id);
          debugPrint('✅ Review submitted successfully');
        } else {
          debugPrint('📝 Updating review as draft...');
          // Just update as draft
          await ref
              .read(behaviorIncidentReviewsProvider.notifier)
              .updateReview(widget.existingReview!.id, updates);
          debugPrint('✅ Review updated as draft');
        }

        // Invalidate the incident review provider to refresh the UI
        if (finalConvexId.isNotEmpty) {
          debugPrint('🔄 Invalidating incident review provider for convexId: $finalConvexId');
          ref.invalidate(incidentReviewProvider(finalConvexId));
        }

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              submit
                  ? 'Review updated and submitted successfully'
                  : 'Review updated and saved as draft',
            ),
            backgroundColor: AppColors.deepBrown,
          ),
        );

        // Return to previous screen
        Navigator.pop(context, widget.existingReview);
        return;
      }

      // Create new review object using Convex ID
      final review = BehaviorIncidentReview(
        id: '', // Will be set by backend
        behaviorIncidentId: finalConvexId, // Use Convex ID, not UUID
        clientId: widget.clientId ?? widget.shiftNote.clientId,
        reviewerId: userId,
        reviewerName: userName,
        comments: _commentsController.text.trim(),
        recommendations: _recommendationsController.text.trim(),
        severityAssessment: _severity,
        followUpRequired: _followUpRequired,
        followUpNotes: _followUpNotesController.text.trim().isNotEmpty
            ? _followUpNotesController.text.trim()
            : null,
        status: submit ? ReviewStatus.submitted : ReviewStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to backend
      final createdReview = await ref
          .read(behaviorIncidentReviewsProvider.notifier)
          .addReview(review);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            submit
                ? 'Review submitted successfully'
                : 'Review saved as draft',
          ),
          backgroundColor: AppColors.deepBrown,
        ),
      );

      // Return to previous screen
      Navigator.pop(context, createdReview);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving review: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
        title: Text(
          _isEditing ? 'Edit Review' : 'Create Review',
          style: const TextStyle(
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
        child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Incident Summary Card
              _buildIncidentSummary(),

              const SizedBox(height: 24),

              // Comments Section
              _buildSectionTitle('Comments'),
              const SizedBox(height: 8),
              _buildCommentsField(),

              const SizedBox(height: 24),

              // Recommendations Section
              _buildSectionTitle('Recommendations'),
              const SizedBox(height: 8),
              _buildRecommendationsField(),

              const SizedBox(height: 24),

              // Severity Assessment
              _buildSectionTitle('Severity Assessment'),
              const SizedBox(height: 8),
              _buildSeveritySelector(),

              const SizedBox(height: 24),

              // Follow-up Required
              _buildFollowUpToggle(),

              if (_followUpRequired) ...[
                const SizedBox(height: 16),
                _buildFollowUpNotesField(),
              ],

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),

              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildIncidentSummary() {
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
              const Icon(Icons.info_outline, size: 20, color: AppColors.deepBrown),
              const SizedBox(width: 8),
              const Text(
                'Incident Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.clientName != null) ...[
            _buildInfoRow('Client', widget.clientName!),
            const SizedBox(height: 8),
          ],
          _buildInfoRow('Date', widget.shiftNote.shiftDate),
          const SizedBox(height: 8),
          _buildInfoRow('Severity', widget.incident.severity.displayName),
          const SizedBox(height: 8),
          if (widget.incident.behaviorsDisplayed.isNotEmpty) ...[
            _buildInfoRow('Behaviors', widget.incident.behaviorsDisplayed.join(', ')),
            const SizedBox(height: 8),
          ],
          // Behavior Description
          if (widget.incident.description.isNotEmpty) ...[
            const Divider(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.incident.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCommentsField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextFormField(
        controller: _commentsController,
        maxLines: 6,
        decoration: const InputDecoration(
          hintText: 'Provide your professional assessment of the incident...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Comments are required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRecommendationsField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextFormField(
        controller: _recommendationsController,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'List your recommendations for handling similar situations...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Recommendations are required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSeveritySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<SeverityAssessment>(
        value: _severity,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: SeverityAssessment.values.map((severity) {
          return DropdownMenuItem(
            value: severity,
            child: Row(
              children: [
                Icon(
                  _getSeverityIcon(severity),
                  color: _getSeverityColor(severity),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  severity.displayName,
                  style: TextStyle(
                    color: _getSeverityColor(severity),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _severity = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildFollowUpToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: CheckboxListTile(
        title: const Text(
          'Follow-up Required',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text(
          'Check if this incident requires additional action',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        value: _followUpRequired,
        onChanged: (value) {
          setState(() {
            _followUpRequired = value ?? false;
          });
        },
        activeColor: AppColors.deepBrown,
      ),
    );
  }

  Widget _buildFollowUpNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextFormField(
        controller: _followUpNotesController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Describe the follow-up actions needed...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _saveReview(submit: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepBrown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _isEditing ? 'Update & Submit' : 'Submit Review',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Save as Draft Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => _saveReview(submit: false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepBrown,
              side: const BorderSide(color: AppColors.deepBrown),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isEditing ? 'Update Draft' : 'Save as Draft',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
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
        return Icons.notification_important_outlined;
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
