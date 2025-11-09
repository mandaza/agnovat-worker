import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../data/models/activity.dart';
import '../../../data/models/client.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/shift_note.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/shift_notes_provider.dart';
import 'ai_formatting_screen.dart';

/// Create Shift Note Screen
/// Form to document a new shift with all required details
/// Can also be used to edit existing shift notes
class CreateShiftNoteScreen extends ConsumerStatefulWidget {
  final ShiftNote? shiftNote; // Optional: for editing existing shift notes
  
  const CreateShiftNoteScreen({
    super.key,
    this.shiftNote,
  });

  @override
  ConsumerState<CreateShiftNoteScreen> createState() =>
      _CreateShiftNoteScreenState();
}

class _CreateShiftNoteScreenState
    extends ConsumerState<CreateShiftNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _locationController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _behavioursController = TextEditingController();
  final _progressNotesController = TextEditingController();

  // Form values
  String? _selectedClientId;
  String? _selectedClientName;
  DateTime _selectedDate = DateTime.now();
  String _selectedShiftType = 'Afternoon';
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<String> _selectedActivityIds = []; // Selected activity IDs
  List<String> _selectedGoalIds = []; // Selected goal IDs
  List<String> _locations = []; // Multiple locations

  bool _isLoading = false;
  bool _isSavingDraft = false;

  @override
  void initState() {
    super.initState();
    
    // If editing an existing shift note, pre-fill the form
    if (widget.shiftNote != null) {
      _preFillFormData(widget.shiftNote!);
    } else {
      // Initialize with first available client for new notes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final dashboardState = ref.read(dashboardProvider);
        if (dashboardState.assignedClients.isNotEmpty && _selectedClientId == null) {
          setState(() {
            _selectedClientId = dashboardState.assignedClients.first.id;
            _selectedClientName = dashboardState.assignedClients.first.name;
          });
        }
      });
    }
  }
  
  /// Pre-fill form data when editing an existing shift note
  void _preFillFormData(ShiftNote shiftNote) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get client name from dashboard
      final dashboardState = ref.read(dashboardProvider);
      String clientName = 'Unknown Client';
      
      try {
        final client = dashboardState.assignedClients.firstWhere(
          (c) => c.id == shiftNote.clientId,
        );
        clientName = client.name;
      } catch (e) {
        if (dashboardState.assignedClients.isNotEmpty) {
          clientName = dashboardState.assignedClients.first.name;
        }
      }
      
      setState(() {
        // Set client
        _selectedClientId = shiftNote.clientId;
        _selectedClientName = clientName;
        
        // Set date
        _selectedDate = DateTime.parse(shiftNote.shiftDate);
        
        // Set times
        final startParts = shiftNote.startTime.split(':');
        _startTime = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
        
        final endParts = shiftNote.endTime.split(':');
        _endTime = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
        
        // Determine shift type based on start time
        final startHour = _startTime!.hour;
        if (startHour >= 5 && startHour < 12) {
          _selectedShiftType = 'Morning';
        } else if (startHour >= 12 && startHour < 17) {
          _selectedShiftType = 'Afternoon';
        } else if (startHour >= 17 && startHour < 21) {
          _selectedShiftType = 'Evening';
        } else {
          _selectedShiftType = 'Overnight';
        }
        
        // Set locations (multiple)
        if (shiftNote.primaryLocations != null && shiftNote.primaryLocations!.isNotEmpty) {
          _locations = List.from(shiftNote.primaryLocations!);
        }
        
        // Set activity IDs
        if (shiftNote.activityIds != null && shiftNote.activityIds!.isNotEmpty) {
          _selectedActivityIds = List.from(shiftNote.activityIds!);
        }
        
        // Parse raw notes and populate fields
        _parseAndFillRawNotes(shiftNote.rawNotes);
      });
    });
  }
  
  /// Parse raw notes and fill individual fields
  void _parseAndFillRawNotes(String rawNotes) {
    final lines = rawNotes.split('\n');
    String currentSection = '';
    final StringBuffer activitiesBuffer = StringBuffer();
    final StringBuffer behavioursBuffer = StringBuffer();
    final StringBuffer progressBuffer = StringBuffer();
    
    for (final line in lines) {
      if (line.startsWith('Activities Completed:')) {
        currentSection = 'activities';
      } else if (line.startsWith('Behaviours & Engagement:')) {
        currentSection = 'behaviours';
      } else if (line.startsWith('Progress Notes:')) {
        currentSection = 'progress';
      } else if (line.trim().isNotEmpty) {
        if (currentSection == 'activities') {
          activitiesBuffer.writeln(line);
        } else if (currentSection == 'behaviours') {
          behavioursBuffer.writeln(line);
        } else if (currentSection == 'progress') {
          progressBuffer.writeln(line);
        }
      }
    }
    
    _activitiesController.text = activitiesBuffer.toString().trim();
    _behavioursController.text = behavioursBuffer.toString().trim();
    _progressNotesController.text = progressBuffer.toString().trim();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _activitiesController.dispose();
    _behavioursController.dispose();
    _progressNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client selector
                      _buildClientSelector(),
                      const SizedBox(height: 24),

                      // Date and Shift Type row
                      Row(
                        children: [
                          Expanded(child: _buildDatePicker()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildShiftTypeSelector()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Start Time and End Time row
                      Row(
                        children: [
                          Expanded(child: _buildStartTimePicker()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildEndTimePicker()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Location
                      _buildLocationField(),
                      const SizedBox(height: 24),

                      // Activities Completed
                      _buildActivitiesField(),
                      const SizedBox(height: 24),

                      // Behaviours & Engagement
                      _buildBehavioursField(),
                      const SizedBox(height: 24),

                      // Goal Progress selector
                      _buildGoalProgressSelector(),
                      const SizedBox(height: 24),

                      // Progress Notes
                      _buildProgressNotesField(),
                      const SizedBox(height: 32),

                      // Format with AI button
                      _buildFormatWithAIButton(),
                      const SizedBox(height: 24),

                      // Save buttons
                      _buildSaveShiftNoteButton(),
                      const SizedBox(height: 12),
                      _buildSaveAsDraftButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    final isEditing = widget.shiftNote != null;
    
    return AppBar(
      backgroundColor: Colors.white,
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
        isEditing ? 'Edit Shift Note' : 'Create Shift Note',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// Build client selector
  Widget _buildClientSelector() {
    final dashboardState = ref.watch(dashboardProvider);
    final clients = dashboardState.assignedClients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Client',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showClientSelector(clients),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedClientName ?? 'Select client',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedClientName != null 
                        ? AppColors.textPrimary 
                        : AppColors.textSecondary,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Show client selector dialog
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

  /// Build date picker
  Widget _buildDatePicker() {
    final isEditing = widget.shiftNote != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEditing ? null : () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 7)),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isEditing ? AppColors.grey100.withOpacity(0.5) : AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: isEditing ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build shift type selector
  Widget _buildShiftTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shift Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showShiftTypeSelector();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedShiftType,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build start time picker
  Widget _buildStartTimePicker() {
    final isEditing = widget.shiftNote != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEditing ? null : () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _startTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              setState(() => _startTime = time);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isEditing ? AppColors.grey100.withOpacity(0.5) : AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  _startTime != null
                      ? _startTime!.format(context)
                      : 'Select time',
                  style: TextStyle(
                    fontSize: 14,
                    color: isEditing 
                        ? AppColors.textSecondary 
                        : (_startTime != null ? AppColors.textPrimary : AppColors.textSecondary),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build end time picker
  Widget _buildEndTimePicker() {
    final isEditing = widget.shiftNote != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'End Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEditing ? null : () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _endTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              setState(() => _endTime = time);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isEditing ? AppColors.grey100.withOpacity(0.5) : AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  _endTime != null ? _endTime!.format(context) : 'Select time',
                  style: TextStyle(
                    fontSize: 14,
                    color: isEditing 
                        ? AppColors.textSecondary 
                        : (_endTime != null ? AppColors.textPrimary : AppColors.textSecondary),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build location field
  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Locations',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _addLocation,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Location'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_locations.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No locations added',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ..._locations.asMap().entries.map((entry) {
            final index = entry.key;
            final location = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => _removeLocation(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  /// Add location dialog
  void _addLocation() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter location',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _locations.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Remove location
  void _removeLocation(int index) {
    setState(() {
      _locations.removeAt(index);
    });
  }

  /// Build activities field
  Widget _buildActivitiesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activities Completed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _selectedClientId != null ? _selectActivities : null,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Select Activities'),
              style: TextButton.styleFrom(
                foregroundColor: _selectedClientId != null ? AppColors.primary : AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedActivityIds.isNotEmpty)
          FutureBuilder<List<Activity>>(
            future: _fetchClientActivities(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedActivityIds.map((activityId) {
                      try {
                        final activity = snapshot.data!.firstWhere((a) => a.id == activityId);
                        return Chip(
                          label: Text(activity.title),
                          onDeleted: () {
                            setState(() {
                              _selectedActivityIds.remove(activityId);
                            });
                          },
                          backgroundColor: AppColors.goldenAmber.withOpacity(0.1),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        );
                      } catch (e) {
                        return const SizedBox.shrink();
                      }
                    }).toList(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        TextFormField(
          controller: _activitiesController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Add additional activity notes...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  /// Fetch client-specific activities
  Future<List<Activity>> _fetchClientActivities() async {
    if (_selectedClientId == null) return [];
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      return await apiService.listActivities(
        clientId: _selectedClientId,
        limit: 50,
      );
    } catch (e) {
      print('Error fetching activities: $e');
      return [];
    }
  }

  /// Select activities dialog
  Future<void> _selectActivities() async {
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Fetch client activities
    final activities = await _fetchClientActivities();
    
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
                  'Select Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select activities completed during this shift',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      final isSelected = _selectedActivityIds.contains(activity.id);
                      return CheckboxListTile(
                        title: Text(activity.title),
                        subtitle: Text(activity.activityType.displayName),
                        value: isSelected,
                        onChanged: (value) {
                          setModalState(() {
                            if (value == true) {
                              _selectedActivityIds.add(activity.id);
                            } else {
                              _selectedActivityIds.remove(activity.id);
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
                    child: Text('Done (${_selectedActivityIds.length} selected)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build behaviours field
  Widget _buildBehavioursField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Behaviours & Engagement',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _behavioursController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Note any behaviours, mood, and level of engagement...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please note behaviours and engagement';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build goal progress selector
  Widget _buildGoalProgressSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Goals Worked On',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _selectedClientId != null ? _selectGoals : null,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Select Goals'),
              style: TextButton.styleFrom(
                foregroundColor: _selectedClientId != null ? AppColors.primary : AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedGoalIds.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No goals selected',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          FutureBuilder<List<Goal>>(
            future: _fetchClientGoals(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedGoalIds.map((goalId) {
                    try {
                      final goal = snapshot.data!.firstWhere((g) => g.id == goalId);
                      return Chip(
                        label: Text(goal.title),
                        onDeleted: () {
                          setState(() {
                            _selectedGoalIds.remove(goalId);
                          });
                        },
                        backgroundColor: AppColors.secondary.withOpacity(0.1),
                        deleteIcon: const Icon(Icons.close, size: 16),
                      );
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
      ],
    );
  }

  /// Fetch client-specific goals
  Future<List<Goal>> _fetchClientGoals() async {
    if (_selectedClientId == null) return [];
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      return await apiService.listGoals(
        clientId: _selectedClientId,
        archived: false,
        limit: 50,
      );
    } catch (e) {
      print('Error fetching goals: $e');
      return [];
    }
  }

  /// Select goals dialog
  Future<void> _selectGoals() async {
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Fetch client goals
    final goals = await _fetchClientGoals();
    
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
                const SizedBox(height: 8),
                Text(
                  'Select the goals that were worked on during this shift',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
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
  }

  /// Build progress notes field
  Widget _buildProgressNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Notes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _progressNotesController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe progress made towards the selected goal...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  /// Build Format with AI button
  Widget _buildFormatWithAIButton() {
    return InkWell(
      onTap: _formatWithAI,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepBrown, AppColors.burntOrange],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBrown.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Format with AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Let Agnovat Assistant format your notes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Save Shift Note button
  Widget _buildSaveShiftNoteButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveShiftNote,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBrown,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: AppColors.deepBrown.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Shift Note',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Build Save as Draft button
  Widget _buildSaveAsDraftButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _isSavingDraft ? null : _saveAsDraft,
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
            : const Text(
                'Save as Draft',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }

  /// Show shift type selector
  void _showShiftTypeSelector() {
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
              'Select Shift Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...['Morning', 'Afternoon', 'Evening', 'Overnight', 'Full Day'].map((type) {
              final isSelected = _selectedShiftType == type;
              return ListTile(
                title: Text(type),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedShiftType = type);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Format notes with AI
  Future<void> _formatWithAI() async {
    // Gather all notes into a single string
    final originalNotes = '''
${_activitiesController.text.isNotEmpty ? 'Activities: ${_activitiesController.text}\n\n' : ''}${_behavioursController.text.isNotEmpty ? 'Behaviours & Engagement: ${_behavioursController.text}\n\n' : ''}${_progressNotesController.text.isNotEmpty ? 'Progress Notes: ${_progressNotesController.text}' : ''}'''
        .trim();

    if (originalNotes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some notes before formatting'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navigate to AI formatting screen
    final formattedNotes = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => AiFormattingScreen(
          shiftNoteId: widget.shiftNote?.id, // Pass ID if editing existing note
          originalNotes: originalNotes,
        ),
      ),
    );

    // If user chose to use formatted version, update progress notes
    if (formattedNotes != null && mounted) {
      setState(() {
        _progressNotesController.text = formattedNotes;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formatted notes applied successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Save shift note
  Future<void> _saveShiftNote() async {
    // Validate client selection
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end times'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final authState = ref.read(authProvider);
      final isEditing = widget.shiftNote != null;

      print(isEditing ? '✏️ Updating shift note...' : '💾 Creating shift note...');

      // Get user ID from current user
      final userId = authState.user?.id;
      if (userId == null) {
        throw Exception('User ID not found. Please sign in again.');
      }

      // Use actual selected client ID
      final clientId = _selectedClientId!;

      // Format date and time
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedStartTime = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
      final formattedEndTime = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

      // Combine all notes into raw_notes
      final rawNotes = '''
Activities Completed:
${_activitiesController.text}

Behaviours & Engagement:
${_behavioursController.text}

Progress Notes:
${_progressNotesController.text}'''
          .trim();

      // Primary locations from multi-select
      final locations = _locations.isNotEmpty ? _locations : null;
      
      // Activity IDs from multi-select
      final activityIds = _selectedActivityIds.isNotEmpty ? _selectedActivityIds : null;

      final Map<String, dynamic> result;

      if (isEditing) {
        // Update existing shift note
        // Note: Convex doesn't allow updating shift date/time after creation
        print('   - shift_note_id: ${widget.shiftNote!.id}');
        print('   - updating notes, locations, and activities only');

        result = await apiService.updateShiftNote(
          shiftNoteId: widget.shiftNote!.id,
          primaryLocations: locations,
          rawNotes: rawNotes,
          activityIds: activityIds,
        );

        print('✅ Shift note updated successfully');
      } else {
        // Create new shift note
        print('   - client_id: $clientId');
        print('   - user_id: $userId');
        print('   - shift_date: $formattedDate');
        print('   - start_time: $formattedStartTime');
        print('   - end_time: $formattedEndTime');

        result = await apiService.createShiftNote(
          clientId: clientId,
          userId: userId,
          shiftDate: formattedDate,
          startTime: formattedStartTime,
          endTime: formattedEndTime,
          primaryLocations: locations,
          rawNotes: rawNotes,
          activityIds: activityIds,
        );

        print('✅ Shift note created successfully: ${result['id']}');
      }

      // Refresh shift notes list
      ref.read(shiftNotesProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing 
                ? 'Shift note updated successfully!' 
                : 'Shift note saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() => _isLoading = false);

      print('❌ Failed to save shift note: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save shift note: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Save as draft
  Future<void> _saveAsDraft() async {
    // Validate client selection
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end times'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSavingDraft = true);

    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final authState = ref.read(authProvider);
      final isEditing = widget.shiftNote != null;

      print(isEditing ? '✏️ Updating draft...' : '📝 Saving shift note as draft...');

      // Get user ID from current user
      final userId = authState.user?.id;
      if (userId == null) {
        throw Exception('User ID not found. Please sign in again.');
      }

      // Use actual selected client ID
      final clientId = _selectedClientId!;

      // Format date and time
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedStartTime = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
      final formattedEndTime = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

      // Combine all notes into raw_notes
      final rawNotes = '''
Activities Completed:
${_activitiesController.text}

Behaviours & Engagement:
${_behavioursController.text}

Progress Notes:
${_progressNotesController.text}'''
          .trim();

      // Primary locations from multi-select
      final locations = _locations.isNotEmpty ? _locations : null;
      
      // Activity IDs from multi-select
      final activityIds = _selectedActivityIds.isNotEmpty ? _selectedActivityIds : null;

      final Map<String, dynamic> result;

      if (isEditing) {
        // Update existing draft
        // Note: Convex doesn't allow updating shift date/time after creation
        result = await apiService.updateShiftNote(
          shiftNoteId: widget.shiftNote!.id,
          primaryLocations: locations,
          rawNotes: rawNotes,
          activityIds: activityIds,
        );

        print('✅ Draft updated successfully');
      } else {
        // Create new draft (without formatted_note means it's a draft)
        result = await apiService.createShiftNote(
          clientId: clientId,
          userId: userId,
          shiftDate: formattedDate,
          startTime: formattedStartTime,
          endTime: formattedEndTime,
          primaryLocations: locations,
          rawNotes: rawNotes,
          activityIds: activityIds,
        );

        print('✅ Draft saved successfully: ${result['id']}');
      }

      // Refresh shift notes list
      ref.read(shiftNotesProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing 
                ? 'Draft updated successfully!' 
                : 'Draft saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() => _isSavingDraft = false);

      print('❌ Failed to save draft: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save draft: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

