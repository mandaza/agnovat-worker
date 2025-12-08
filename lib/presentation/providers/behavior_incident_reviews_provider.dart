import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/behavior_incident_review.dart';
import '../../data/models/user.dart';
import '../../data/services/providers.dart';
import '../providers/auth_provider.dart';

/// Behavior Incident Reviews Filter
enum ReviewFilter {
  all,
  draft,
  submitted,
  acknowledged,
  followUpRequired,
  critical;
}

/// Behavior incident reviews state model
class BehaviorIncidentReviewsState {
  final bool isLoading;
  final String? error;
  final List<BehaviorIncidentReview> reviews;
  final String searchQuery;
  final ReviewFilter filter;
  final ReviewSummary? summary;

  const BehaviorIncidentReviewsState({
    this.isLoading = true,
    this.error,
    this.reviews = const [],
    this.searchQuery = '',
    this.filter = ReviewFilter.all,
    this.summary,
  });

  BehaviorIncidentReviewsState copyWith({
    bool? isLoading,
    String? error,
    List<BehaviorIncidentReview>? reviews,
    String? searchQuery,
    ReviewFilter? filter,
    ReviewSummary? summary,
  }) {
    return BehaviorIncidentReviewsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      reviews: reviews ?? this.reviews,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      summary: summary ?? this.summary,
    );
  }

  /// Get filtered reviews based on filter
  List<BehaviorIncidentReview> get filteredReviews {
    var filtered = reviews;

    // Apply filter
    switch (filter) {
      case ReviewFilter.draft:
        filtered = filtered.where((review) => review.isDraft).toList();
        break;
      case ReviewFilter.submitted:
        filtered = filtered.where((review) => review.isSubmitted).toList();
        break;
      case ReviewFilter.acknowledged:
        filtered = filtered.where((review) => review.isAcknowledged).toList();
        break;
      case ReviewFilter.followUpRequired:
        filtered = filtered.where((review) => review.followUpRequired).toList();
        break;
      case ReviewFilter.critical:
        filtered = filtered.where((review) => review.isCritical).toList();
        break;
      case ReviewFilter.all:
        // Show all
        break;
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((review) {
        return review.comments.toLowerCase().contains(query) ||
            review.recommendations.toLowerCase().contains(query) ||
            review.reviewerName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  /// Get count of draft reviews
  int get draftReviewsCount => reviews.where((r) => r.isDraft).length;

  /// Get count of submitted reviews
  int get submittedReviewsCount => reviews.where((r) => r.isSubmitted).length;

  /// Get count of acknowledged reviews
  int get acknowledgedReviewsCount => reviews.where((r) => r.isAcknowledged).length;

  /// Get count of reviews requiring follow-up
  int get followUpRequiredCount => reviews.where((r) => r.followUpRequired).length;

  /// Get count of critical reviews
  int get criticalReviewsCount => reviews.where((r) => r.isCritical).length;
}

/// Behavior incident reviews notifier
class BehaviorIncidentReviewsNotifier extends AutoDisposeNotifier<BehaviorIncidentReviewsState> {
  Timer? _refreshTimer;

  @override
  BehaviorIncidentReviewsState build() {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.isLoggingOut) {
      return const BehaviorIncidentReviewsState(isLoading: false, reviews: []);
    }

    // Set up auto-refresh (every 60 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchReviews();
    });

    // Clean up timer when disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    // Initial data fetch
    _fetchReviews();

    return const BehaviorIncidentReviewsState();
  }

  /// Fetch behavior incident reviews from Convex
  Future<void> _fetchReviews({bool fetchAll = false}) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated || authState.isLoggingOut) {
      _refreshTimer?.cancel();
      state = const BehaviorIncidentReviewsState(isLoading: false, reviews: []);
      return;
    }

    try {
      // Get service
      final service = ref.read(behaviorIncidentReviewsServiceProvider);
      // Get current user's Clerk ID and role for filtering
      final clerkId = authState.user?.clerkId;
      final userRole = authState.user?.role;

      // Determine if user should see all reviews (admins/practitioners) or just their own
      final isAdmin = userRole == UserRole.superAdmin ||
                      userRole == UserRole.manager;
      final isPractitioner = userRole == UserRole.behaviorPractitioner;

      // Fetch reviews from Convex (now using Clerk ID)
      final reviews = await service.listReviews(
        reviewerClerkId: (fetchAll || isAdmin || !isPractitioner) ? null : clerkId,
        limit: 100,
      );

      // Fetch summary statistics (now using Clerk ID)
      ReviewSummary? summary;
      try {
        summary = await service.getSummary(
          reviewerClerkId: isPractitioner ? clerkId : null,
        );
      } catch (e) {
        print('⚠️ Error fetching summary: $e');
      }

      state = state.copyWith(
        isLoading: false,
        error: null,
        reviews: reviews,
        summary: summary,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Manually refresh reviews
  Future<void> refresh({bool fetchAll = false}) async {
    state = state.copyWith(isLoading: true);
    await _fetchReviews(fetchAll: fetchAll);
  }

  /// Fetch all reviews (for admins)
  Future<void> fetchAllReviews() async {
    state = state.copyWith(isLoading: true);
    await _fetchReviews(fetchAll: true);
  }

  /// Add a new review to Convex
  Future<BehaviorIncidentReview> addReview(BehaviorIncidentReview review) async {
    try {
      final service = ref.read(behaviorIncidentReviewsServiceProvider);
      
      // Get Clerk ID from auth state
      final authState = ref.read(authProvider);
      final clerkId = authState.user?.clerkId;
      
      if (clerkId == null) {
        throw Exception('User not authenticated - Clerk ID not found');
      }

      print('📝 Creating review with Clerk ID: $clerkId...');

      // Create review on Convex (now passes Clerk ID)
      final createdReview = await service.createReview(review, clerkId);

      print('✅ Review created successfully with ID: ${createdReview.id}');

      // Refresh the list to get the full data from backend
      await refresh();

      return createdReview;
    } catch (e) {
      print('❌ Error in addReview: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Submit a review (change status from draft to submitted)
  Future<void> submitReview(String reviewId) async {
    try {
      final service = ref.read(behaviorIncidentReviewsServiceProvider);

      final updatedReview = await service.submitReview(reviewId);

      // Update in local state
      final updatedList = state.reviews.map((r) {
        return r.id == reviewId ? updatedReview : r;
      }).toList();

      state = state.copyWith(reviews: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Update an existing review
  Future<void> updateReview(String reviewId, Map<String, dynamic> updates) async {
    try {
      final service = ref.read(behaviorIncidentReviewsServiceProvider);

      final updatedReview = await service.updateReview(
        reviewId: reviewId,
        updates: updates,
      );

      // Update in local state
      final updatedList = state.reviews.map((r) {
        return r.id == reviewId ? updatedReview : r;
      }).toList();

      state = state.copyWith(reviews: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Acknowledge a review (support worker marks as read)
  /// Now accepts Clerk ID instead of Convex user ID
  Future<void> acknowledgeReview(String reviewId, String acknowledgedByClerkId) async {
    try {
      final service = ref.read(behaviorIncidentReviewsServiceProvider);

      final updatedReview = await service.acknowledgeReview(
        reviewId: reviewId,
        acknowledgedByClerkId: acknowledgedByClerkId,
      );

      // Update in local state
      final updatedList = state.reviews.map((r) {
        return r.id == reviewId ? updatedReview : r;
      }).toList();

      state = state.copyWith(reviews: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      final service = ref.read(behaviorIncidentReviewsServiceProvider);

      await service.deleteReview(reviewId);

      // Remove from local state
      final updatedList = state.reviews.where((r) => r.id != reviewId).toList();
      state = state.copyWith(reviews: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Update filter
  void setFilter(ReviewFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      filter: ReviewFilter.all,
    );
  }
}

/// Main behavior incident reviews provider
final behaviorIncidentReviewsProvider = AutoDisposeNotifierProvider<BehaviorIncidentReviewsNotifier, BehaviorIncidentReviewsState>(
  BehaviorIncidentReviewsNotifier.new,
);

/// Provider for unacknowledged reviews (notifications for support workers)
/// Now uses Clerk ID instead of Convex user ID
final unacknowledgedReviewsProvider = FutureProvider.autoDispose<List<BehaviorIncidentReview>>((ref) async {
  final authState = ref.watch(authProvider);

  // Don't fetch if not authenticated or logging out
  if (!authState.isAuthenticated || authState.isLoggingOut) {
    return [];
  }

  final clerkId = authState.user?.clerkId;
  if (clerkId == null) {
    return [];
  }

  final service = ref.watch(behaviorIncidentReviewsServiceProvider);

  try {
    return await service.getUnacknowledgedForUser(clerkId);
  } catch (e) {
    print('❌ Error fetching unacknowledged reviews: $e');
    return [];
  }
});

/// Provider for unacknowledged review count (notification badge)
final unacknowledgedReviewCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final unacknowledgedReviews = await ref.watch(unacknowledgedReviewsProvider.future);
  return unacknowledgedReviews.length;
});

/// Provider to get reviews for a specific behavior incident
/// Returns the most recent review (draft or submitted) for the incident
final incidentReviewProvider = FutureProvider.autoDispose.family<BehaviorIncidentReview?, String>((ref, behaviorIncidentConvexId) async {
  final service = ref.watch(behaviorIncidentReviewsServiceProvider);
  
  try {
    // Fetch all reviews for this incident
    final reviews = await service.listReviews(
      behaviorIncidentId: behaviorIncidentConvexId,
      limit: 10, // Get recent reviews
    );
    
    if (reviews.isEmpty) {
      return null;
    }
    
    // Get current user's Clerk ID to filter by reviewer
    final authState = ref.watch(authProvider);
    final clerkId = authState.user?.clerkId;
    
    if (clerkId == null) {
      // If no clerk ID, return the most recent review
      reviews.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return reviews.first;
    }
    
    // Filter reviews by current reviewer (using reviewer_clerk_id)
    // Note: We need to check if the review was created by current user
    // Since we're using Clerk ID now, we should filter by reviewer
    final userReviews = reviews.where((review) {
      // For now, return all reviews - backend should filter by reviewer_clerk_id
      return true;
    }).toList();
    
    if (userReviews.isEmpty) {
      return null;
    }
    
    // Sort by updated date (most recent first) and return the first one
    userReviews.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return userReviews.first;
  } catch (e) {
    print('❌ Error fetching review for incident $behaviorIncidentConvexId: $e');
    return null;
  }
});
