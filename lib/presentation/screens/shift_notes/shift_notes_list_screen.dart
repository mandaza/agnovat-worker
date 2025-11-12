import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/shift_note.dart';
import '../../providers/shift_notes_provider.dart';
import '../../widgets/cards/shift_note_card.dart';
import 'shift_note_details_screen.dart';
import 'create_shift_note_screen.dart';

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

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Shift Notes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: shiftNotesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : shiftNotesState.error != null
              ? _buildError(context, ref, shiftNotesState.error!)
              : _buildContent(context, ref, shiftNotesState),
    );
  }

  /// Build main content
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ShiftNotesState state,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(shiftNotesProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with subtitle
            _buildHeader(context),

            // Create New Shift Note button
            _buildCreateButton(context),

            const SizedBox(height: 24),

            // Search bar
            _buildSearchBar(context, ref, state),

            const SizedBox(height: 16),

            // Filter chips
            _buildFilterChips(context, ref, state),

            const SizedBox(height: 24),

            // Recent notes section
            if (state.filteredShiftNotes.isEmpty)
              _buildEmptyState(context, state)
            else
              _buildShiftNotesList(context, ref, state.groupedShiftNotes),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build header with subtitle
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: const Text(
        'Manage and review shift documentation',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Build create button
  Widget _buildCreateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateShiftNoteScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '+ Create New Shift Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Document your recent shift',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
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
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ShiftNoteCard(
                      shiftNote: note,
                      clientName: 'Tavonga Gore', // TODO: Get actual client name
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ShiftNoteDetailsScreen(shiftNote: note),
                          ),
                        );
                      },
                    ),
                  )),

              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Build search bar
  Widget _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
    ShiftNotesState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(shiftNotesProvider.notifier).setSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search shift notes...',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: state.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(shiftNotesProvider.notifier).setSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    ShiftNotesState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    context: context,
                    ref: ref,
                    label: 'All Notes',
                    count: state.shiftNotes.length,
                    isSelected: state.statusFilter == ShiftNoteFilter.all,
                    onTap: () {
                      ref.read(shiftNotesProvider.notifier).setStatusFilter(
                            ShiftNoteFilter.all,
                          );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context: context,
                    ref: ref,
                    label: 'Drafts',
                    count: state.draftNotesCount,
                    isSelected: state.statusFilter == ShiftNoteFilter.draft,
                    onTap: () {
                      ref.read(shiftNotesProvider.notifier).setStatusFilter(
                            ShiftNoteFilter.draft,
                          );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context: context,
                    ref: ref,
                    label: 'Submitted',
                    count: state.submittedNotesCount,
                    isSelected: state.statusFilter == ShiftNoteFilter.submitted,
                    onTap: () {
                      ref.read(shiftNotesProvider.notifier).setStatusFilter(
                            ShiftNoteFilter.submitted,
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (state.statusFilter != ShiftNoteFilter.all ||
              state.searchQuery.isNotEmpty) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                ref.read(shiftNotesProvider.notifier).clearFilters();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Clear',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build individual filter chip
  Widget _buildFilterChip({
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
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.black.withOpacity(0.1),
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
                    ? Colors.white.withOpacity(0.2)
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

  /// Build empty state
  Widget _buildEmptyState(BuildContext context, ShiftNotesState state) {
    // Check if empty due to filters
    final hasActiveFilters = state.statusFilter != ShiftNoteFilter.all ||
        state.searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilters ? Icons.filter_list_off : Icons.note_add_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilters
                  ? 'No matching shift notes'
                  : 'No shift notes yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilters
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




