import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../widgets/skeleton_loader.dart';
import '../shift_notes/shift_note_details_screen.dart';

/// Guardian Shift Notes Screen - View all submitted shift notes
class GuardianShiftNotesScreen extends ConsumerStatefulWidget {
  const GuardianShiftNotesScreen({super.key});

  @override
  ConsumerState<GuardianShiftNotesScreen> createState() =>
      _GuardianShiftNotesScreenState();
}

class _GuardianShiftNotesScreenState extends ConsumerState<GuardianShiftNotesScreen> {
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _shiftNotes = [];
  Map<String, String> _clientNames = {}; // client_id -> name
  Map<String, String> _workerNames = {}; // user_id -> name
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShiftNotes();
  }

  Future<void> _loadShiftNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(mcpApiServiceProvider);
      
      // Fetch shift notes and clients
      final notes = await apiService.listShiftNotes(limit: 100);
      final clients = await apiService.listClients();
      
      // Build client name lookup map
      final clientNameMap = <String, String>{};
      for (final client in clients) {
        clientNameMap[client.id] = client.name;
      }
      
      // Extract unique user IDs from notes
      final userIds = notes
          .map((note) => note['user_id'] as String?)
          .where((id) => id != null)
          .toSet();
      
      // Fetch user information for each unique user ID
      final workerNameMap = <String, String>{};
      for (final userId in userIds) {
        if (userId != null) {
          try {
            // Fetch user by ID
            final user = await apiService.getUserById(userId);
            workerNameMap[userId] = user.name;
          } catch (e) {
            print('Failed to fetch user $userId: $e');
            workerNameMap[userId] = 'Unknown Worker';
          }
        }
      }
      
      setState(() {
        _shiftNotes = notes;
        _clientNames = clientNameMap;
        _workerNames = workerNameMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _viewShiftNoteDetails(String shiftNoteId) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final apiService = ref.read(mcpApiServiceProvider);
      final shiftNote = await apiService.getShiftNote(shiftNoteId);

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShiftNoteDetailsScreen(
            shiftNoteId: shiftNote.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading shift note: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredNotes {
    // Only show submitted notes
    var notes = _shiftNotes.where((note) => note['status'] == 'submitted').toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) {
        final clientId = note['client_id'] as String?;
        final userId = note['user_id'] as String?;
        
        final clientName = (clientId != null ? _clientNames[clientId] : null) ?? '';
        final workerName = (userId != null ? _workerNames[userId] : null) ?? '';
        final title = (note['title'] ?? '').toString();
        final query = _searchQuery.toLowerCase();
        
        return clientName.toLowerCase().contains(query) ||
            workerName.toLowerCase().contains(query) ||
            title.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by date (most recent first)
    notes.sort((a, b) {
      final dateA = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
      final dateB = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
      return dateB.compareTo(dateA);
    });

    return notes;
  }

  /// Build skeleton loader for shift notes
  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(5, (index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SkeletonListItem(height: 100),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        title: const Text('Submitted Shift Notes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadShiftNotes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by client, worker, or title...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // Submitted count indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${filteredNotes.length} Submitted ${filteredNotes.length == 1 ? 'Note' : 'Notes'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: _error != null
                ? _buildErrorState()
                : _isLoading && filteredNotes.isEmpty
                    ? _buildSkeletonLoader()
                    : filteredNotes.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadShiftNotes,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredNotes.length,
                              itemBuilder: (context, index) {
                                return _buildShiftNoteCard(
                                    filteredNotes[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftNoteCard(Map<String, dynamic> note) {
    final clientId = note['client_id'] as String?;
    final userId = note['user_id'] as String?;
    
    final clientName = (clientId != null ? _clientNames[clientId] : null) ?? 'Unknown Client';
    final workerName = (userId != null ? _workerNames[userId] : null) ?? 'Unknown Worker';
    final title = note['title'] ?? 'Shift Note';
    final dateStr = note['shift_date'] ?? note['created_at'];

    // Format date
    String formattedDate = 'Unknown date';
    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = 'Invalid date';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () async {
          // Fetch full shift note and navigate to details
          await _viewShiftNoteDetails(note['id'] as String);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                clientName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Footer Row
              Row(
                children: [
                  // Date
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // View Details Arrow
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Icon(
            Icons.description_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No submitted notes found'
                  : 'No submitted shift notes yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'Submitted shift notes from support workers will appear here',
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Error loading shift notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadShiftNotes,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

