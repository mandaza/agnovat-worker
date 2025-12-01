import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../data/models/activity.dart';
import '../../../data/models/activity_session.dart';
import '../../../data/models/activity_session_enums.dart';
import '../../../data/models/client.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/shift_note.dart';
import '../../../data/services/media_upload_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/shift_notes_provider.dart';

/// Unified Shift Note Creation Wizard
/// Creates shift notes with inline activity sessions and behaviors
/// Can also be used to edit existing shift notes
class UnifiedShiftNoteWizard extends ConsumerStatefulWidget {
  final ShiftNote? shiftNote; // Optional: for editing existing shift notes
  
  const UnifiedShiftNoteWizard({
    super.key,
    this.shiftNote,
  });

  @override
  ConsumerState<UnifiedShiftNoteWizard> createState() =>
      _UnifiedShiftNoteWizardState();
}

class _UnifiedShiftNoteWizardState
    extends ConsumerState<UnifiedShiftNoteWizard> {
  final _uuid = const Uuid();

  // Stepper control
  int _currentStep = 0;

  // Step 1: Shift Details
  String? _selectedClientId;
  String? _selectedClientName;
  DateTime _shiftDate = DateTime.now();
  TimeOfDay? _shiftStartTime;
  TimeOfDay? _shiftEndTime;

  // Step 2: Activity Sessions
  final List<ActivitySessionData> _activitySessions = [];

  // Loading state
  bool _isSubmitting = false;
  bool _isSavingDraft = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing, otherwise set default client
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.shiftNote != null) {
        // Check if trying to edit a submitted note
        if (!widget.shiftNote!.isDraft) {
          // Show error and go back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Submitted shift notes cannot be edited'),
                  backgroundColor: AppColors.error,
                ),
              );
              Navigator.of(context).pop();
            }
          });
          return;
        }
        _preFillFormData(widget.shiftNote!);
      } else {
        final dashboardState = ref.read(dashboardProvider);
        if (dashboardState.assignedClients.isNotEmpty && _selectedClientId == null) {
          setState(() {
            _selectedClientId = dashboardState.assignedClients.first.id;
            _selectedClientName = dashboardState.assignedClients.first.name;
          });
        }
      }
    });
  }

  /// Pre-fill form data when editing an existing shift note
  void _preFillFormData(ShiftNote shiftNote) async {
    // Get client name
    String clientName = 'Unknown Client';
    try {
      final dashboardState = ref.read(dashboardProvider);
      final client = dashboardState.assignedClients.firstWhere(
        (c) => c.id == shiftNote.clientId,
      );
      clientName = client.name;
    } catch (e) {
      // If not in dashboard, fetch client directly
      try {
        final apiService = ref.read(mcpApiServiceProvider);
        final client = await apiService.getClient(shiftNote.clientId);
        clientName = client.name;
      } catch (e) {
        // Keep default
      }
    }

    // Set date and times
    final startParts = shiftNote.startTime.split(':');
    final endParts = shiftNote.endTime.split(':');
    
    setState(() {
      _selectedClientId = shiftNote.clientId;
      _selectedClientName = clientName;
      _shiftDate = DateTime.parse(shiftNote.shiftDate);
      _shiftStartTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
      _shiftEndTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
    });

    // Load existing activity sessions if any
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final result = await apiService.getShiftNoteWithSessions(shiftNote.id);
      
      // Parse activity sessions if present
      final sessionsList = result['activity_sessions'] as List<dynamic>?;
      if (sessionsList != null && sessionsList.isNotEmpty) {
        final List<ActivitySessionData> loadedSessions = [];
        
        for (final sessionJson in sessionsList) {
          try {
            final session = ActivitySession.fromJson(sessionJson as Map<String, dynamic>);
            
            // Convert MediaItem to UploadedMedia
            final uploadedMedia = session.media.map((mediaItem) {
              return UploadedMedia(
                storageId: mediaItem.storageId,
                fileName: mediaItem.fileName,
                fileSize: mediaItem.fileSize,
                mimeType: mediaItem.mimeType,
                type: mediaItem.type == 'photo' ? MediaType.photo : MediaType.video,
              );
            }).toList();
            
            // Convert ActivitySession to ActivitySessionData
            final sessionData = ActivitySessionData(
              id: session.id,
              activityId: session.activityId,
              activityTitle: session.activityTitle,
              sessionStartTime: session.sessionStartTime,
              sessionEndTime: session.sessionEndTime,
              durationMinutes: session.durationMinutes,
              location: session.location,
              participantEngagement: session.participantEngagement,
              goalProgress: session.goalProgress,
              behaviorIncidents: session.behaviorIncidents,
              sessionNotes: session.sessionNotes,
              uploadedMedia: uploadedMedia,
            );
            
            loadedSessions.add(sessionData);
          } catch (e) {
            // Skip sessions that fail to parse
            continue;
          }
        }
        
        if (mounted) {
          setState(() {
            _activitySessions.addAll(loadedSessions);
          });
        }
      }
    } catch (e) {
      // If loading sessions fails, continue without them
      // User can still add new sessions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: _buildStepControls,
        steps: [
          Step(
            title: const Text('Shift Details'),
            content: _buildStep1ShiftDetails(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Activity Sessions'),
            content: _buildStep2ActivitySessions(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Review & Submit'),
            content: _buildStep3Review(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.shiftNote != null ? 'Edit Shift Note' : 'Document Shift',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ==================== STEP 1: SHIFT DETAILS ====================
  Widget _buildStep1ShiftDetails() {
    final dashboardState = ref.watch(dashboardProvider);
    final clients = dashboardState.assignedClients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic shift information',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Client Selector
        _buildSectionLabel('Client'),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.shiftNote != null ? null : () => _showClientSelector(clients),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.shiftNote != null 
                  ? AppColors.grey100.withOpacity(0.5) 
                  : AppColors.white,
              border: Border.all(
                color: widget.shiftNote != null 
                    ? AppColors.borderLight.withOpacity(0.5) 
                    : AppColors.borderLight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedClientName ?? 'Select client',
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.shiftNote != null
                        ? AppColors.textSecondary
                        : (_selectedClientName != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary),
                  ),
                ),
                if (widget.shiftNote != null)
                  const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary)
                else
                  const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Date Picker
        _buildSectionLabel('Shift Date'),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.shiftNote != null ? null : () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _shiftDate,
              firstDate: DateTime.now().subtract(const Duration(days: 7)),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _shiftDate = date);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.shiftNote != null 
                  ? AppColors.grey100.withOpacity(0.5) 
                  : AppColors.white,
              border: Border.all(
                color: widget.shiftNote != null 
                    ? AppColors.borderLight.withOpacity(0.5) 
                    : AppColors.borderLight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                if (widget.shiftNote == null)
                  const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                if (widget.shiftNote == null) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_shiftDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.shiftNote != null 
                          ? AppColors.textSecondary 
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (widget.shiftNote != null)
                  const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Time Pickers
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Start Time'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: widget.shiftNote != null ? null : () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _shiftStartTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _shiftStartTime = time);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: widget.shiftNote != null 
                            ? AppColors.grey100.withOpacity(0.5) 
                            : AppColors.white,
                        border: Border.all(
                          color: widget.shiftNote != null 
                              ? AppColors.borderLight.withOpacity(0.5) 
                              : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          if (widget.shiftNote == null)
                            const Icon(Icons.access_time, size: 20, color: AppColors.primary),
                          if (widget.shiftNote == null) const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _shiftStartTime?.format(context) ?? 'Select time',
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.shiftNote != null
                                    ? AppColors.textSecondary
                                    : (_shiftStartTime != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ),
                          if (widget.shiftNote != null)
                            const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('End Time'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: widget.shiftNote != null ? null : () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _shiftEndTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _shiftEndTime = time);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: widget.shiftNote != null 
                            ? AppColors.grey100.withOpacity(0.5) 
                            : AppColors.white,
                        border: Border.all(
                          color: widget.shiftNote != null 
                              ? AppColors.borderLight.withOpacity(0.5) 
                              : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          if (widget.shiftNote == null)
                            const Icon(Icons.access_time, size: 20, color: AppColors.primary),
                          if (widget.shiftNote == null) const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _shiftEndTime?.format(context) ?? 'Select time',
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.shiftNote != null
                                    ? AppColors.textSecondary
                                    : (_shiftEndTime != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ),
                          if (widget.shiftNote != null)
                            const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== STEP 2: ACTIVITY SESSIONS ====================
  Widget _buildStep2ActivitySessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Document activities performed during this shift',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // List of added activity sessions
        if (_activitySessions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Center(
              child: Text(
                'No activity sessions added yet',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ..._activitySessions.asMap().entries.map((entry) {
            final index = entry.key;
            final session = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActivitySessionCard(session, index),
            );
          }),

        const SizedBox(height: 16),

        // Add Activity Session Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addActivitySession,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Activity Session'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary, width: 2),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySessionCard(ActivitySessionData session, int index) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldenAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_activity,
                  size: 20,
                  color: AppColors.goldenAmber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.activityTitle ?? 'Activity Session ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${session.location} • ${session.behaviorIncidents.length} behavior(s)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editActivitySession(index),
                color: AppColors.primary,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => _deleteActivitySession(index),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== STEP 3: REVIEW & SUBMIT ====================
  Widget _buildStep3Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review your shift documentation',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Shift Summary
        _buildReviewSection(
          'Shift Details',
          [
            _buildReviewItem('Client', _selectedClientName ?? 'Not selected'),
            _buildReviewItem('Date', DateFormat('EEEE, MMMM d, yyyy').format(_shiftDate)),
            _buildReviewItem(
              'Time',
              '${_shiftStartTime?.format(context) ?? '--'} - ${_shiftEndTime?.format(context) ?? '--'}',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Activity Sessions Summary
        _buildReviewSection(
          'Activity Sessions (${_activitySessions.length})',
          _activitySessions.asMap().entries.map((entry) {
            final session = entry.value;
            return _buildReviewItem(
              'Session ${entry.key + 1}',
              '${session.activityTitle ?? 'Unknown'} • ${session.behaviorIncidents.length} behavior(s) • ${session.goalProgress.length} goal(s)',
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Action Buttons
        _buildSubmitButton(),
        const SizedBox(height: 12),
        _buildSaveAsDraftButton(),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<Widget> items) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _showClientSelector(List<Client> clients) {
    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No clients available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Client',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...clients.map((client) {
              final isSelected = _selectedClientId == client.id;
              return ListTile(
                title: Text(client.name),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedClientId = client.id;
                    _selectedClientName = client.name;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _addActivitySession() {
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitySessionFormScreen(
          clientId: _selectedClientId!,
          shiftDate: _shiftDate,
          onSave: (session) {
            setState(() {
              _activitySessions.add(session);
            });
          },
        ),
      ),
    );
  }

  void _editActivitySession(int index) {
    final session = _activitySessions[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitySessionFormScreen(
          clientId: _selectedClientId!,
          shiftDate: _shiftDate,
          existingSession: session,
          onSave: (updatedSession) {
            setState(() {
              _activitySessions[index] = updatedSession;
            });
          },
        ),
      ),
    );
  }

  void _deleteActivitySession(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity Session?'),
        content: const Text('This will remove the activity session and all its behaviors.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _activitySessions.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (details.currentStep < 2)
            Expanded(
              child: ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          if (details.currentStep > 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: details.onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      // Validate Step 1
      if (_selectedClientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a client'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (_shiftStartTime == null || _shiftEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select shift start and end times'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      // Validate Step 2
      if (_activitySessions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one activity session'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBrown,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: AppColors.grey300,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                widget.shiftNote != null ? 'Update Shift Note' : 'Submit Shift Note',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSaveAsDraftButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _isSavingDraft ? null : _handleSaveAsDraft,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceLight,
          side: const BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSavingDraft
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                widget.shiftNote != null ? 'Update Draft' : 'Save as Draft',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (_selectedClientId == null) {
        throw Exception('No client selected');
      }

      if (_shiftStartTime == null || _shiftEndTime == null) {
        throw Exception('Shift times not set');
      }

      // Step 1: Create or update shift note
      final isEditing = widget.shiftNote != null;
      
      // Prevent editing submitted notes
      if (isEditing && !widget.shiftNote!.isDraft) {
        throw Exception('Cannot edit submitted shift notes');
      }
      
      print(isEditing ? '📝 Updating shift note...' : '📝 Creating shift note...');
      final apiService = ref.read(mcpApiServiceProvider);

      // Format shift date as YYYY-MM-DD
      final shiftDateStr = DateFormat('yyyy-MM-dd').format(_shiftDate);

      // Format times as HH:MM
      final startTimeStr = '${_shiftStartTime!.hour.toString().padLeft(2, '0')}:${_shiftStartTime!.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${_shiftEndTime!.hour.toString().padLeft(2, '0')}:${_shiftEndTime!.minute.toString().padLeft(2, '0')}';

      // Create shift note with raw notes summarizing the shift
      final rawNotes = _generateRawNotes();

      final String shiftNoteId;
      if (isEditing) {
        // Update existing shift note
        await apiService.updateShiftNote(
          shiftNoteId: widget.shiftNote!.id,
          rawNotes: rawNotes,
        );
        shiftNoteId = widget.shiftNote!.id;
        print('✅ Shift note updated: $shiftNoteId');
      } else {
        // Create new shift note
        final shiftNoteResult = await apiService.createShiftNote(
          clientId: _selectedClientId!,
          userId: userId,
          shiftDate: shiftDateStr,
          startTime: startTimeStr,
          endTime: endTimeStr,
          rawNotes: rawNotes,
        );
        shiftNoteId = shiftNoteResult['_id'] ?? shiftNoteResult['id'];
        print('✅ Shift note created: $shiftNoteId');
      }

      // Step 2: Create or update activity sessions and link to shift note
      if (_activitySessions.isNotEmpty) {
        print('📋 Processing ${_activitySessions.length} activity sessions...');
        final activitySessionService = ref.read(activitySessionServiceProvider);

        for (final sessionData in _activitySessions) {
          // Check if this is an existing session (has a backend ID that's not a UUID)
          // Convex IDs are typically shorter and don't match UUID pattern
          final isExistingSession = sessionData.id.length < 36 || !sessionData.id.contains('-');
          
          if (isExistingSession && isEditing) {
            // Update existing session
            print('🔄 Updating existing session: ${sessionData.id}');
            
            // Prepare update data
            final updates = <String, dynamic>{
              'activity_id': sessionData.activityId,
              'session_start_time': sessionData.sessionStartTime.toIso8601String(),
              'session_end_time': sessionData.sessionEndTime.toIso8601String(),
              'duration_minutes': sessionData.durationMinutes,
              'location': sessionData.location,
              'session_notes': sessionData.sessionNotes,
              'participant_engagement': sessionData.participantEngagement.value,
              'goal_progress': sessionData.goalProgress.map((gp) => {
                'goal_id': gp.goalId,
                'progress_observed': gp.progressObserved,
                'evidence_notes': gp.evidenceNotes,
              }).toList(),
              'behavior_incidents': sessionData.behaviorIncidents.map((bi) => {
                'id': bi.id,
                'behaviors_displayed': bi.behaviorsDisplayed,
                'duration': bi.duration,
                'severity': bi.severity.toJson(),
                'self_harm': bi.selfHarm,
                'self_harm_types': bi.selfHarmTypes,
                'self_harm_count': bi.selfHarmCount,
                'initial_intervention': bi.initialIntervention,
                'intervention_description': bi.interventionDescription,
                'second_support_needed': bi.secondSupportNeeded,
                'second_support_description': bi.secondSupportDescription,
                'description': bi.description,
              }).toList(),
            };
            
            await activitySessionService.updateSession(
              sessionData.id,
              updates,
            );
            print('✅ Activity session updated: ${sessionData.activityTitle}');
            
            // Handle media updates
            // Get existing media from the session to compare
            final existingSession = await activitySessionService.getSessionById(sessionData.id);
            final existingMediaIds = existingSession.media.map((m) => m.storageId).toSet();
            final newMediaIds = sessionData.uploadedMedia.map((m) => m.storageId).toSet();
            
            // Remove media that was deleted
            for (final existingMedia in existingSession.media) {
              if (!newMediaIds.contains(existingMedia.storageId)) {
                await apiService.removeMediaFromSession(
                  sessionId: sessionData.id,
                  mediaId: existingMedia.id,
                );
                print('🗑️ Removed media: ${existingMedia.fileName}');
              }
            }
            
            // Add new media that wasn't there before
            for (final media in sessionData.uploadedMedia) {
              if (!existingMediaIds.contains(media.storageId)) {
                await apiService.addMediaToSession(
                  sessionId: sessionData.id,
                  storageId: media.storageId,
                  type: media.type.value,
                  fileName: media.fileName,
                  fileSize: media.fileSize,
                  mimeType: media.mimeType,
                );
                print('✅ Added media: ${media.fileName}');
              }
            }
          } else {
            // Create new session
            print('➕ Creating new session: ${sessionData.activityTitle}');
            
            // Convert ActivitySessionData to ActivitySession
            final activitySession = ActivitySession(
              id: sessionData.id,
              activityId: sessionData.activityId,
              clientId: _selectedClientId!,
              stakeholderId: userId,
              shiftNoteId: shiftNoteId,
              sessionStartTime: sessionData.sessionStartTime,
              sessionEndTime: sessionData.sessionEndTime,
              durationMinutes: sessionData.durationMinutes,
              location: sessionData.location,
              sessionNotes: sessionData.sessionNotes,
              participantEngagement: sessionData.participantEngagement,
              goalProgress: sessionData.goalProgress,
              behaviorIncidents: sessionData.behaviorIncidents,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            // Create session and get the returned session with backend ID
            final createdSession = await activitySessionService.createSession(activitySession);
            print('✅ Activity session created: ${sessionData.activityTitle}');

            // Link session to shift note (as per backend docs)
            await apiService.addActivitySessionToShiftNote(
              shiftNoteId: shiftNoteId,
              activitySessionId: createdSession.id,
            );
            print('🔗 Linked session to shift note');

            // Link uploaded media to session
            if (sessionData.uploadedMedia.isNotEmpty) {
              print('📸 Linking ${sessionData.uploadedMedia.length} media files to session...');
              for (final media in sessionData.uploadedMedia) {
                await apiService.addMediaToSession(
                  sessionId: createdSession.id,
                  storageId: media.storageId,
                  type: media.type.value,
                  fileName: media.fileName,
                  fileSize: media.fileSize,
                  mimeType: media.mimeType,
                );
                print('✅ Media linked: ${media.fileName}');
              }
            }
          }
        }
      }

      // Step 3: Submit the shift note (mark as submitted)
      print('📤 Submitting shift note...');
      await apiService.submitShiftNote(shiftNoteId);

      // Step 4: Refresh shift notes list
      ref.read(shiftNotesProvider.notifier).refresh();

      print('✅ Shift note submitted successfully');
      print('📋 ${_activitySessions.length} activity sessions');

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shift note submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ Error submitting shift note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleSaveAsDraft() async {
    setState(() => _isSavingDraft = true);

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (_selectedClientId == null) {
        throw Exception('No client selected');
      }

      if (_shiftStartTime == null || _shiftEndTime == null) {
        throw Exception('Shift times not set');
      }

      // Step 1: Create or update draft shift note
      final isEditing = widget.shiftNote != null;
      
      // Prevent editing submitted notes
      if (isEditing && !widget.shiftNote!.isDraft) {
        throw Exception('Cannot edit submitted shift notes');
      }
      
      print(isEditing ? '📝 Updating draft shift note...' : '📝 Saving draft shift note...');
      final apiService = ref.read(mcpApiServiceProvider);

      // Format shift date as YYYY-MM-DD
      final shiftDateStr = DateFormat('yyyy-MM-dd').format(_shiftDate);

      // Format times as HH:MM
      final startTimeStr = '${_shiftStartTime!.hour.toString().padLeft(2, '0')}:${_shiftStartTime!.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${_shiftEndTime!.hour.toString().padLeft(2, '0')}:${_shiftEndTime!.minute.toString().padLeft(2, '0')}';

      // Create shift note with raw notes (draft)
      final rawNotes = _generateRawNotes();

      final String shiftNoteId;
      if (isEditing) {
        // Update existing shift note
        await apiService.updateShiftNote(
          shiftNoteId: widget.shiftNote!.id,
          rawNotes: rawNotes.isEmpty ? 'Draft shift note' : rawNotes,
        );
        shiftNoteId = widget.shiftNote!.id;
        print('✅ Draft shift note updated: $shiftNoteId');
      } else {
        // Create new draft shift note
        final shiftNoteResult = await apiService.createShiftNote(
          clientId: _selectedClientId!,
          userId: userId,
          shiftDate: shiftDateStr,
          startTime: startTimeStr,
          endTime: endTimeStr,
          rawNotes: rawNotes.isEmpty ? 'Draft shift note' : rawNotes,
        );
        shiftNoteId = shiftNoteResult['_id'] ?? shiftNoteResult['id'];
        print('✅ Draft shift note created: $shiftNoteId');
      }

      // Step 2: Create or update activity sessions if any
      if (_activitySessions.isNotEmpty) {
        print('📋 Processing ${_activitySessions.length} activity sessions...');
        final activitySessionService = ref.read(activitySessionServiceProvider);

        for (final sessionData in _activitySessions) {
          // Check if this is an existing session (has a backend ID that's not a UUID)
          final isExistingSession = sessionData.id.length < 36 || !sessionData.id.contains('-');
          
          if (isExistingSession && isEditing) {
            // Update existing session
            print('🔄 Updating existing session: ${sessionData.id}');
            
            // Prepare update data
            final updates = <String, dynamic>{
              'activity_id': sessionData.activityId,
              'session_start_time': sessionData.sessionStartTime.toIso8601String(),
              'session_end_time': sessionData.sessionEndTime.toIso8601String(),
              'duration_minutes': sessionData.durationMinutes,
              'location': sessionData.location,
              'session_notes': sessionData.sessionNotes,
              'participant_engagement': sessionData.participantEngagement.value,
              'goal_progress': sessionData.goalProgress.map((gp) => {
                'goal_id': gp.goalId,
                'progress_observed': gp.progressObserved,
                'evidence_notes': gp.evidenceNotes,
              }).toList(),
              'behavior_incidents': sessionData.behaviorIncidents.map((bi) => {
                'id': bi.id,
                'behaviors_displayed': bi.behaviorsDisplayed,
                'duration': bi.duration,
                'severity': bi.severity.toJson(),
                'self_harm': bi.selfHarm,
                'self_harm_types': bi.selfHarmTypes,
                'self_harm_count': bi.selfHarmCount,
                'initial_intervention': bi.initialIntervention,
                'intervention_description': bi.interventionDescription,
                'second_support_needed': bi.secondSupportNeeded,
                'second_support_description': bi.secondSupportDescription,
                'description': bi.description,
              }).toList(),
            };
            
            await activitySessionService.updateSession(
              sessionData.id,
              updates,
            );
            print('✅ Activity session updated: ${sessionData.activityTitle}');
            
            // Handle media updates
            final existingSession = await activitySessionService.getSessionById(sessionData.id);
            final existingMediaIds = existingSession.media.map((m) => m.storageId).toSet();
            final newMediaIds = sessionData.uploadedMedia.map((m) => m.storageId).toSet();
            
            // Remove media that was deleted
            for (final existingMedia in existingSession.media) {
              if (!newMediaIds.contains(existingMedia.storageId)) {
                await apiService.removeMediaFromSession(
                  sessionId: sessionData.id,
                  mediaId: existingMedia.id,
                );
                print('🗑️ Removed media: ${existingMedia.fileName}');
              }
            }
            
            // Add new media that wasn't there before
            for (final media in sessionData.uploadedMedia) {
              if (!existingMediaIds.contains(media.storageId)) {
                await apiService.addMediaToSession(
                  sessionId: sessionData.id,
                  storageId: media.storageId,
                  type: media.type.value,
                  fileName: media.fileName,
                  fileSize: media.fileSize,
                  mimeType: media.mimeType,
                );
                print('✅ Added media: ${media.fileName}');
              }
            }
          } else {
            // Create new session
            print('➕ Creating new session: ${sessionData.activityTitle}');
            
            final activitySession = ActivitySession(
              id: sessionData.id,
              activityId: sessionData.activityId,
              clientId: _selectedClientId!,
              stakeholderId: userId,
              shiftNoteId: shiftNoteId,
              sessionStartTime: sessionData.sessionStartTime,
              sessionEndTime: sessionData.sessionEndTime,
              durationMinutes: sessionData.durationMinutes,
              location: sessionData.location,
              sessionNotes: sessionData.sessionNotes,
              participantEngagement: sessionData.participantEngagement,
              goalProgress: sessionData.goalProgress,
              behaviorIncidents: sessionData.behaviorIncidents,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            final createdSession = await activitySessionService.createSession(activitySession);
            print('✅ Activity session created: ${sessionData.activityTitle}');

            await apiService.addActivitySessionToShiftNote(
              shiftNoteId: shiftNoteId,
              activitySessionId: createdSession.id,
            );
            print('🔗 Linked session to shift note');

            if (sessionData.uploadedMedia.isNotEmpty) {
              print('📸 Linking ${sessionData.uploadedMedia.length} media files to session...');
              for (final media in sessionData.uploadedMedia) {
                await apiService.addMediaToSession(
                  sessionId: createdSession.id,
                  storageId: media.storageId,
                  type: media.type.value,
                  fileName: media.fileName,
                  fileSize: media.fileSize,
                  mimeType: media.mimeType,
                );
                print('✅ Media linked: ${media.fileName}');
              }
            }
          }
        }
      }

      // Step 3: Refresh shift notes list
      ref.read(shiftNotesProvider.notifier).refresh();

      print('📝 Draft saved successfully');

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving draft: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingDraft = false);
      }
    }
  }

  /// Generate raw notes summary from activity sessions
  String _generateRawNotes() {
    if (_activitySessions.isEmpty) {
      return 'Shift completed';
    }

    final buffer = StringBuffer();
    buffer.writeln('Shift Summary:');
    buffer.writeln();

    for (var i = 0; i < _activitySessions.length; i++) {
      final session = _activitySessions[i];
      buffer.writeln('Activity ${i + 1}: ${session.activityTitle ?? 'Activity'}');
      buffer.writeln('Time: ${DateFormat('HH:mm').format(session.sessionStartTime)} - ${DateFormat('HH:mm').format(session.sessionEndTime)}');
      buffer.writeln('Location: ${session.location}');
      buffer.writeln('Engagement: ${session.participantEngagement.displayName}');

      if (session.goalProgress.isNotEmpty) {
        buffer.writeln('Goals worked on: ${session.goalProgress.length}');
      }

      if (session.behaviorIncidents.isNotEmpty) {
        buffer.writeln('Behaviors recorded: ${session.behaviorIncidents.length}');
      }

      if (session.sessionNotes.isNotEmpty) {
        buffer.writeln('Notes: ${session.sessionNotes}');
      }

      buffer.writeln();
    }

    return buffer.toString();
  }
}

// ==================== ACTIVITY SESSION DATA MODEL ====================
/// Temporary data model for activity session during creation
class ActivitySessionData {
  final String id;
  final String activityId;
  String? activityTitle;
  DateTime sessionStartTime;
  DateTime sessionEndTime;
  int durationMinutes;
  String location;
  ParticipantEngagement participantEngagement;
  List<GoalProgressEntry> goalProgress;
  List<BehaviorIncident> behaviorIncidents;
  String sessionNotes;
  List<UploadedMedia> uploadedMedia;

  ActivitySessionData({
    required this.id,
    required this.activityId,
    this.activityTitle,
    required this.sessionStartTime,
    required this.sessionEndTime,
    required this.durationMinutes,
    required this.location,
    required this.participantEngagement,
    this.goalProgress = const [],
    this.behaviorIncidents = const [],
    this.sessionNotes = '',
    this.uploadedMedia = const [],
  });
}

// ==================== ACTIVITY SESSION FORM SCREEN ====================
/// Form for adding/editing an activity session with inline behaviors
class ActivitySessionFormScreen extends ConsumerStatefulWidget {
  final String clientId;
  final DateTime shiftDate;
  final ActivitySessionData? existingSession;
  final Function(ActivitySessionData) onSave;

  const ActivitySessionFormScreen({
    super.key,
    required this.clientId,
    required this.shiftDate,
    this.existingSession,
    required this.onSave,
  });

  @override
  ConsumerState<ActivitySessionFormScreen> createState() =>
      _ActivitySessionFormScreenState();
}

class _ActivitySessionFormScreenState
    extends ConsumerState<ActivitySessionFormScreen> {
  final _uuid = const Uuid();
  final _sessionNotesController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedActivityId;
  String? _selectedActivityTitle;
  TimeOfDay? _sessionStartTime;
  TimeOfDay? _sessionEndTime;
  ParticipantEngagement _participantEngagement = ParticipantEngagement.moderate;
  final List<String> _selectedGoalIds = [];
  final List<BehaviorIncident> _behaviorIncidents = [];
  final List<UploadedMedia> _uploadedMedia = [];
  bool _isUploadingMedia = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSession != null) {
      _selectedActivityId = widget.existingSession!.activityId;
      _selectedActivityTitle = widget.existingSession!.activityTitle;
      _sessionStartTime = TimeOfDay.fromDateTime(widget.existingSession!.sessionStartTime);
      _sessionEndTime = TimeOfDay.fromDateTime(widget.existingSession!.sessionEndTime);
      _locationController.text = widget.existingSession!.location;
      _participantEngagement = widget.existingSession!.participantEngagement;
      _selectedGoalIds.addAll(widget.existingSession!.goalProgress.map((g) => g.goalId));
      _behaviorIncidents.addAll(widget.existingSession!.behaviorIncidents);
      _uploadedMedia.addAll(widget.existingSession!.uploadedMedia);
      _sessionNotesController.text = widget.existingSession!.sessionNotes;
    }
  }

  @override
  void dispose() {
    _sessionNotesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingSession != null ? 'Edit Activity Session' : 'Add Activity Session',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity Selection
            _buildSectionLabel('Activity'),
            const SizedBox(height: 8),
            _buildActivitySelector(),
            const SizedBox(height: 24),

            // Session Times
            Row(
              children: [
                Expanded(child: _buildTimeSelector('Start Time', _sessionStartTime, (time) {
                  setState(() => _sessionStartTime = time);
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeSelector('End Time', _sessionEndTime, (time) {
                  setState(() => _sessionEndTime = time);
                })),
              ],
            ),
            const SizedBox(height: 24),

            // Location
            _buildSectionLabel('Location'),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'e.g., In the home, At the park, In the community...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Participant Engagement
            _buildParticipantEngagementSelector(),
            const SizedBox(height: 24),

            // Goals Progressed
            _buildGoalsSelector(),
            const SizedBox(height: 24),

            // Behaviors Section
            _buildBehaviorsSection(),
            const SizedBox(height: 24),

            // Photos & Videos Section
            _buildMediaSection(),
            const SizedBox(height: 24),

            // Session Notes
            _buildSectionLabel('Session Notes'),
            const SizedBox(height: 8),
            TextField(
              controller: _sessionNotesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Additional notes about this activity session...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Activity Session',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildActivitySelector() {
    return InkWell(
      onTap: _selectActivity,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedActivityTitle ?? 'Select activity',
              style: TextStyle(
                fontSize: 16,
                color: _selectedActivityTitle != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay? time, Function(TimeOfDay) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selected = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
            );
            if (selected != null) {
              onSelect(selected);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  time?.format(context) ?? 'Select time',
                  style: TextStyle(
                    fontSize: 16,
                    color: time != null ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantEngagementSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Participant Engagement'),
        const SizedBox(height: 8),
        ...ParticipantEngagement.values.map((engagement) {
          final isSelected = _participantEngagement == engagement;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _participantEngagement = engagement),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.grey400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        engagement.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGoalsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('Goals Progressed'),
            TextButton.icon(
              onPressed: _selectGoals,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Select Goals'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedGoalIds.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Center(
              child: Text(
                'No goals selected',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedGoalIds.map((goalId) {
              return Chip(
                label: Text('Goal ${_selectedGoalIds.indexOf(goalId) + 1}'),
                onDeleted: () {
                  setState(() => _selectedGoalIds.remove(goalId));
                },
                backgroundColor: AppColors.success.withValues(alpha: 0.1),
                deleteIcon: const Icon(Icons.close, size: 16),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBehaviorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('Behaviors of Concern (${_behaviorIncidents.length})'),
            TextButton.icon(
              onPressed: _addBehaviorIncident,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Behavior'),
              style: TextButton.styleFrom(foregroundColor: AppColors.burntOrange),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_behaviorIncidents.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Center(
              child: Text(
                'No behaviors recorded',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ..._behaviorIncidents.asMap().entries.map((entry) {
            final index = entry.key;
            final behavior = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.burntOrange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.burntOrange.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Behavior ${index + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${behavior.behaviorsDisplayed.join(", ")} • ${behavior.severity.displayName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editBehaviorIncident(index),
                          color: AppColors.primary,
                          tooltip: 'Edit behavior',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () {
                            setState(() => _behaviorIncidents.removeAt(index));
                          },
                          color: AppColors.error,
                          tooltip: 'Delete behavior',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('Photos & Videos (${_uploadedMedia.length})'),
            if (!_isUploadingMedia)
              TextButton.icon(
                onPressed: _showMediaOptions,
                icon: const Icon(Icons.add_a_photo, size: 16),
                label: const Text('Add Media'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isUploadingMedia)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Uploading media...',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else if (_uploadedMedia.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Center(
              child: Text(
                'No photos or videos added',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _uploadedMedia.length,
            itemBuilder: (context, index) {
              final media = _uploadedMedia[index];
              return _buildMediaThumbnail(media, index);
            },
          ),
      ],
    );
  }

  Widget _buildMediaThumbnail(UploadedMedia media, int index) {
    return Consumer(
      builder: (context, ref, _) {
        return FutureBuilder<String>(
          future: ref.read(mediaUploadServiceProvider).getMediaUrl(media.storageId),
          builder: (context, snapshot) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      media.type == MediaType.photo
                                          ? Icons.photo
                                          : Icons.videocam,
                                      size: 32,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        media.fileName,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : snapshot.hasData
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (media.type == MediaType.photo)
                                        CachedNetworkImage(
                                          imageUrl: snapshot.data!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 32,
                                                  color: AppColors.textSecondary,
                                                ),
                                                const SizedBox(height: 4),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                  child: Text(
                                                    media.fileName,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          color: Colors.black87,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.play_circle_outline,
                                                  size: 48,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(height: 4),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                  child: Text(
                                                    media.fileName,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white70,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      // Type badge
                                      Positioned(
                                        bottom: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            media.type == MediaType.photo ? 'Photo' : 'Video',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          media.type == MediaType.photo
                                              ? Icons.photo
                                              : Icons.videocam,
                                          size: 32,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            media.fileName,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _replaceMedia(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeMedia(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Photo or Video',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMediaFromCamera(MediaType.photo);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: const Text('Choose Photo from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMediaFromGallery(MediaType.photo);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldenAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.videocam, color: AppColors.goldenAmber),
                ),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMediaFromCamera(MediaType.video);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldenAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.video_library, color: AppColors.goldenAmber),
                ),
                title: const Text('Choose Video from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMediaFromGallery(MediaType.video);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadMediaFromGallery(MediaType type, {int? replaceIndex}) async {
    setState(() => _isUploadingMedia = true);

    try {
      final mediaService = ref.read(mediaUploadServiceProvider);
      UploadedMedia? uploaded;

      if (type == MediaType.photo) {
        uploaded = await mediaService.pickAndUploadImageFromGallery();
      } else {
        uploaded = await mediaService.pickAndUploadVideoFromGallery();
      }

      if (uploaded != null) {
        setState(() {
          if (replaceIndex != null) {
            _uploadedMedia[replaceIndex] = uploaded!;
          } else {
            _uploadedMedia.add(uploaded!);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${type == MediaType.photo ? 'Photo' : 'Video'} uploaded successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error uploading from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingMedia = false);
      }
    }
  }

  Future<void> _uploadMediaFromCamera(MediaType type, {int? replaceIndex}) async {
    setState(() => _isUploadingMedia = true);

    try {
      final mediaService = ref.read(mediaUploadServiceProvider);
      UploadedMedia? uploaded;

      if (type == MediaType.photo) {
        uploaded = await mediaService.pickAndUploadImageFromCamera();
      } else {
        uploaded = await mediaService.pickAndUploadVideoFromCamera();
      }

      if (uploaded != null) {
        setState(() {
          if (replaceIndex != null) {
            _uploadedMedia[replaceIndex] = uploaded!;
          } else {
            _uploadedMedia.add(uploaded!);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${type == MediaType.photo ? 'Photo' : 'Video'} captured and uploaded!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error uploading from camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingMedia = false);
      }
    }
  }

  void _replaceMedia(int index) {
    // Show media options to replace the existing media
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Replace Media',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMediaFromCamera(MediaType.photo, replaceIndex: index);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: const Text('Choose Photo from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMediaFromGallery(MediaType.photo, replaceIndex: index);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldenAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.videocam, color: AppColors.goldenAmber),
                ),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMediaFromCamera(MediaType.video, replaceIndex: index);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldenAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.video_library, color: AppColors.goldenAmber),
                ),
                title: const Text('Choose Video from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadMediaFromGallery(MediaType.video, replaceIndex: index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeMedia(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Media?'),
        content: Text('Remove ${_uploadedMedia[index].fileName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _uploadedMedia.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectActivity() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Fetch activities
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final activities = await apiService.listActivities(
        clientId: widget.clientId,
        limit: 50,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (activities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No activities found for this client'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Show selector
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Select Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return ListTile(
                        title: Text(activity.title),
                        subtitle: Text(activity.activityType.displayName),
                        onTap: () {
                          setState(() {
                            _selectedActivityId = activity.id;
                            _selectedActivityTitle = activity.title;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading activities: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectGoals() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final goals = await apiService.listGoals(
        clientId: widget.clientId,
        archived: false,
        limit: 50,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (goals.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No goals found for this client'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Show selector with checkboxes
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Select Goals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        final isSelected = _selectedGoalIds.contains(goal.id);
                        return CheckboxListTile(
                          title: Text(goal.title),
                          subtitle: Text(goal.category.displayName),
                          value: isSelected,
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                _selectedGoalIds.add(goal.id);
                              } else {
                                _selectedGoalIds.remove(goal.id);
                              }
                            });
                            setState(() {});
                          },
                          activeColor: AppColors.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Done (${_selectedGoalIds.length} selected)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading goals: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _addBehaviorIncident() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BehaviorIncidentFormScreen(
          onSave: (behavior) {
            setState(() {
              _behaviorIncidents.add(behavior);
            });
          },
        ),
      ),
    );
  }

  void _editBehaviorIncident(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BehaviorIncidentFormScreen(
          existingIncident: _behaviorIncidents[index],
          onSave: (updatedBehavior) {
            setState(() {
              _behaviorIncidents[index] = updatedBehavior;
            });
          },
        ),
      ),
    );
  }

  void _handleSave() {
    // Validate
    if (_selectedActivityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an activity'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_sessionStartTime == null || _sessionEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select session start and end times'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create session data
    final sessionStartDateTime = DateTime(
      widget.shiftDate.year,
      widget.shiftDate.month,
      widget.shiftDate.day,
      _sessionStartTime!.hour,
      _sessionStartTime!.minute,
    );

    final sessionEndDateTime = DateTime(
      widget.shiftDate.year,
      widget.shiftDate.month,
      widget.shiftDate.day,
      _sessionEndTime!.hour,
      _sessionEndTime!.minute,
    );

    // Calculate duration in minutes
    final durationMinutes = sessionEndDateTime.difference(sessionStartDateTime).inMinutes;

    // Create goal progress entries
    final goalProgress = _selectedGoalIds.map((goalId) {
      return GoalProgressEntry(
        goalId: goalId,
        progressObserved: 5, // Default value - can be enhanced later
        evidenceNotes: 'Documented in session',
      );
    }).toList();

    final session = ActivitySessionData(
      id: widget.existingSession?.id ?? _uuid.v4(),
      activityId: _selectedActivityId!,
      activityTitle: _selectedActivityTitle,
      sessionStartTime: sessionStartDateTime,
      sessionEndTime: sessionEndDateTime,
      durationMinutes: durationMinutes,
      location: _locationController.text.trim(),
      participantEngagement: _participantEngagement,
      goalProgress: goalProgress,
      behaviorIncidents: _behaviorIncidents,
      sessionNotes: _sessionNotesController.text.trim(),
      uploadedMedia: _uploadedMedia,
    );

    widget.onSave(session);
    Navigator.pop(context);
  }
}

// ==================== BEHAVIOR INCIDENT FORM SCREEN ====================
/// Form for adding/editing a behavior incident with all details
class BehaviorIncidentFormScreen extends StatefulWidget {
  final Function(BehaviorIncident) onSave;
  final BehaviorIncident? existingIncident; // Optional: for editing

  const BehaviorIncidentFormScreen({
    super.key,
    required this.onSave,
    this.existingIncident,
  });

  @override
  State<BehaviorIncidentFormScreen> createState() =>
      _BehaviorIncidentFormScreenState();
}

class _BehaviorIncidentFormScreenState
    extends State<BehaviorIncidentFormScreen> {
  final _uuid = const Uuid();
  final _descriptionController = TextEditingController();
  final _interventionDescriptionController = TextEditingController();
  final _supportDescriptionController = TextEditingController();

  // Behavior fields (from behavior report)
  final Map<String, bool> _behaviours = {
    'Verbal Aggression': false,
    'Physical Aggression': false,
    'Wandering': false,
    'Withdrawal': false,
    'Harm to self (eg. head banging)': false,
    'Damage to Property': false,
    'Inappropriate touching of another': false,
    'Public Masturbation': false,
    'Shared a lie or a fictional story': false,
    'Risk of safety (e.g running into road towards car/s)': false,
    'Leaving the home unsupervised': false,
    'Moving neighbours bins without permission': false,
    'Approaching neighbours house without invitation with intention to socially engage': false,
    'Attempting to kiss/touch a girl': false,
    'Other': false,
  };

  String? _duration;
  BehaviorSeverity? _severity;
  bool _selfHarm = false;

  final Map<String, bool> _selfHarmTypes = {
    'Bite': false,
    'Scratch': false,
    'Hit his head': false,
    'Consuming non-food items': false,
    'Bang his head': false,
    'No Harm': false,
    'Other': false,
  };

  int _harmCount = 0;
  String? _initialIntervention;

  final Map<String, bool> _supportNeeds = {
    'Ensure client\'s safety': false,
    'Prevent harm to others': false,
    'Effectively manage transitions or high risk scenarios': false,
    'All': false,
    'No additional support needed': false,
  };

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing
    if (widget.existingIncident != null) {
      final incident = widget.existingIncident!;
      
      // Set behaviors
      for (final behavior in incident.behaviorsDisplayed) {
        if (_behaviours.containsKey(behavior)) {
          _behaviours[behavior] = true;
        }
      }
      
      _duration = incident.duration;
      _severity = incident.severity;
      _selfHarm = incident.selfHarm;
      
      // Set self-harm types
      for (final type in incident.selfHarmTypes) {
        if (_selfHarmTypes.containsKey(type)) {
          _selfHarmTypes[type] = true;
        }
      }
      
      _harmCount = incident.selfHarmCount;
      _initialIntervention = incident.initialIntervention;
      _interventionDescriptionController.text = incident.interventionDescription ?? '';
      
      // Set support needs
      for (final need in incident.secondSupportNeeded) {
        if (_supportNeeds.containsKey(need)) {
          _supportNeeds[need] = true;
        }
      }
      
      _supportDescriptionController.text = incident.secondSupportDescription ?? '';
      _descriptionController.text = incident.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _interventionDescriptionController.dispose();
    _supportDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingIncident != null ? 'Edit Behavior' : 'Record Behavior',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Behaviors displayed
            _buildSectionLabel('What behavior was displayed?'),
            const SizedBox(height: 8),
            const Text(
              'Select all that apply',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ..._behaviours.keys.map((behavior) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCheckbox(behavior, _behaviours[behavior]!, (val) {
                    setState(() => _behaviours[behavior] = val!);
                  }),
                )),
            const SizedBox(height: 24),

            // Duration
            _buildSectionLabel('Duration'),
            const SizedBox(height: 12),
            ...[
              '0 - 5 minutes',
              '6 - 10 minutes',
              '11 - 15 minutes',
              '16 - 30 minutes',
              'Over 30 minutes',
              'Other',
            ].map((duration) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRadio(duration, _duration, (val) {
                    setState(() => _duration = val);
                  }),
                )),
            const SizedBox(height: 24),

            // Severity
            _buildSectionLabel('Severity'),
            const SizedBox(height: 12),
            ...[
              BehaviorSeverity.low,
              BehaviorSeverity.medium,
              BehaviorSeverity.high,
            ].map((severity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRadio(
                    severity.displayName,
                    _severity?.displayName,
                    (val) {
                      setState(() => _severity = severity);
                    },
                  ),
                )),
            const SizedBox(height: 24),

            // Self-harm
            _buildSectionLabel('Did self-harm occur?'),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Yes'),
              value: _selfHarm,
              onChanged: (val) {
                setState(() => _selfHarm = val!);
              },
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),

            if (_selfHarm) ...[
              const SizedBox(height: 12),
              _buildSectionLabel('Self-harm types'),
              const SizedBox(height: 12),
              ..._selfHarmTypes.keys.map((type) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildCheckbox(type, _selfHarmTypes[type]!, (val) {
                      setState(() => _selfHarmTypes[type] = val!);
                    }),
                  )),
              const SizedBox(height: 16),
              _buildSectionLabel('How many times?'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(12, (index) {
                  final label = index == 11 ? '10+' : index.toString();
                  final isSelected = _harmCount == index;
                  return InkWell(
                    onTap: () => setState(() => _harmCount = index),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.white,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: 24),

            // Initial Intervention
            _buildSectionLabel('Initial Intervention'),
            const SizedBox(height: 12),
            ...[
              'Verbal Redirection',
              'Escape Environment',
              'Deflection with body',
              'Distraction with items',
              'No intervention required',
            ].map((intervention) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRadio(intervention, _initialIntervention, (val) {
                    setState(() => _initialIntervention = val);
                  }),
                )),
            const SizedBox(height: 12),
            TextField(
              controller: _interventionDescriptionController,
              decoration: InputDecoration(
                hintText: 'Describe the intervention...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Second support needed
            _buildSectionLabel('Could a second support person help?'),
            const SizedBox(height: 8),
            const Text(
              'Select all that apply',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ..._supportNeeds.keys.map((need) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCheckbox(need, _supportNeeds[need]!, (val) {
                    setState(() => _supportNeeds[need] = val!);
                  }),
                )),
            const SizedBox(height: 12),
            TextField(
              controller: _supportDescriptionController,
              decoration: InputDecoration(
                hintText: 'Describe how second support would help...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Detailed description
            _buildSectionLabel('Detailed Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Describe what happened in detail...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burntOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Behavior',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildRadio(String label, String? groupValue, ValueChanged<String?> onChanged) {
    final isSelected = groupValue == label;
    return InkWell(
      onTap: () => onChanged(label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    // Validate
    final selectedBehaviors = _behaviours.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedBehaviors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one behavior'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select duration'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_severity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select severity'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_initialIntervention == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select initial intervention'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a detailed description'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Collect self-harm types
    final selfHarmTypes = _selfHarm
        ? _selfHarmTypes.entries.where((e) => e.value).map((e) => e.key).toList()
        : ['No Harm'];

    // Collect support needs
    final supportNeeds = _supportNeeds.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    // Create or update behavior incident
    final incident = BehaviorIncident(
      id: widget.existingIncident?.id ?? _uuid.v4(),
      behaviorsDisplayed: selectedBehaviors,
      duration: _duration!,
      severity: _severity!,
      selfHarm: _selfHarm,
      selfHarmTypes: selfHarmTypes,
      selfHarmCount: _selfHarm ? _harmCount : 0,
      initialIntervention: _initialIntervention!,
      interventionDescription: _interventionDescriptionController.text.trim().isEmpty
          ? null
          : _interventionDescriptionController.text.trim(),
      secondSupportNeeded: supportNeeds.isEmpty ? ['No additional support needed'] : supportNeeds,
      secondSupportDescription: _supportDescriptionController.text.trim().isEmpty
          ? null
          : _supportDescriptionController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    widget.onSave(incident);
    Navigator.pop(context);
  }
}
