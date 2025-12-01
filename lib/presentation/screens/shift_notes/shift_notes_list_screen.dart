import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/shift_note.dart';
import '../../providers/shift_notes_provider.dart';
import '../../widgets/cards/shift_note_card.dart';
import 'shift_note_details_screen.dart';
import 'unified_shift_note_wizard.dart';
import '../activities/activities_list_screen.dart';
import '../dashboard/worker_dashboard_screen.dart';

/// Shift Notes List Screen
/// Displays all shift notes with ability to create new ones
class ShiftNotesListScreen extends ConsumerStatefulWidget {
  const ShiftNotesListScreen({super.key});

  @override
  ConsumerState<ShiftNotesListScreen> createState() => _ShiftNotesListScreenState();
}

class _ShiftNotesListScreenState extends ConsumerState<ShiftNotesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shiftNotesState = ref.watch(shiftNotesProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const WorkerDashboardScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: shiftNotesState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : shiftNotesState.error != null
                ? _buildError(context, ref, shiftNotesState.error!)
                : _buildContent(context, ref, shiftNotesState),
        bottomNavigationBar: _buildBottomNavigation(context),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 2, // Shift Notes tab
        onTap: (index) {
          switch (index) {
            case 0:
              // Dashboard
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const WorkerDashboardScreen(),
                ),
              );
              break;
            case 1:
              // Activities
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ActivitiesListScreen(),
                ),
              );
              break;
            case 2:
              // Already on Shift Notes
              break;
          }
        },
        selectedItemColor: AppColors.deepBrown,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Shift Notes',
          ),
        ],
      ),
    );
  }

  /// Build main content
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ShiftNotesState state,
  ) {
    final filteredNotes = state.filteredShiftNotes;

    return Column(
      children: [
        // Header
        _buildHeader(context),

        // Search and Filters
        _buildSearchAndFilters(context, ref, state),

        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(shiftNotesProvider.notifier).refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create New Shift Note Button
                  _buildCreateButton(context),

                  const SizedBox(height: 24),

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
                      if (state.searchQuery.isNotEmpty ||
                          state.statusFilter != ShiftNoteFilter.all)
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(shiftNotesProvider.notifier)
                                .clearFilters();
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
                  if (filteredNotes.isEmpty)
                    _buildEmptyState(context, state)
                  else
                    _buildShiftNotesList(context, ref, state.groupedShiftNotes),

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
  Widget _buildHeader(BuildContext context) {
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
      child: const SafeArea(
        bottom: false,
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
              'Manage and review shift documentation',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build create button
  Widget _buildCreateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UnifiedShiftNoteWizard(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 24),
            SizedBox(width: 8),
            Text(
              'Create New Shift Note',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    WidgetRef ref,
    ShiftNotesState state,
  ) {
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
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(shiftNotesProvider.notifier)
                            .setSearchQuery('');
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
              ref.read(shiftNotesProvider.notifier).setSearchQuery(value);
            },
          ),

          const SizedBox(height: 12),

          // Status Filter Chips (All/Drafts/Submitted)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(
                  context: context,
                  ref: ref,
                  label: 'All Notes',
                  count: state.shiftNotes.length,
                  isSelected: state.statusFilter == ShiftNoteFilter.all,
                  onTap: () {
                    ref
                        .read(shiftNotesProvider.notifier)
                        .setStatusFilter(ShiftNoteFilter.all);
                  },
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  context: context,
                  ref: ref,
                  label: 'Drafts',
                  count: state.draftNotesCount,
                  isSelected: state.statusFilter == ShiftNoteFilter.draft,
                  onTap: () {
                    ref
                        .read(shiftNotesProvider.notifier)
                        .setStatusFilter(ShiftNoteFilter.draft);
                  },
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  context: context,
                  ref: ref,
                  label: 'Submitted',
                  count: state.submittedNotesCount,
                  isSelected: state.statusFilter == ShiftNoteFilter.submitted,
                  onTap: () {
                    ref
                        .read(shiftNotesProvider.notifier)
                        .setStatusFilter(ShiftNoteFilter.submitted);
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
    required BuildContext context,
    required WidgetRef ref,
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
  Widget _buildShiftNotesList(
    BuildContext context,
    WidgetRef ref,
    Map<String, List<ShiftNote>> groupedNotes,
  ) {
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
                    clientName: 'Tavonga Gore', // TODO: Get actual client name
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

  /// Build empty state
  Widget _buildEmptyState(BuildContext context, ShiftNotesState state) {
    final hasFilters = state.searchQuery.isNotEmpty ||
        state.statusFilter != ShiftNoteFilter.all;

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
                  : 'Create your first shift note to get started',
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
  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
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
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(shiftNotesProvider.notifier).refresh();
              },
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




