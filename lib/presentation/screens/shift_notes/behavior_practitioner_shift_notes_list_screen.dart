import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/shift_note.dart';
import '../../providers/behavior_practitioner_shift_notes_provider.dart';
import '../../widgets/cards/shift_note_card.dart';
import '../../widgets/skeleton_loader.dart';
import 'shift_note_details_screen.dart';
import '../dashboard/behavior_practitioner_dashboard_screen.dart';
import '../behavior_incidents/behavior_incidents_list_screen.dart';

/// Behavior Practitioner Shift Notes List Screen
/// Displays all shift notes (not filtered by user) for behavior practitioners
class BehaviorPractitionerShiftNotesListScreen extends ConsumerStatefulWidget {
  const BehaviorPractitionerShiftNotesListScreen({super.key});

  @override
  ConsumerState<BehaviorPractitionerShiftNotesListScreen> createState() =>
      _BehaviorPractitionerShiftNotesListScreenState();
}

class _BehaviorPractitionerShiftNotesListScreenState
    extends ConsumerState<BehaviorPractitionerShiftNotesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shiftNotesState = ref.watch(behaviorPractitionerShiftNotesProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const BehaviorPractitionerDashboardScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: shiftNotesState.error != null
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
                  builder: (context) => const BehaviorPractitionerDashboardScreen(),
                ),
              );
              break;
            case 1:
              // Behavior Incidents
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const BehaviorIncidentsListScreen(),
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
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Incidents',
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
    BehaviorPractitionerShiftNotesState state,
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
            onRefresh: () => ref.read(behaviorPractitionerShiftNotesProvider.notifier).refresh(),
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
                      if (state.searchQuery.isNotEmpty ||
                          state.statusFilter != BehaviorPractitionerShiftNoteFilter.all)
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(behaviorPractitionerShiftNotesProvider.notifier)
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
                  if (state.isLoading && filteredNotes.isEmpty)
                    _buildShiftNotesSkeleton()
                  else if (filteredNotes.isEmpty)
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
              'Review all submitted shift documentation',
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

  /// Build search and filters section
  Widget _buildSearchAndFilters(
    BuildContext context,
    WidgetRef ref,
    BehaviorPractitionerShiftNotesState state,
  ) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search shift notes...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(behaviorPractitionerShiftNotesProvider.notifier)
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              ref
                  .read(behaviorPractitionerShiftNotesProvider.notifier)
                  .setSearchQuery(value);
            },
          ),
          const SizedBox(height: 12),
          // Status filters - Behavior practitioners only see submitted notes
          // Draft filter is removed since behavior practitioners should NEVER see drafts
          Row(
            children: [
              _buildStatusChip(
                context: context,
                ref: ref,
                label: 'All',
                count: state.shiftNotes.length,
                isSelected: state.statusFilter == BehaviorPractitionerShiftNoteFilter.all,
                onTap: () {
                  ref
                      .read(behaviorPractitionerShiftNotesProvider.notifier)
                      .setStatusFilter(BehaviorPractitionerShiftNoteFilter.all);
                },
              ),
              const SizedBox(width: 8),
              // Only show "Submitted" filter - drafts are not visible to behavior practitioners
              _buildStatusChip(
                context: context,
                ref: ref,
                label: 'Submitted',
                count: state.shiftNotes.where((n) => n.isSubmitted).length,
                isSelected: state.statusFilter == BehaviorPractitionerShiftNoteFilter.submitted,
                onTap: () {
                  ref
                      .read(behaviorPractitionerShiftNotesProvider.notifier)
                      .setStatusFilter(BehaviorPractitionerShiftNoteFilter.submitted);
                },
              ),
            ],
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
                fontSize: 12,
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
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build shift notes list grouped by date
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
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...entry.value.map((note) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ShiftNoteCard(
                  shiftNote: note,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShiftNoteDetailsScreen(shiftNoteId: note.id),
                      ),
                    );
                  },
                ),
              );
            }),
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
  Widget _buildEmptyState(BuildContext context, BehaviorPractitionerShiftNotesState state) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            state.searchQuery.isNotEmpty || state.statusFilter != BehaviorPractitionerShiftNoteFilter.all
                ? 'No shift notes found'
                : 'No shift notes yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.searchQuery.isNotEmpty || state.statusFilter != BehaviorPractitionerShiftNoteFilter.all
                ? 'Try adjusting your filters or search query'
                : 'Submitted shift notes will appear here',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
              'Error loading shift notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(behaviorPractitionerShiftNotesProvider.notifier).refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBrown,
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

