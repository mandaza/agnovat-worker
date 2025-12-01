import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/shift_note.dart';
import '../../../data/models/activity_session.dart';
import '../../../data/models/activity_session_enums.dart';
import '../../../data/models/goal.dart';
import '../../../data/services/media_upload_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shift_notes_provider.dart';
import '../../providers/shift_note_detail_provider.dart';
import 'unified_shift_note_wizard.dart';

/// Shift Note Details Screen
/// Displays detailed information about a specific shift note matching Figma design
class ShiftNoteDetailsScreen extends ConsumerWidget {
  final String shiftNoteId;

  const ShiftNoteDetailsScreen({
    super.key,
    required this.shiftNoteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the shift note detail provider for complete data
    final detailState = ref.watch(shiftNoteDetailProvider(shiftNoteId));

    // Show loading state
    if (detailState.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Shift Note',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (detailState.error != null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Shift Note',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Center(
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
                'Error loading shift note',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detailState.error!,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(shiftNoteDetailProvider(shiftNoteId).notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Get the data
    final detail = detailState.data;
    if (detail == null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Shift Note',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: const Center(
          child: Text('No data available'),
        ),
      );
    }

    final shiftNote = detail.shiftNote;
    final activitySessions = detail.activitySessions;
    final goalsMap = detail.goalsMap;
    final client = detail.client;
    final stats = detail.stats;
    final isDraft = shiftNote.isDraft;
    
    // Get client name from provider (already loaded)
    final clientName = client?.name ?? 'Unknown Client';
    
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context, ref, isDraft, shiftNote),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Document title header (show for both draft and submitted)
            _buildDocumentHeader(context, clientName, shiftNote, stats, isDraft),
            const SizedBox(height: 24),
            _buildShiftInfoCard(context, clientName, shiftNote),
            const SizedBox(height: 24),
            // Show activity sessions - either linked records OR parsed from raw notes
            _buildSectionDivider('ACTIVITY SESSIONS'),
            const SizedBox(height: 16),
            if (activitySessions.isNotEmpty)
              _buildActivitySessionsSection(context, activitySessions)
            else
              _buildParsedActivitySessions(context, shiftNote),
            const SizedBox(height: 32),
            // Goals Summary Section (removed redundant shift overview)
            if (activitySessions.isNotEmpty) ...[
              // Goals Summary Section
              if (_hasGoalProgress(activitySessions)) ...[
                _buildSectionDivider('GOALS SUMMARY'),
                const SizedBox(height: 16),
                _buildGoalsSummarySection(context, activitySessions, goalsMap),
                const SizedBox(height: 32),
              ],
              // Behaviors Summary Section
              if (_hasBehaviorIncidents(activitySessions)) ...[
                _buildSectionDivider('BEHAVIORS RECORDED'),
                const SizedBox(height: 16),
                _buildBehaviorsSummarySection(context, activitySessions),
                const SizedBox(height: 32),
              ],
            ],
            // Show raw notes if not already parsed as activity sessions
            if (shiftNote.rawNotes.trim().isNotEmpty &&
                activitySessions.isEmpty &&
                _parseActivitySessionsFromRawNotes(shiftNote.rawNotes).isEmpty) ...[
              _buildSectionDivider('ADDITIONAL NOTES'),
              const SizedBox(height: 16),
              _buildRawNotesSection(context, shiftNote),
              const SizedBox(height: 24),
            ],
            _buildSubmittedBySection(context, ref, shiftNote),
            const SizedBox(height: 24),
            if (isDraft)
              _buildDraftActions(context, shiftNote)
            else
              _buildShareButton(context, clientName, shiftNote),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, bool isDraft, ShiftNote shiftNote) {
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
            onPressed: () => _editNote(context, ref, shiftNote),
            tooltip: 'Edit Note',
          ),
        if (!isDraft)
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.textPrimary),
            onPressed: () => _exportShiftNote(context, shiftNote),
            tooltip: 'Export/Print',
          ),
        Container(
          margin: EdgeInsets.only(right: 24, left: isDraft ? 0 : 8),
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

  /// Build document header with summary
  Widget _buildDocumentHeader(
    BuildContext context,
    String clientName,
    ShiftNote shiftNote,
    ShiftNoteStats stats,
    bool isDraft,
  ) {
    // Use pre-calculated stats from provider
    final totalActivities = stats.totalActivities;
    final totalGoals = stats.totalGoals;
    final totalBehaviors = stats.totalBehaviors;
    final totalMedia = stats.totalMedia;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDraft
                ? [
                    AppColors.goldenAmber.withOpacity(0.8),
                    AppColors.burntOrange.withOpacity(0.7),
                  ]
                : [
                    AppColors.deepBrown,
                    AppColors.burntOrange.withOpacity(0.9),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDraft ? AppColors.goldenAmber : AppColors.deepBrown).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDraft ? 'SHIFT DOCUMENTATION (DRAFT)' : 'SHIFT DOCUMENTATION',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDocumentStat(
                          icon: Icons.event_note,
                          label: 'Activities',
                          value: totalActivities.toString(),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: _buildDocumentStat(
                          icon: Icons.track_changes,
                          label: 'Goals',
                          value: totalGoals.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDocumentStat(
                          icon: Icons.warning_amber_rounded,
                          label: 'Behaviors',
                          value: totalBehaviors.toString(),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: _buildDocumentStat(
                          icon: Icons.photo_library,
                          label: 'Media',
                          value: totalMedia.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildShiftInfoCard(BuildContext context, String clientName, ShiftNote shiftNote) {
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
              DateFormat('MMMM d, yyyy').format(DateTime.parse(shiftNote.shiftDate)),
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

  Widget _buildRawNotesSection(BuildContext context, ShiftNote shiftNote) {
    // Parse raw notes into sections
    final sections = _parseRawNotes(shiftNote.rawNotes);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activities Section
          if (sections['activities']?.isNotEmpty ?? false) ...[
            Container(
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
                        'Activities Completed',
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
                    sections['activities']!,
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
            const SizedBox(height: 16),
          ],
          
          // Behaviors Section
          if (sections['behaviours']?.isNotEmpty ?? false) ...[
            Container(
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
                    sections['behaviours']!,
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
            const SizedBox(height: 16),
          ],
          
          // Goals Section
          if (sections['progress']?.isNotEmpty ?? false) ...[
            Container(
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
                  Text(
                    sections['progress']!,
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
            const SizedBox(height: 16),
          ],
          
          // If no sections parsed, show all raw notes together
          if ((sections['activities']?.isEmpty ?? true) &&
              (sections['behaviours']?.isEmpty ?? true) &&
              (sections['progress']?.isEmpty ?? true)) ...[
            Container(
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
                        'Notes',
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
          ],
        ],
      ),
    );
  }
  
  /// Parse raw notes into sections
  Map<String, String> _parseRawNotes(String rawNotes) {
    final sections = <String, String>{};
    final lines = rawNotes.split('\n');
    String currentSection = '';
    final StringBuffer activitiesBuffer = StringBuffer();
    final StringBuffer behavioursBuffer = StringBuffer();
    final StringBuffer progressBuffer = StringBuffer();
    
    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      if (lowerLine.contains('activities completed:') || 
          lowerLine.contains('activity') && lowerLine.contains(':')) {
        currentSection = 'activities';
        continue;
      } else if (lowerLine.contains('behaviours') || 
                 lowerLine.contains('engagement') ||
                 lowerLine.contains('behaviour')) {
        currentSection = 'behaviours';
        continue;
      } else if (lowerLine.contains('progress') || 
                 lowerLine.contains('goal')) {
        currentSection = 'progress';
        continue;
      }
      
      if (line.trim().isNotEmpty) {
        if (currentSection == 'activities') {
          activitiesBuffer.writeln(line);
        } else if (currentSection == 'behaviours') {
          behavioursBuffer.writeln(line);
        } else if (currentSection == 'progress') {
          progressBuffer.writeln(line);
        }
      }
    }
    
    final activities = activitiesBuffer.toString().trim();
    final behaviours = behavioursBuffer.toString().trim();
    final progress = progressBuffer.toString().trim();
    
    if (activities.isNotEmpty) sections['activities'] = activities;
    if (behaviours.isNotEmpty) sections['behaviours'] = behaviours;
    if (progress.isNotEmpty) sections['progress'] = progress;
    
    return sections;
  }
  
  /// Parse activity sessions from raw notes text and display as cards
  Widget _buildParsedActivitySessions(BuildContext context, ShiftNote shiftNote) {
    final activitySessions = _parseActivitySessionsFromRawNotes(shiftNote.rawNotes);
    
    // Enhance with structured data from shift note if available
    if (activitySessions.isNotEmpty) {
      for (final session in activitySessions) {
        final goals = session['goals'] as List<String>;
        final behaviors = session['behaviors'] as List<String>;

        // Check if goals list contains only placeholder text
        final hasGoalPlaceholder = goals.any((g) => g.contains('goal(s) worked on during this session'));
        final hasBehaviorPlaceholder = behaviors.any((b) => b.contains('behavior(s) recorded during this session'));

        // Replace goal placeholders with structured data if available
        if (shiftNote.goalsProgress != null && shiftNote.goalsProgress!.isNotEmpty) {
          // Clear ALL existing goals (placeholders or counts)
          goals.clear();

          // Add actual goals from structured data
          for (final goalProgress in shiftNote.goalsProgress!) {
            final goalText = goalProgress.progressNotes.isNotEmpty
                ? '${goalProgress.progressNotes} (Progress: ${goalProgress.progressObserved}/10)'
                : 'Goal progress recorded (${goalProgress.progressObserved}/10)';
            goals.add(goalText);
          }
        } else if (hasGoalPlaceholder) {
          // If still only placeholders and no structured data, add a helpful message
          final count = goals.firstWhere((g) => g.contains('goal(s) worked on'), orElse: () => '');
          if (count.isNotEmpty) {
            final match = RegExp(r'(\d+)').firstMatch(count);
            if (match != null) {
              goals.clear();
              goals.add('ℹ️ ${match.group(1)} goal(s) were worked on during this session.');
              goals.add('💡 Full goal details not available in shift note data.');
            }
          }
        }

        // Same for behaviors - add helpful message if only counts available
        if (hasBehaviorPlaceholder && behaviors.any((b) => b.contains('behavior(s) recorded'))) {
          final count = behaviors.firstWhere((b) => b.contains('behavior(s) recorded'));
          final match = RegExp(r'(\d+)').firstMatch(count);
          if (match != null) {
            behaviors.clear();
            behaviors.add('ℹ️ ${match.group(1)} behavior incident(s) were recorded during this session.');
            behaviors.add('💡 Full behavior details not available in shift note data.');
          }
        }
      }
    }
    
    if (activitySessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.event_note_outlined,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Activity Sessions',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Activity sessions will appear here once added to this shift note.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: activitySessions.map((session) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildParsedActivitySessionCard(context, session),
          ),
        ).toList(),
      ),
    );
  }
  
  /// Parse activity sessions from raw notes text
  List<Map<String, dynamic>> _parseActivitySessionsFromRawNotes(String rawNotes) {
    final sessions = <Map<String, dynamic>>[];
    final lines = rawNotes.split('\n');
    
    Map<String, dynamic>? currentSession;
    String currentField = '';
    int? goalCount;
    int? behaviorCount;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // Detect start of a new activity
      if (trimmedLine.toLowerCase().startsWith('activity ')) {
        // Save previous session if exists
        if (currentSession != null) {
          // Add placeholder text if only counts were provided
          if ((currentSession['goals'] as List<String>).isEmpty && goalCount != null && goalCount > 0) {
            (currentSession['goals'] as List<String>).add('$goalCount goal(s) worked on during this session');
          }
          if ((currentSession['behaviors'] as List<String>).isEmpty && behaviorCount != null && behaviorCount > 0) {
            (currentSession['behaviors'] as List<String>).add('$behaviorCount behavior(s) recorded during this session');
          }
          sessions.add(currentSession);
        }
        // Start new session
        currentSession = {
          'name': trimmedLine.replaceFirst(RegExp(r'Activity \d+:\s*', caseSensitive: false), ''),
          'time': '',
          'location': '',
          'engagement': '',
          'goals': <String>[],
          'behaviors': <String>[],
          'notes': '',
        };
        currentField = '';
        goalCount = null;
        behaviorCount = null;
      } else if (currentSession != null) {
        final lowerLine = trimmedLine.toLowerCase();
        
        // Parse session details
        if (lowerLine.startsWith('time:')) {
          currentSession['time'] = trimmedLine.substring(5).trim();
          currentField = '';
        } else if (lowerLine.startsWith('location:')) {
          currentSession['location'] = trimmedLine.substring(9).trim();
          currentField = '';
        } else if (lowerLine.startsWith('engagement:')) {
          currentSession['engagement'] = trimmedLine.substring(11).trim();
          currentField = '';
        } else if (lowerLine.startsWith('goals worked on:') || lowerLine.startsWith('goals:')) {
          // Extract goals - could be count or list
          final goalsText = trimmedLine.replaceFirst(RegExp(r'Goals worked on:\s*|Goals:\s*', caseSensitive: false), '');
          currentField = 'goals';
          
          // Check if it's just a number
          if (RegExp(r'^\d+$').hasMatch(goalsText)) {
            goalCount = int.tryParse(goalsText);
          } else if (goalsText.isNotEmpty) {
            // It's actual goal text
            (currentSession['goals'] as List<String>).add(goalsText);
          }
        } else if (lowerLine.startsWith('behaviors recorded:') || 
                   lowerLine.startsWith('behaviours recorded:') ||
                   lowerLine.startsWith('behaviors:') ||
                   lowerLine.startsWith('behaviours:')) {
          // Extract behaviors - could be count or list
          final behaviorsText = trimmedLine.replaceFirst(RegExp(r'Behaviors? recorded:\s*|Behaviours? recorded:\s*|Behaviors?:\s*|Behaviours?:\s*', caseSensitive: false), '');
          currentField = 'behaviors';
          
          // Check if it's just a number
          if (RegExp(r'^\d+$').hasMatch(behaviorsText)) {
            behaviorCount = int.tryParse(behaviorsText);
          } else if (behaviorsText.isNotEmpty) {
            // It's actual behavior text
            (currentSession['behaviors'] as List<String>).add(behaviorsText);
          }
        } else if (lowerLine.startsWith('notes:')) {
          currentSession['notes'] = trimmedLine.substring(6).trim();
          currentField = 'notes';
        } else {
          // Multi-line content for current field
          if (currentField == 'goals') {
            // Check if line looks like a goal (starts with - or •, or is descriptive text)
            if (trimmedLine.startsWith('-') || trimmedLine.startsWith('•') || 
                trimmedLine.startsWith('*') || (trimmedLine.length > 5 && !RegExp(r'^\d+$').hasMatch(trimmedLine))) {
              final goalText = trimmedLine.replaceFirst(RegExp(r'^[-•*]\s*'), '');
              if (goalText.isNotEmpty) {
                (currentSession['goals'] as List<String>).add(goalText);
              }
            }
          } else if (currentField == 'behaviors') {
            // Check if line looks like a behavior
            if (trimmedLine.startsWith('-') || trimmedLine.startsWith('•') || 
                trimmedLine.startsWith('*') || (trimmedLine.length > 5 && !RegExp(r'^\d+$').hasMatch(trimmedLine))) {
              final behaviorText = trimmedLine.replaceFirst(RegExp(r'^[-•*]\s*'), '');
              if (behaviorText.isNotEmpty) {
                (currentSession['behaviors'] as List<String>).add(behaviorText);
              }
            }
          } else if (currentField == 'notes' && !lowerLine.startsWith('activity ')) {
            // Continue notes
            if (currentSession['notes'].isNotEmpty) {
              currentSession['notes'] += '\n' + trimmedLine;
            } else {
              currentSession['notes'] = trimmedLine;
            }
          }
        }
      }
    }
    
    // Add last session
    if (currentSession != null) {
      // Add placeholder text if only counts were provided
      if ((currentSession['goals'] as List<String>).isEmpty && goalCount != null && goalCount > 0) {
        (currentSession['goals'] as List<String>).add('$goalCount goal(s) worked on during this session');
      }
      if ((currentSession['behaviors'] as List<String>).isEmpty && behaviorCount != null && behaviorCount > 0) {
        (currentSession['behaviors'] as List<String>).add('$behaviorCount behavior(s) recorded during this session');
      }
      sessions.add(currentSession);
    }
    
    return sessions;
  }
  
  /// Build activity session card from parsed data
  Widget _buildParsedActivitySessionCard(BuildContext context, Map<String, dynamic> session) {
    final engagement = session['engagement'] as String;
    final engagementColor = _getEngagementColorFromText(engagement);
    
    return Container(
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
          // Activity Title and Engagement
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A3111).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📋',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  session['name'] as String,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (engagement.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: engagementColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sentiment_satisfied_alt,
                        size: 14,
                        color: engagementColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        engagement,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: engagementColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Time and Location
          Row(
            children: [
              if ((session['time'] as String).isNotEmpty) ...[
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  session['time'] as String,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if ((session['location'] as String).isNotEmpty) ...[
                const SizedBox(width: 16),
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    session['location'] as String,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          
          // Session Notes
          if ((session['notes'] as String).isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                session['notes'] as String,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
          
          // Goals
          // Goals and Behaviors removed - shown in detailed summary cards below
          /*if ((session['goals'] as List<String>).isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.track_changes,
                    size: 18,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Goal Progress',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(session['goals'] as List<String>).length}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...(session['goals'] as List<String>).map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        goal,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
          
          // Behaviors
          if ((session['behaviors'] as List<String>).isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 18,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Behavior Incidents',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(session['behaviors'] as List<String>).length}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...(session['behaviors'] as List<String>).map((behavior) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        behavior,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],*/
        ],
      ),
    );
  }
  
  /// Get engagement color from text
  Color _getEngagementColorFromText(String engagement) {
    final lower = engagement.toLowerCase();
    if (lower.contains('highly') || lower.contains('high')) {
      return const Color(0xFF10B981); // Green
    } else if (lower.contains('engaged') && !lower.contains('dis')) {
      return const Color(0xFF3B82F6); // Blue
    } else if (lower.contains('moderate') || lower.contains('medium')) {
      return const Color(0xFFF59E0B); // Amber
    } else if (lower.contains('minimal') || lower.contains('low')) {
      return const Color(0xFFEF4444); // Red
    } else if (lower.contains('disengaged')) {
      return const Color(0xFF6B7280); // Gray
    }
    return const Color(0xFF3B82F6); // Default blue
  }

  // Helper to check if there's goal progress
  bool _hasGoalProgress(List<ActivitySession> sessions) {
    return sessions.any((session) => session.goalProgress.isNotEmpty);
  }

  // Helper to check if there are behavior incidents
  bool _hasBehaviorIncidents(List<ActivitySession> sessions) {
    return sessions.any((session) => session.behaviorIncidents.isNotEmpty);
  }

  // Build shift summary statistics
  Widget _buildShiftSummaryStats(BuildContext context, List<ActivitySession> sessions) {
    final totalActivities = sessions.length;
    final totalGoals = sessions.fold<int>(0, (sum, s) => sum + s.goalProgress.length);
    final totalBehaviors = sessions.fold<int>(0, (sum, s) => sum + s.behaviorIncidents.length);
    final totalDuration = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.event_note,
                label: 'Activities',
                value: '$totalActivities',
                color: AppColors.primary,
              ),
            ),
            Container(width: 1, height: 40, color: Colors.black.withOpacity(0.1)),
            Expanded(
              child: _buildStatItem(
                icon: Icons.track_changes,
                label: 'Goals',
                value: '$totalGoals',
                color: AppColors.success,
              ),
            ),
            Container(width: 1, height: 40, color: Colors.black.withOpacity(0.1)),
            Expanded(
              child: _buildStatItem(
                icon: Icons.warning_amber_rounded,
                label: 'Behaviors',
                value: '$totalBehaviors',
                color: AppColors.warning,
              ),
            ),
            Container(width: 1, height: 40, color: Colors.black.withOpacity(0.1)),
            Expanded(
              child: _buildStatItem(
                icon: Icons.access_time,
                label: 'Duration',
                value: '${totalDuration}m',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Build goals summary section
  Widget _buildGoalsSummarySection(
    BuildContext context,
    List<ActivitySession> sessions,
    Map<String, Goal> goalsMap,
  ) {
    // Aggregate all goals from all sessions
    final Map<String, List<GoalProgressEntry>> goalsByActivity = {};

    for (final session in sessions) {
      if (session.goalProgress.isNotEmpty) {
        final key = session.activityTitle ?? 'Unknown Activity';
        if (!goalsByActivity.containsKey(key)) {
          goalsByActivity[key] = [];
        }
        goalsByActivity[key]!.addAll(session.goalProgress);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.1)),
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
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.track_changes,
                    color: AppColors.success,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Goals Worked On',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${sessions.fold<int>(0, (sum, s) => sum + s.goalProgress.length)}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...goalsByActivity.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entry.value.map((goal) {
                      // Get the actual goal from the goalsMap
                      final goalData = goalsMap[goal.goalId];
                      final goalTitle = goalData?.title ?? 'Goal not found';
                      final goalDescription = goalData?.description ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Goal Title
                                  Text(
                                    goalTitle,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (goalDescription.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      goalDescription,
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (goal.evidenceNotes.isNotEmpty &&
                                      goal.evidenceNotes != 'Documented in session') ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.note_outlined,
                                            size: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              goal.evidenceNotes,
                                              style: const TextStyle(
                                                fontFamily: 'Nunito',
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.trending_up,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${goal.progressObserved}',
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Build behaviors summary section
  Widget _buildBehaviorsSummarySection(BuildContext context, List<ActivitySession> sessions) {
    // Aggregate all behaviors from all sessions
    final List<Map<String, dynamic>> allBehaviors = [];

    for (final session in sessions) {
      for (final incident in session.behaviorIncidents) {
        allBehaviors.add({
          'incident': incident,
          'activity': session.activityTitle ?? 'Unknown Activity',
          'time': session.sessionStartTime,
        });
      }
    }

    // Sort by time
    allBehaviors.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.1)),
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
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Behaviors Recorded',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${allBehaviors.length}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...allBehaviors.map((item) {
              final incident = item['incident'] as BehaviorIncident;
              final activity = item['activity'] as String;
              final time = item['time'] as DateTime;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSeverityColor(incident.severity).withOpacity(0.05),
                  border: Border.all(
                    color: _getSeverityColor(incident.severity).withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(incident.severity).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            incident.severity.displayName.split(':')[0],
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _getSeverityColor(incident.severity),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          incident.duration,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('h:mm a').format(time),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      incident.description,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (incident.behaviorsDisplayed.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: incident.behaviorsDisplayed.map((behavior) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              behavior,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (incident.initialIntervention.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.medical_services_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Intervention:',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  incident.initialIntervention,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (incident.interventionDescription != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    incident.interventionDescription!,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
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
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySessionsSection(BuildContext context, List<ActivitySession> sessions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.event_note,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Activity Sessions',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${sessions.length}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sessions.map((session) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActivitySessionCard(context, session),
          )),
        ],
      ),
    );
  }

  Widget _buildActivitySessionCard(BuildContext context, ActivitySession session) {
    return Container(
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
          // Activity Title
          Row(
            children: [
              Expanded(
                child: Text(
                  session.activityTitle ?? 'Activity',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Engagement indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getEngagementColor(session.participantEngagement).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_alt,
                      size: 14,
                      color: _getEngagementColor(session.participantEngagement),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.participantEngagement.displayName,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getEngagementColor(session.participantEngagement),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Session Time and Duration
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${DateFormat('h:mm a').format(session.sessionStartTime)} - ${DateFormat('h:mm a').format(session.sessionEndTime)} (${session.durationMinutes} min)',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  session.location,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          // Session Notes
          if (session.sessionNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                session.sessionNotes,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],

          // Goal Progress and Behavior Incidents removed - shown in detailed summary cards below

          // Media
          if (session.media.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.photo_library,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Media',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${session.media.length}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: session.media.length,
                itemBuilder: (context, index) {
                  final media = session.media[index];
                  return _buildMediaThumbnail(context, media, index < session.media.length - 1);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getActivityTypeIcon(String? type) {
    switch (type) {
      case 'household_tasks':
        return '🏠';
      case 'social_activities':
        return '👥';
      case 'personal_care':
        return '🧼';
      case 'community_access':
        return '🌍';
      case 'skill_development':
        return '📚';
      case 'recreation':
        return '⚽';
      case 'health_wellness':
        return '💪';
      default:
        return '📋';
    }
  }

  String _formatActivityType(String type) {
    return type.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Color _getEngagementColor(ParticipantEngagement engagement) {
    switch (engagement) {
      case ParticipantEngagement.highlyEngaged:
        return const Color(0xFF10B981); // Green
      case ParticipantEngagement.engaged:
        return const Color(0xFF3B82F6); // Blue
      case ParticipantEngagement.moderate:
        return const Color(0xFFF59E0B); // Amber
      case ParticipantEngagement.minimal:
        return const Color(0xFFEF4444); // Red
      case ParticipantEngagement.disengaged:
        return const Color(0xFF6B7280); // Gray
    }
  }

  Color _getSeverityColor(BehaviorSeverity severity) {
    switch (severity) {
      case BehaviorSeverity.low:
        return const Color(0xFFF59E0B); // Amber
      case BehaviorSeverity.medium:
        return const Color(0xFFEF4444); // Red
      case BehaviorSeverity.high:
        return const Color(0xFF991B1B); // Dark Red
    }
  }





  Widget _buildSubmittedBySection(BuildContext context, WidgetRef ref, ShiftNote shiftNote) {
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

  Widget _buildDraftActions(BuildContext context, ShiftNote shiftNote) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Edit Note button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer(
              builder: (context, ref, child) => ElevatedButton(
                onPressed: () {
                  final detail = ref.read(shiftNoteDetailProvider(shiftNoteId)).data;
                  if (detail != null) {
                    _editNote(context, ref, detail.shiftNote);
                  }
                },
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
          ),
          const SizedBox(height: 12),
          // Submit Note button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer(
              builder: (context, ref, child) => ElevatedButton(
                onPressed: () {
                  final detail = ref.read(shiftNoteDetailProvider(shiftNoteId)).data;
                  if (detail != null) {
                    _submitNote(context, ref, detail.shiftNote);
                  }
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
                  final detail = ref.read(shiftNoteDetailProvider(shiftNoteId)).data;
                  if (detail != null) {
                    _showDeleteConfirmation(context, ref, detail.shiftNote);
                  }
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

  Widget _buildShareButton(BuildContext context, String clientName, ShiftNote shiftNote) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: () => _shareShiftNote(context, clientName, shiftNote),
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

  void _submitNote(BuildContext context, WidgetRef ref, ShiftNote shiftNote) async {
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ShiftNote shiftNote) {
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

  void _editNote(BuildContext context, WidgetRef ref, ShiftNote shiftNote) {
    // Only allow editing draft notes
    if (!shiftNote.isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submitted shift notes cannot be edited'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navigate to unified wizard for editing
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UnifiedShiftNoteWizard(
          shiftNote: shiftNote,
        ),
      ),
    ).then((updated) {
      // If the note was updated, refresh the data
      if (updated == true) {
        ref.read(shiftNoteDetailProvider(shiftNoteId).notifier).refresh();
      }
    });
  }

  String _getShiftTypeName(ShiftNote shiftNote) {
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

  void _shareShiftNote(BuildContext context, String clientName, ShiftNote shiftNote) {
    final shiftNoteText = '''
Shift Note - ${DateFormat('MMMM d, yyyy').format(DateTime.parse(shiftNote.shiftDate))}

Client: $clientName
Duration: ${shiftNote.startTime} - ${shiftNote.endTime}


${shiftNote.rawNotes}
''';

    Clipboard.setData(ClipboardData(text: shiftNoteText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shift note copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Export shift note as text (future: could be PDF)
  void _exportShiftNote(BuildContext context, ShiftNote shiftNote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Export Shift Note',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Export functionality coming soon! This will allow you to export the shift note as a PDF document.',
          style: TextStyle(
            fontFamily: 'Nunito',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section divider
  Widget _buildSectionDivider(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary.withOpacity(0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  /// Build media thumbnail with actual image loading
  Widget _buildMediaThumbnail(BuildContext context, MediaItem media, bool hasMargin) {
    return Consumer(
      builder: (context, ref, _) {
        return FutureBuilder<String>(
          future: ref.read(mediaUploadServiceProvider).getMediaUrl(media.storageId),
          builder: (context, snapshot) {
            return GestureDetector(
              onTap: () {
                if (snapshot.hasData && media.type == 'photo') {
                  _showFullScreenImage(context, snapshot.data!);
                }
              },
              child: Container(
                width: 120,
                margin: EdgeInsets.only(right: hasMargin ? 8 : 0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : snapshot.hasError
                          ? Center(
                              child: Icon(
                                media.type == 'photo' ? Icons.photo : Icons.videocam,
                                size: 32,
                                color: AppColors.error,
                              ),
                            )
                          : snapshot.hasData
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (media.type == 'photo')
                                      CachedNetworkImage(
                                        imageUrl: snapshot.data!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        errorWidget: (context, url, error) => Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 32,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        color: Colors.black87,
                                        child: const Center(
                                          child: Icon(
                                            Icons.play_circle_outline,
                                            size: 48,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    // Type badge
                                    Positioned(
                                      bottom: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              media.type == 'photo'
                                                  ? Icons.photo
                                                  : Icons.videocam,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Icon(
                                    media.type == 'photo' ? Icons.photo : Icons.videocam,
                                    size: 32,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Show full screen image
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
