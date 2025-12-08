import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../data/models/activity_session.dart';
import '../../../data/models/activity_session_enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/client_details_provider.dart';
import '../shift_notes/unified_shift_note_wizard.dart';

/// Screen for guardians to create standalone activity sessions
/// with behavior incidents (without requiring a shift note)
class CreateActivitySessionScreen extends ConsumerStatefulWidget {
  const CreateActivitySessionScreen({super.key});

  @override
  ConsumerState<CreateActivitySessionScreen> createState() =>
      _CreateActivitySessionScreenState();
}

class _CreateActivitySessionScreenState
    extends ConsumerState<CreateActivitySessionScreen> {
  final _uuid = const Uuid();

  // Step control
  int _currentStep = 0;

  // Step 1: Client & Date Selection
  String? _selectedClientId;
  String? _selectedClientName;
  DateTime _activityDate = DateTime.now();

  // Step 2: Activity Sessions
  final List<ActivitySessionData> _activitySessions = [];

  // Loading state
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final clientsState = ref.watch(clientsListCachedProvider);

    // Auto-select first client if none selected and clients are available
    if (_selectedClientId == null &&
        clientsState.clients.isNotEmpty &&
        !clientsState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedClientId = clientsState.clients.first.id;
            _selectedClientName = clientsState.clients.first.name;
          });
        }
      });
    }

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
            title: const Text('Client & Date'),
            content: _buildStep1ClientSelection(clientsState),
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
      title: const Text(
        'Add Activity Session',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ==================== STEP 1: CLIENT & DATE ====================
  Widget _buildStep1ClientSelection(ClientsListState clientsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select the client and date for this activity',
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
          onTap: () => _showClientSelector(clientsState),
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
                if (clientsState.isLoading && _selectedClientName == null)
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Loading clients...',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    _selectedClientName ?? 'Select client',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedClientName != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Date Picker
        _buildSectionLabel('Activity Date'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _activityDate,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _activityDate = date);
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
                const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_activityDate),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          'Add activities with behaviors and progress notes',
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

  // ==================== STEP 3: REVIEW ====================
  Widget _buildStep3Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review your activity documentation',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Summary
        _buildReviewSection(
          'Details',
          [
            _buildReviewItem('Client', _selectedClientName ?? 'Not selected'),
            _buildReviewItem(
                'Date', DateFormat('EEEE, MMMM d, yyyy').format(_activityDate)),
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

        // Submit Button
        _buildSubmitButton(),
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

  void _showClientSelector(ClientsListState clientsState) {
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
            if (clientsState.clients.isEmpty && !clientsState.isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No clients available',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...clientsState.clients.map((client) {
                final isSelected = _selectedClientId == client.id;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.deepBrown, AppColors.burntOrange],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(client.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text('Age: ${client.age} years'),
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
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
          shiftDate: _activityDate,
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
          shiftDate: _activityDate,
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
        content:
            const Text('This will remove the activity session and all its data.'),
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
          if (details.currentStep > 0) ...[ const SizedBox(width: 12),
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
            : const Text(
                'Submit Activity Sessions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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

      print('📝 Creating ${_activitySessions.length} standalone activity sessions...');
      final activitySessionService = ref.read(activitySessionServiceProvider);
      final apiService = ref.read(mcpApiServiceProvider);

      for (final sessionData in _activitySessions) {
        print('➕ Creating session: ${sessionData.activityTitle}');

        // Convert ActivitySessionData to ActivitySession
        final activitySession = ActivitySession(
          id: sessionData.id,
          activityId: sessionData.activityId,
          clientId: _selectedClientId!,
          stakeholderId: userId,
          shiftNoteId: null, // No shift note for standalone sessions
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

        // Create session
        final createdSession =
            await activitySessionService.createSession(activitySession);
        print('✅ Activity session created: ${sessionData.activityTitle}');

        // Link uploaded media to session
        if (sessionData.uploadedMedia.isNotEmpty) {
          print(
              '📸 Linking ${sessionData.uploadedMedia.length} media files to session...');
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

      print('✅ All activity sessions created successfully');

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity sessions submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ Error submitting activity sessions: $e');
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
}
