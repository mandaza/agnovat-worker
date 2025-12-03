import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../data/models/client.dart';
import '../../providers/client_details_provider.dart';
import '../../widgets/skeleton_loader.dart';
import 'client_details_screen.dart';
import '../dashboard/worker_dashboard_screen.dart';
import '../shift_notes/shift_notes_list_screen.dart';

/// Clients List Screen
/// Displays all clients assigned to the support worker
class ClientsListScreen extends ConsumerWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsState = ref.watch(clientsListCachedProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Navigate back to dashboard if there's nothing to pop
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const WorkerDashboardScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: clientsState.error != null
            ? _buildErrorState(context, clientsState.error!)
            : _buildContent(context, ref, clientsState),
        bottomNavigationBar: _buildBottomNavigation(context),
      ),
    );
  }

  /// Build main content
  Widget _buildContent(BuildContext context, WidgetRef ref, ClientsListState state) {
    return Column(
      children: [
        // Header
        _buildHeader(context),

        // Content
        Expanded(
          child: state.clients.isEmpty && !state.isLoading
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => ref.read(clientsListCachedProvider.notifier).refresh(),
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
                              '${state.clients.length} ${state.clients.length == 1 ? 'Client' : 'Clients'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Clients List
                        if (state.isLoading && state.clients.isEmpty)
                          _buildClientsSkeleton()
                        else
                          _buildClientsList(context, ref, state.clients, state),

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
              'My Clients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'View and manage assigned clients',
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

  Widget _buildClientsList(BuildContext context, WidgetRef ref, List<Client> clients, ClientsListState state) {
    return Column(
      children: [
        // Show existing clients
        ...clients.map((client) {
          return _buildClientCard(context, client);
        }),
        // Load more trigger - uses NotificationListener to detect when scrolled to bottom
        if (state.hasMore && !state.isLoadingMore)
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                // Load more when scrolled near bottom (within 200 pixels)
                if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                  ref.read(clientsListCachedProvider.notifier).loadMore();
                }
              }
              return false;
            },
            child: const SizedBox(height: 1),
          ),
        // Loading more indicator
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildClientCard(BuildContext context, Client client) {
    final goalsCount = client is ClientWithStats ? client.activeGoalsCount : null;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ClientDetailsScreen(client: client),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Avatar with gradient
            Container(
              width: 64,
              height: 64,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Client info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age: ${client.age} years',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (goalsCount != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$goalsCount active goal${goalsCount != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.goldenAmber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No clients assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Clients assigned to you will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
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
            'Error loading clients',
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
        ],
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
        currentIndex: 1, // Clients tab
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
              // Already on Clients
              break;
            case 2:
              // Shift Notes
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ShiftNotesListScreen(),
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
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Shift Notes',
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Build skeleton for clients list
  Widget _buildClientsSkeleton() {
    return Column(
      children: List.generate(5, (index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: SkeletonClientCard(),
        );
      }),
    );
  }

}

