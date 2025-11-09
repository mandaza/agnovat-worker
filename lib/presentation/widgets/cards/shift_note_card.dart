import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/shift_note.dart';

/// Shift Note card widget matching Figma design
class ShiftNoteCard extends StatelessWidget {
  final ShiftNote shiftNote;
  final String? clientName;
  final VoidCallback? onTap;

  const ShiftNoteCard({
    super.key,
    required this.shiftNote,
    this.clientName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = shiftNote.isDraft;

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
              _formatDate(shiftNote.shiftDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Shift info
            Text(
              _getShiftInfo(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // Status and client badges
            Row(
              children: [
                _buildStatusBadge(isDraft),
                const SizedBox(width: 8),
                if (clientName != null) _buildClientBadge(clientName!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(bool isDraft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDraft
            ? AppColors.goldenAmber.withValues(alpha: 0.1)
            : AppColors.deepBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDraft ? 'Draft' : 'Submitted',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: isDraft ? AppColors.goldenAmber : AppColors.deepBrown,
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

  /// Format date for display
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Get shift info string (e.g., "Morning Shift • 3 hours")
  String _getShiftInfo() {
    // Calculate duration
    final startParts = shiftNote.startTime.split(':');
    final endParts = shiftNote.endTime.split(':');
    
    final startHour = int.parse(startParts[0]);
    final endHour = int.parse(endParts[0]);
    
    final duration = endHour - startHour;

    // Determine shift type
    String shiftType;
    if (startHour < 12) {
      shiftType = 'Morning Shift';
    } else if (startHour < 17) {
      shiftType = 'Afternoon Shift';
    } else {
      shiftType = 'Evening Shift';
    }

    return '$shiftType • $duration ${duration == 1 ? 'hour' : 'hours'}';
  }
}




