import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/shift_note.dart';
import '../ai_assistant/ai_assistant_screen.dart';

/// Formatted Shift Note Details Screen
/// Displays a formatted shift note with AI-enhanced sections
class FormattedShiftNoteScreen extends ConsumerWidget {
  final ShiftNote shiftNote;

  const FormattedShiftNoteScreen({
    super.key,
    required this.shiftNote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildShiftInfoCard(context),
            const SizedBox(height: 24),
            _buildSessionActivitiesSection(context),
            const SizedBox(height: 24),
            _buildBehavioursEngagementSection(context),
            const SizedBox(height: 24),
            _buildGoalProgressSection(context),
            const SizedBox(height: 24),
            _buildSessionSummarySection(context),
            const SizedBox(height: 24),
            _buildSubmittedBySection(context),
            const SizedBox(height: 24),
            _buildShareButton(context),
            const SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),
      floatingActionButton: _buildFloatingAIButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
        Container(
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF5A3111).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Submitted',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A3111),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShiftInfoCard(BuildContext context) {
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
              value: shiftNote.clientId, // In production, fetch client name
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.access_time,
              iconColor: const Color(0xFFD68630).withOpacity(0.1),
              label: 'Duration',
              value: '${shiftNote.startTime} - ${shiftNote.endTime} (${_calculateDuration(shiftNote.startTime, shiftNote.endTime)})',
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
            // Goal with progress bar
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

  Widget _buildSubmittedBySection(BuildContext context) {
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
            const Text(
              'Sarah Johnson', // TODO: Get from actual user data
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy').format(shiftNote.createdAt) +
                  ' at ' +
                  DateFormat('h:mm a').format(shiftNote.createdAt),
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

  Widget _buildShareButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: () => _shareShiftNote(context),
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

  Widget _buildFloatingAIButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AiAssistantScreen(),
          ),
        );
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5A3111), Color(0xFF954406)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A3111).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF5A3111).withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 28,
              ),
            ),
            Positioned(
              right: 2,
              top: 10,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFD68630),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      final start = DateFormat('h:mm a').parse(startTime);
      final end = DateFormat('h:mm a').parse(endTime);
      final duration = end.difference(start);
      final hours = duration.inHours;
      return '$hours hours';
    } catch (e) {
      return '2 hours';
    }
  }

  void _shareShiftNote(BuildContext context) {
    final shiftNoteText = '''
Shift Note - ${DateFormat('MMMM d, yyyy').format(DateTime.parse(shiftNote.shiftDate))}

Client: ${shiftNote.clientId}
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

