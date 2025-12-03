import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../providers/behavior_practitioner_provider.dart';
import '../../widgets/cards/behavior_incident_card.dart';
import '../reviews/create_review_screen.dart';

/// Screen showing unacknowledged behavior incidents for behavior practitioners
/// This is the notification center for new incidents that need review
class UnacknowledgedIncidentsScreen extends ConsumerWidget {
  const UnacknowledgedIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unacknowledgedIncidentsAsync = ref.watch(unacknowledgedIncidentsProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Incidents',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: unacknowledgedIncidentsAsync.when(
          data: (incidents) => _buildContent(context, ref, incidents),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(context, ref, error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<BehaviorIncidentWithContext> incidents) {
    if (incidents.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(unacknowledgedIncidentsProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: incidents.length,
        itemBuilder: (context, index) {
          final incidentWithContext = incidents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BehaviorIncidentCard(
              item: incidentWithContext,
              onReviewTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateReviewScreen(
                      incident: incidentWithContext.incident,
                      shiftNote: incidentWithContext.shiftNote,
                      clientId: incidentWithContext.shiftNote.clientId,
                      clientName: incidentWithContext.clientName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.deepBrown.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.deepBrown,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Caught Up!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You have no new incidents to review.\nNew behavior incidents will appear here.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                ref.invalidate(unacknowledgedIncidentsProvider);
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

