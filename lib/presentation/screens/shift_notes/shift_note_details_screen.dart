import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../data/models/shift_note.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/shift_notes_provider.dart';
import 'create_shift_note_screen.dart';
import 'ai_formatting_screen.dart';

/// Shift Note Details Screen
/// Displays detailed information about a specific shift note matching Figma design
class ShiftNoteDetailsScreen extends ConsumerWidget {
  final ShiftNote shiftNote;

  const ShiftNoteDetailsScreen({
    super.key,
    required this.shiftNote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDraft = shiftNote.isDraft;
    
    // Get client name from dashboard provider
    final dashboardState = ref.watch(dashboardProvider);
    String clientName = 'Unknown Client';
    
    try {
      final client = dashboardState.assignedClients.firstWhere(
        (c) => c.id == shiftNote.clientId,
      );
      clientName = client.name;
    } catch (e) {
      // Client not found, use default name
      if (dashboardState.assignedClients.isNotEmpty) {
        clientName = dashboardState.assignedClients.first.name;
      }
    }
    
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context, isDraft),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildShiftInfoCard(context, clientName),
            const SizedBox(height: 24),
            if (!isDraft) ...[
              _buildSessionActivitiesSection(context),
              const SizedBox(height: 24),
              _buildBehavioursEngagementSection(context),
              const SizedBox(height: 24),
              _buildGoalProgressSection(context),
              const SizedBox(height: 24),
              _buildSessionSummarySection(context),
              const SizedBox(height: 24),
            ] else ...[
              _buildRawNotesSection(context),
              const SizedBox(height: 24),
            ],
            _buildSubmittedBySection(context, ref),
            const SizedBox(height: 24),
            if (isDraft)
              _buildDraftActions(context)
            else
              _buildShareButton(context, clientName),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDraft) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
        ),
      ),
      title: const Text(
        'Shift Note',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        if (isDraft)
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textPrimary),
            onPressed: () => _editNote(context),
            tooltip: 'Edit Note',
          ),
        Container(
          margin: EdgeInsets.only(right: 24, left: isDraft ? 0 : 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDraft 
                ? AppColors.goldenAmber.withOpacity(0.1)
                : const Color(0xFF5A3111).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isDraft ? 'Draft' : 'Submitted',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDraft ? AppColors.goldenAmber : const Color(0xFF5A3111),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShiftInfoCard(BuildContext context, String clientName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('MMMM d, yyyy').format(DateTime.parse(shiftNote.shiftDate))} - ${_getShiftTypeName()} Shift',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.person,
              iconColor: const Color(0xFF5A3111).withOpacity(0.1),
              label: 'Client',
              value: clientName,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.access_time,
              iconColor: const Color(0xFFD68630).withOpacity(0.1),
              label: 'Duration',
              value: '${_formatTime(shiftNote.startTime)} - ${_formatTime(shiftNote.endTime)} (${_calculateDuration(shiftNote.startTime, shiftNote.endTime)})',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.location_on,
              iconColor: const Color(0xFF954406).withOpacity(0.1),
              label: 'Location',
              value: shiftNote.primaryLocations?.join(', ') ?? 'No location specified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 20,
          ),
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
                  color: AppColors.textSecondary,
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRawNotesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(16),
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
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Center(
                    child: Text(
                      '📝',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Raw Notes',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              shiftNote.rawNotes,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionActivitiesSection(BuildContext context) {
    final extractedSection = _extractSection(shiftNote.formattedNote, '🌅 Session Activities');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(16),
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
                  child: const Center(
                    child: Text(
                      '🌅',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Session Activities',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              extractedSection ?? shiftNote.rawNotes,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehavioursEngagementSection(BuildContext context) {
    final extractedSection = _extractSection(shiftNote.formattedNote, '😊 Behaviours & Engagement');

    // If formatted note doesn't have this section, don't show this widget at all
    if (extractedSection == null && shiftNote.formattedNote == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(16),
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
                    color: const Color(0xFFD68630).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Center(
                    child: Text(
                      '😊',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Behaviours & Engagement',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              extractedSection!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressSection(BuildContext context) {
    final extractedSection = _extractSection(shiftNote.formattedNote, '🎯 Goal Progress');

    // If no goals progress AND no formatted section AND no formatted note, don't show this widget
    if ((shiftNote.goalsProgress == null || shiftNote.goalsProgress!.isEmpty) &&
        extractedSection == null &&
        shiftNote.formattedNote == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(16),
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
                    Icons.track_changes,
                    color: AppColors.textPrimary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Goal Progress',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (shiftNote.goalsProgress != null && shiftNote.goalsProgress!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    shiftNote.goalsProgress!.first.goalId,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '+${shiftNote.goalsProgress!.first.progressObserved}%',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: shiftNote.goalsProgress!.first.progressObserved / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF5A3111),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                shiftNote.goalsProgress!.first.progressNotes,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ] else if (extractedSection != null) ...[
              const Text(
                'Independent Living Skills',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                extractedSection,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSummarySection(BuildContext context) {
    final extractedSection = _extractSection(shiftNote.formattedNote, '📋 Session Summary');

    // If formatted note doesn't have this section, don't show this widget at all
    if (extractedSection == null && shiftNote.formattedNote == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(16),
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
                    color: const Color(0xFF954406).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Center(
                    child: Text(
                      '📋',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Session Summary',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              extractedSection!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittedBySection(BuildContext context, WidgetRef ref) {
    // Get the current user's name from auth provider
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Unknown User';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submitted by',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('MMM d, yyyy').format(shiftNote.createdAt)} at ${DateFormat('h:mm a').format(shiftNote.createdAt)}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Edit Note button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _editNote(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Note',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Format with AI button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer(
              builder: (context, ref, child) => ElevatedButton(
                onPressed: () async {
                  // Navigate to AI formatting screen
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (context) => AiFormattingScreen(
                        shiftNoteId: shiftNote.id,
                        originalNotes: shiftNote.rawNotes,
                        formattedNotes: shiftNote.formattedNote,
                      ),
                    ),
                  );

                  // If user chose to use formatted version, update the shift note
                  if (result != null && context.mounted) {
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    try {
                      // Save formatted shift note
                      final apiService = ref.read(mcpApiServiceProvider);
                      await apiService.saveFormattedShiftNote(
                        shiftNoteId: shiftNote.id,
                        formattedNote: result,
                      );

                      // Refresh the shift notes list
                      await ref.read(shiftNotesProvider.notifier).refresh();

                      // Close loading
                      if (context.mounted) Navigator.of(context).pop();

                      // Close details screen
                      if (context.mounted) Navigator.of(context).pop();

                      // Show success
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Shift note formatted successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      // Close loading
                      if (context.mounted) Navigator.of(context).pop();

                      // Show error
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to save: ${e.toString()}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A3111),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Format with AI',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Submit Note button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer(
              builder: (context, ref, child) => ElevatedButton(
                onPressed: () {
                  _submitNote(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Submit Note',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Delete Draft button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer(
              builder: (context, ref, child) => OutlinedButton(
                onPressed: () {
                  _showDeleteConfirmation(context, ref);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Delete Draft',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, String clientName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: () => _shareShiftNote(context, clientName),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(
              color: Colors.black.withOpacity(0.1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share,
                size: 16,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Share Shift Note',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitNote(BuildContext context, WidgetRef ref) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Submit the shift note
      await ref.read(shiftNotesProvider.notifier).submitShiftNote(shiftNote.id);

      // Close loading indicator
      if (context.mounted) Navigator.of(context).pop();

      // Close details screen
      if (context.mounted) Navigator.of(context).pop();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shift note submitted successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading indicator
      if (context.mounted) Navigator.of(context).pop();

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit note: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Delete Draft',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this draft? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'Nunito',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // Close dialog

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Actually delete from backend
                await ref.read(shiftNotesProvider.notifier).deleteShiftNote(shiftNote.id);

                // Close loading indicator
                if (context.mounted) Navigator.of(context).pop();

                // Close details screen
                if (context.mounted) Navigator.of(context).pop();

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Draft deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                // Close loading indicator
                if (context.mounted) Navigator.of(context).pop();

                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete draft: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editNote(BuildContext context) {
    // Navigate to create/edit shift note screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateShiftNoteScreen(
          shiftNote: shiftNote,
        ),
      ),
    ).then((updated) {
      // If the note was updated, refresh the list and go back
      if (updated == true) {
        Navigator.of(context).pop(); // Go back to list
      }
    });
  }

  String _getShiftTypeName() {
    // Determine shift type based on start time
    final time = shiftNote.startTime.split(':');
    final hour = int.parse(time[0]);
    
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Overnight';
    }
  }

  String? _extractSection(String? formattedNote, String sectionHeader) {
    if (formattedNote == null) return null;
    
    // Try to extract the section content between headers
    final startIndex = formattedNote.indexOf(sectionHeader);
    if (startIndex == -1) return null;
    
    // Find the start of the content (after the header and newline)
    final contentStart = formattedNote.indexOf('\n', startIndex) + 1;
    if (contentStart == 0) return null;
    
    // Find the next section header (emoji pattern)
    final nextSectionPattern = RegExp(r'[🌅😊🎯📋]');
    final match = nextSectionPattern.firstMatch(formattedNote.substring(contentStart));
    final contentEnd = match != null 
        ? contentStart + match.start 
        : formattedNote.length;
    
    return formattedNote.substring(contentStart, contentEnd).trim();
  }

  String _calculateDuration(String startTime, String endTime) {
    try {
      // Parse 24-hour format (HH:mm)
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);
      
      // Create DateTime objects for today with the times
      final now = DateTime.now();
      var start = DateTime(now.year, now.month, now.day, startHour, startMinute);
      var end = DateTime(now.year, now.month, now.day, endHour, endMinute);
      
      // If end time is before start time, assume it's the next day
      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1));
      }
      
      final duration = end.difference(start);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      
      if (minutes > 0) {
        return '$hours hrs ${minutes} mins';
      } else {
        return '$hours hrs';
      }
    } catch (e) {
      return 'N/A';
    }
  }
  
  /// Format 24-hour time to 12-hour format with AM/PM
  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final minuteStr = minute.toString().padLeft(2, '0');
      
      return '$hour12:$minuteStr $period';
    } catch (e) {
      return time24;
    }
  }

  void _shareShiftNote(BuildContext context, String clientName) {
    final shiftNoteText = '''
Shift Note - ${DateFormat('MMMM d, yyyy').format(DateTime.parse(shiftNote.shiftDate))}

Client: $clientName
Duration: ${shiftNote.startTime} - ${shiftNote.endTime}
Location: ${shiftNote.primaryLocations?.join(', ') ?? 'N/A'}

${shiftNote.formattedNote ?? shiftNote.rawNotes}
''';

    Clipboard.setData(ClipboardData(text: shiftNoteText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shift note copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
