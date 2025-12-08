import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/providers/service_providers.dart';
import '../../../data/models/shift_note.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/cards/shift_note_card.dart';
import '../shift_notes/shift_note_details_screen.dart';

/// Guardian Shift Notes Screen - View all submitted shift notes
class GuardianShiftNotesScreen extends ConsumerStatefulWidget {
  const GuardianShiftNotesScreen({super.key});

  @override
  ConsumerState<GuardianShiftNotesScreen> createState() =>
      _GuardianShiftNotesScreenState();
}

enum ShiftNoteFilter { all, submitted }

class _GuardianShiftNotesScreenState extends ConsumerState<GuardianShiftNotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ShiftNoteFilter _statusFilter = ShiftNoteFilter.all;
  bool _isLoading = true;
  List<ShiftNote> _shiftNotes = [];
  Map<String, String> _clientNames = {}; // client_id -> name
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      final notesData = await apiService.listShiftNotes(limit: 100);
      final clients = await apiService.listClients();
      
      // Convert Map data to ShiftNote models
      final notes = notesData.map((noteData) {
        return ShiftNote.fromJson(noteData);
      }).toList();
      
      // Build client name lookup map
      final clientNameMap = <String, String>{};
      for (final client in clients) {
        clientNameMap[client.id] = client.name;
      }
      
      setState(() {
        _shiftNotes = notes;
        _clientNames = clientNameMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ShiftNote> get _filteredNotes {
    var notes = _shiftNotes;

    // Filter by status
    if (_statusFilter == ShiftNoteFilter.submitted) {
      notes = notes.where((note) => !note.isDraft).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) {
        final clientName = _clientNames[note.clientId] ?? '';
        final query = _searchQuery.toLowerCase();
        
        return clientName.toLowerCase().contains(query) ||
            note.shiftDate.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by date (most recent first)
    notes.sort((a, b) {
      final dateA = DateTime.parse(a.shiftDate);
      final dateB = DateTime.parse(b.shiftDate);
      return dateB.compareTo(dateA);
    });

    return notes;
  }

  int get _submittedNotesCount {
    return _shiftNotes.where((note) => !note.isDraft).length;
  }

  /// Group shift notes by date category (Today, Yesterday, This Week, etc.)
  Map<String, List<ShiftNote>> get _groupedShiftNotes {
    final grouped = <String, List<ShiftNote>>{};
    final now = DateTime.now();

    for (final note in _filteredNotes) {
      final noteDate = DateTime.parse(note.shiftDate);
      final String category;

      if (_isSameDay(noteDate, now)) {
        category = 'Today';
      } else if (_isSameDay(noteDate, now.subtract(const Duration(days: 1)))) {
        category = 'Yesterday';
      } else if (noteDate.isAfter(now.subtract(const Duration(days: 7)))) {
        category = 'This Week';
      } else if (noteDate.isAfter(now.subtract(const Duration(days: 30)))) {
        category = 'This Month';
      } else {
        category = DateFormat('MMMM yyyy').format(noteDate);
      }

      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(note);
    }

    return grouped;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes;
    final groupedNotes = _groupedShiftNotes;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: _error != null
          ? _buildError()
          : _buildContent(filteredNotes, groupedNotes),
    );
  }

  /// Build main content
  Widget _buildContent(
    List<ShiftNote> filteredNotes,
    Map<String, List<ShiftNote>> groupedNotes,
  ) {
    return Column(
      children: [
        // Header
        _buildHeader(),

        // Search and Filters
        _buildSearchAndFilters(),

        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadShiftNotes,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredNotes.length} ${filteredNotes.length == 1 ? 'Note' : 'Notes'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _statusFilter = ShiftNoteFilter.all;
                            });
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear Filters'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.deepBrown,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Shift Notes List
                  if (_isLoading && filteredNotes.isEmpty)
                    _buildShiftNotesSkeleton()
                  else if (filteredNotes.isEmpty)
                    _buildEmptyState()
                  else
                    _buildShiftNotesList(groupedNotes),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build header with title and subtitle
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Shift Notes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Review shift documentation from support workers',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48), // Balance the back button
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search shift notes...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
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

          const SizedBox(height: 12),

          // Status Filter Chips (All/Submitted)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(
                  label: 'All Notes',
                  count: _shiftNotes.length,
                  isSelected: _statusFilter == ShiftNoteFilter.all,
                  onTap: () {
                    setState(() {
                      _statusFilter = ShiftNoteFilter.all;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  label: 'Submitted',
                  count: _submittedNotesCount,
                  isSelected: _statusFilter == ShiftNoteFilter.submitted,
                  onTap: () {
                    setState(() {
                      _statusFilter = ShiftNoteFilter.submitted;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepBrown : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.deepBrown : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build shift notes list with groups
  Widget _buildShiftNotesList(Map<String, List<ShiftNote>> groupedNotes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedNotes.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Shift notes in this section
            ...entry.value.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ShiftNoteCard(
                    shiftNote: note,
                    clientName: _clientNames[note.clientId],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ShiftNoteDetailsScreen(shiftNoteId: note.id),
                        ),
                      );
                    },
                  ),
                )),

            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  /// Build skeleton for shift notes list
  Widget _buildShiftNotesSkeleton() {
    return Column(
      children: List.generate(5, (index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: SkeletonListItem(height: 100),
        );
      }),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    final hasFilters = _searchQuery.isNotEmpty ||
        _statusFilter != ShiftNoteFilter.all;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.description_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No notes found' : 'No shift notes yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Shift notes from support workers will appear here',
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

  /// Build error state
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Failed to load shift notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadShiftNotes,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

