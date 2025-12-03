import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/activity_session.dart';
import '../../../core/providers/service_providers.dart';
import '../../providers/behavior_practitioner_provider.dart';
import '../../providers/behavior_incident_reviews_provider.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/cards/behavior_incident_card.dart';
import '../dashboard/behavior_practitioner_dashboard_screen.dart';
import '../shift_notes/behavior_practitioner_shift_notes_list_screen.dart';
import '../reviews/create_review_screen.dart';
import '../reviews/review_detail_screen.dart';

/// Behavior Incidents List Screen
/// Displays all behavior incidents for behavior practitioners with filtering
class BehaviorIncidentsListScreen extends ConsumerStatefulWidget {
  const BehaviorIncidentsListScreen({super.key});

  @override
  ConsumerState<BehaviorIncidentsListScreen> createState() =>
      _BehaviorIncidentsListScreenState();
}

class _BehaviorIncidentsListScreenState
    extends ConsumerState<BehaviorIncidentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  BehaviorSeverity? _selectedSeverityFilter;
  bool _showSelfHarmOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BehaviorIncidentWithContext> _getFilteredIncidents(
      BehaviorPractitionerState state) {
    var incidents = state.behaviorIncidents;

    // Apply severity filter
    if (_selectedSeverityFilter != null) {
      incidents = incidents
          .where((item) => item.incident.severity == _selectedSeverityFilter)
          .toList();
    }

    // Apply self-harm filter
    if (_showSelfHarmOnly) {
      incidents =
          incidents.where((item) => item.incident.selfHarm).toList();
    }

    // Apply search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      incidents = incidents.where((item) {
        final clientName = item.clientName?.toLowerCase() ?? '';
        final workerName = item.workerName?.toLowerCase() ?? '';
        final description = item.incident.description.toLowerCase();
        final behaviors = item.incident.behaviorsDisplayed
            .join(' ')
            .toLowerCase();

        return clientName.contains(query) ||
            workerName.contains(query) ||
            description.contains(query) ||
            behaviors.contains(query);
      }).toList();
    }

    return incidents;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSeverityFilter = null;
      _showSelfHarmOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(behaviorPractitionerProvider);
    final filteredIncidents = _getFilteredIncidents(state);

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
        body: state.error != null
            ? _buildError(context, ref, state.error!)
            : _buildContent(context, ref, state, filteredIncidents),
        bottomNavigationBar: _buildBottomNavigation(context),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    BehaviorPractitionerState state,
    List<BehaviorIncidentWithContext> filteredIncidents,
  ) {
    return Column(
      children: [
        // Header
        _buildHeader(context),

        // Search and Filters
        _buildSearchAndFilters(context, state),

        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(behaviorPractitionerProvider.notifier).refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results count and clear filters
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredIncidents.length} ${filteredIncidents.length == 1 ? 'Incident' : 'Incidents'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty ||
                          _selectedSeverityFilter != null ||
                          _showSelfHarmOnly)
                        TextButton.icon(
                          onPressed: _clearFilters,
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

                  // Incidents List
                  if (state.isLoading && filteredIncidents.isEmpty)
                    _buildIncidentsSkeleton()
                  else if (filteredIncidents.isEmpty)
                    _buildEmptyState(context)
                  else
                    _buildIncidentsList(context, ref, filteredIncidents),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

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
              'Behavior Incidents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Review and manage all incidents',
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

  Widget _buildSearchAndFilters(
      BuildContext context, BehaviorPractitionerState state) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search incidents...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          color: AppColors.textSecondary),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          // Severity filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  count: state.behaviorIncidents.length,
                  isSelected: _selectedSeverityFilter == null &&
                      !_showSelfHarmOnly,
                  onTap: () {
                    setState(() {
                      _selectedSeverityFilter = null;
                      _showSelfHarmOnly = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Low',
                  count: state.behaviorIncidents
                      .where((i) => i.incident.severity == BehaviorSeverity.low)
                      .length,
                  isSelected: _selectedSeverityFilter == BehaviorSeverity.low,
                  color: AppColors.goldenAmber,
                  onTap: () {
                    setState(() {
                      _selectedSeverityFilter = BehaviorSeverity.low;
                      _showSelfHarmOnly = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Medium',
                  count: state.behaviorIncidents
                      .where(
                          (i) => i.incident.severity == BehaviorSeverity.medium)
                      .length,
                  isSelected: _selectedSeverityFilter == BehaviorSeverity.medium,
                  color: AppColors.burntOrange,
                  onTap: () {
                    setState(() {
                      _selectedSeverityFilter = BehaviorSeverity.medium;
                      _showSelfHarmOnly = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'High',
                  count: state.behaviorIncidents
                      .where(
                          (i) => i.incident.severity == BehaviorSeverity.high)
                      .length,
                  isSelected: _selectedSeverityFilter == BehaviorSeverity.high,
                  color: AppColors.error,
                  onTap: () {
                    setState(() {
                      _selectedSeverityFilter = BehaviorSeverity.high;
                      _showSelfHarmOnly = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Self-Harm',
                  count: state.behaviorIncidents
                      .where((i) => i.incident.selfHarm)
                      .length,
                  isSelected: _showSelfHarmOnly,
                  color: AppColors.error,
                  icon: Icons.warning_amber_rounded,
                  onTap: () {
                    setState(() {
                      _showSelfHarmOnly = true;
                      _selectedSeverityFilter = null;
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

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    Color? color,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? AppColors.deepBrown;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : chipColor,
              ),
              const SizedBox(width: 4),
            ],
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

  Widget _buildIncidentsList(
    BuildContext context,
    WidgetRef ref,
    List<BehaviorIncidentWithContext> incidents,
  ) {
    return Column(
      children: incidents.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BehaviorIncidentCard(
            item: item,
            onReviewTap: () {
              _handleReviewTap(context, ref, item);
            },
          ),
        );
      }).toList(),
    );
  }

  /// Handle review button tap - navigate to appropriate screen based on review status
  void _handleReviewTap(
    BuildContext context,
    WidgetRef ref,
    BehaviorIncidentWithContext item,
  ) async {
    // First, try to fetch the convexId if missing
    String? convexId = item.incident.convexId;
    
    if (convexId == null || convexId.isEmpty) {
      // Try to fetch it
      try {
        final apiService = ref.read(mcpApiServiceProvider);
        final result = await apiService.getShiftNoteWithSessions(item.shiftNote.id);
        
        final sessionsList = result['activity_sessions'];
        if (sessionsList is List) {
          for (final sessionJson in sessionsList) {
            if (sessionJson is! Map<String, dynamic>) continue;
            try {
              final session = ActivitySession.fromJson(sessionJson);
              for (final incident in session.behaviorIncidents) {
                if (incident.id == item.incident.id) {
                  convexId = incident.convexId;
                  break;
                }
              }
              if (convexId != null) break;
            } catch (e) {
              continue;
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching convexId: $e');
      }
    }

    if (convexId == null || convexId.isEmpty) {
      // No convexId available, show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This incident has not been synced yet. Please wait for the shift note to be fully synced.',
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Check if a review exists for this incident
    final reviewAsync = ref.read(incidentReviewProvider(convexId));
    
    reviewAsync.when(
      data: (review) {
        if (review == null) {
          // No review exists - navigate to create screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateReviewScreen(
                incident: item.incident,
                shiftNote: item.shiftNote,
                clientId: item.shiftNote.clientId,
                clientName: item.clientName,
              ),
            ),
          );
        } else if (review.isDraft) {
          // Draft review exists - navigate to edit screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateReviewScreen(
                incident: item.incident,
                shiftNote: item.shiftNote,
                clientId: item.shiftNote.clientId,
                clientName: item.clientName,
                existingReview: review,
              ),
            ),
          );
        } else {
          // Submitted review exists - navigate to view screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReviewDetailScreen(
                reviewId: review.id,
                canAcknowledge: false, // Practitioners can't acknowledge their own reviews
              ),
            ),
          );
        }
      },
      loading: () {
        // Show loading indicator or navigate to create screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateReviewScreen(
              incident: item.incident,
              shiftNote: item.shiftNote,
              clientId: item.shiftNote.clientId,
              clientName: item.clientName,
            ),
          ),
        );
      },
      error: (_, __) {
        // On error, navigate to create screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateReviewScreen(
              incident: item.incident,
              shiftNote: item.shiftNote,
              clientId: item.shiftNote.clientId,
              clientName: item.clientName,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncidentsSkeleton() {
    return Column(
      children: List.generate(5, (index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonListItem(height: 200),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No incidents found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search query',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
              'Error loading incidents',
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
                ref.read(behaviorPractitionerProvider.notifier).refresh();
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
        currentIndex: 1, // Incidents tab
        onTap: (index) {
          switch (index) {
            case 0:
              // Dashboard
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      const BehaviorPractitionerDashboardScreen(),
                ),
              );
              break;
            case 1:
              // Already on Incidents
              break;
            case 2:
              // Shift Notes
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      const BehaviorPractitionerShiftNotesListScreen(),
                ),
              );
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

}
