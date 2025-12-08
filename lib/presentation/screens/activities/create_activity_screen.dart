import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/activity.dart';
import '../../../data/models/client.dart';
import '../../../data/models/goal.dart';
import '../../providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';

/// Screen for creating a new activity for a client
class CreateActivityScreen extends ConsumerStatefulWidget {
  final String? preselectedClientId;

  const CreateActivityScreen({
    super.key,
    this.preselectedClientId,
  });

  @override
  ConsumerState<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends ConsumerState<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedClientId;
  String? _selectedStakeholderId;
  ActivityType _selectedActivityType = ActivityType.lifeSkills;
  List<String> _selectedGoalIds = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  List<Client> _clients = [];
  List<Goal> _availableGoals = [];
  List<Map<String, dynamic>> _stakeholders = [];

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.preselectedClientId;
    _loadInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final authState = ref.read(authProvider);
      
      // Load clients and stakeholders in parallel
      final results = await Future.wait([
        apiService.listClients(active: true),
        apiService.listStakeholders(role: 'support_worker', active: true, limit: 100),
      ]);

      final clients = results[0] as List<Client>;
      final stakeholders = results[1];

      setState(() {
        _clients = clients;
        _stakeholders = List<Map<String, dynamic>>.from(stakeholders);
        
        // If user is a support worker (has stakeholderId), auto-select them
        if (authState.user?.stakeholderId != null) {
          final userStakeholderId = authState.user!.stakeholderId;
          
          // Try to find matching stakeholder in the list (check 'id' field)
          final matchingStakeholder = _stakeholders.firstWhere(
            (s) => s['id'] == userStakeholderId,
            orElse: () => {},
          );
          
          if (matchingStakeholder.isNotEmpty) {
            _selectedStakeholderId = userStakeholderId;
          }
        }
        
        _isLoadingData = false;
      });

      // Load goals if client is preselected
      if (_selectedClientId != null) {
        _loadGoalsForClient(_selectedClientId!);
      }
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadGoalsForClient(String clientId) async {
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final goals = await apiService.listGoals(clientId: clientId);

      setState(() {
        _availableGoals = goals;
        _selectedGoalIds = []; // Reset selected goals when client changes
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading goals: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedStakeholderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign a support worker'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(mcpApiServiceProvider);

      await apiService.createActivity(
        clientId: _selectedClientId!,
        stakeholderId: _selectedStakeholderId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        activityType: _selectedActivityType,
        status: ActivityStatus.scheduled,
        goalIds: _selectedGoalIds.isEmpty ? null : _selectedGoalIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating activity: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Activity',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.borderLight,
          ),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Client Selection
                    _buildSectionTitle('Select Client'),
                    const SizedBox(height: 12),
                    _buildClientDropdown(),
                    const SizedBox(height: 24),

                    // Activity Title
                    _buildSectionTitle('Activity Title'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'e.g., Swimming, Art Therapy, Music Session',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an activity title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Activity Type
                    _buildSectionTitle('Activity Type'),
                    const SizedBox(height: 12),
                    _buildActivityTypeDropdown(),
                    const SizedBox(height: 24),

                    // Assign Support Worker
                    _buildSectionTitle('Assign to Support Worker'),
                    const SizedBox(height: 12),
                    _buildStakeholderDropdown(),
                    const SizedBox(height: 24),

                    // Description
                    _buildSectionTitle('Description (Optional)'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Add details about this activity...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Link to Goals
                    if (_availableGoals.isNotEmpty) ...[
                      _buildSectionTitle('Link to Goals (Optional)'),
                      const SizedBox(height: 12),
                      _buildGoalsSelection(),
                      const SizedBox(height: 24),
                    ],

                    // Submit Button
                    const SizedBox(height: 16),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildClientDropdown() {
    final selectedClient = _selectedClientId != null
        ? _clients.firstWhere((c) => c.id == _selectedClientId, orElse: () => _clients.first)
        : null;

    return InkWell(
      onTap: widget.preselectedClientId == null ? _showClientSelector : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.preselectedClientId != null
              ? AppColors.grey100.withOpacity(0.5)
              : AppColors.white,
          border: Border.all(
            color: widget.preselectedClientId != null
                ? AppColors.borderLight.withOpacity(0.5)
                : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedClient?.name ?? 'Select a client',
              style: TextStyle(
                fontSize: 16,
                color: selectedClient != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            if (widget.preselectedClientId != null)
              const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary)
            else
              const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }

  void _showClientSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Select Client',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _clients.length,
                itemBuilder: (context, index) {
                  final client = _clients[index];
                  final isSelected = _selectedClientId == client.id;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: Text(
                      client.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.deepBrown : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.deepBrown)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedClientId = client.id;
                      });
                      _loadGoalsForClient(client.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTypeDropdown() {
    return InkWell(
      onTap: _showActivityTypeSelector,
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
              _selectedActivityType.displayName,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }

  void _showActivityTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Select Activity Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: ActivityType.values.length,
                itemBuilder: (context, index) {
                  final type = ActivityType.values[index];
                  final isSelected = _selectedActivityType == type;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.deepBrown : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.deepBrown)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedActivityType = type;
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
    );
  }

  Widget _buildStakeholderDropdown() {
    final selectedStakeholder = _selectedStakeholderId != null
        ? _stakeholders.firstWhere(
            (s) => s['_id'] == _selectedStakeholderId,
            orElse: () => {},
          )
        : null;

    return InkWell(
      onTap: _showStakeholderSelector,
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
            Expanded(
              child: Text(
                selectedStakeholder != null && selectedStakeholder.isNotEmpty
                    ? (selectedStakeholder['name'] as String? ?? 'Unknown')
                    : 'Select support worker',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedStakeholder != null && selectedStakeholder.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }

  void _showStakeholderSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Select Support Worker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _stakeholders.isEmpty
                  ? const Center(
                      child: Text(
                        'No support workers available',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _stakeholders.length,
                      itemBuilder: (context, index) {
                        final stakeholder = _stakeholders[index];
                        final stakeholderId = stakeholder['_id'] as String?;
                        final name = stakeholder['name'] as String? ?? 'Unknown';
                        final isSelected = _selectedStakeholderId == stakeholderId;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          title: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppColors.deepBrown : AppColors.textPrimary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.deepBrown)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedStakeholderId = stakeholderId;
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
    );
  }

  Widget _buildGoalsSelection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_availableGoals.isEmpty)
            const Text(
              'No goals available for this client',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ..._availableGoals.map((goal) {
              final isSelected = _selectedGoalIds.contains(goal.id);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedGoalIds.add(goal.id);
                    } else {
                      _selectedGoalIds.remove(goal.id);
                    }
                  });
                },
                title: Text(
                  goal.title,
                  style: const TextStyle(fontSize: 14),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.deepBrown,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitActivity,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deepBrown,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Create Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
