import '../models/behavior_incident_review.dart';
import '../../core/services/convex_client_service.dart';

/// Service for behavior incident reviews using Convex directly
/// Calls behaviorIncidentReviews Convex functions
class BehaviorIncidentReviewsService {
  final ConvexClientService _convexClient;

  BehaviorIncidentReviewsService(this._convexClient);

  /// List behavior incident reviews with optional filtering
  /// Calls: behaviorIncidentReviews:list
  /// Supports both reviewer_id (Convex ID) and reviewer_clerk_id (Clerk ID) for backward compatibility
  Future<List<BehaviorIncidentReview>> listReviews({
    String? behaviorIncidentId,
    String? clientId,
    String? reviewerId, // Convex ID (for backward compatibility)
    String? reviewerClerkId, // Clerk ID (preferred)
    String? status,
    bool? followUpRequired,
    String? severityAssessment,
    int? limit,
  }) async {
    final args = <String, dynamic>{};
    if (behaviorIncidentId != null) args['behavior_incident_id'] = behaviorIncidentId;
    if (clientId != null) args['client_id'] = clientId;
    if (reviewerClerkId != null) {
      args['reviewer_clerk_id'] = reviewerClerkId; // Prefer Clerk ID
    } else if (reviewerId != null) {
      args['reviewer_id'] = reviewerId; // Fallback to Convex ID for backward compatibility
    }
    if (status != null) args['status'] = status;
    if (followUpRequired != null) args['follow_up_required'] = followUpRequired;
    if (severityAssessment != null) args['severity_assessment'] = severityAssessment;
    if (limit != null) args['limit'] = limit;

    final result = await _convexClient.query<List<dynamic>?>(
      'behaviorIncidentReviews:list',
      args: args,
    );

    return (result ?? [])
        .map((json) => BehaviorIncidentReview.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get behavior incident review by ID
  /// Calls: behaviorIncidentReviews:get
  Future<BehaviorIncidentReview> getReview(String reviewId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      'behaviorIncidentReviews:get',
      args: {'id': reviewId},
    );

    return BehaviorIncidentReview.fromJson(result);
  }

  /// Get all reviews for a specific incident
  /// Calls: behaviorIncidentReviews:getReviewsForIncident
  /// Returns incident with reviews, unacknowledged count, and critical flag
  Future<Map<String, dynamic>> getReviewsForIncident(String behaviorIncidentId) async {
    final result = await _convexClient.query<Map<String, dynamic>>(
      'behaviorIncidentReviews:getReviewsForIncident',
      args: {'behavior_incident_id': behaviorIncidentId},
    );

    return result;
  }

  /// Get unacknowledged reviews for a user (support worker notifications)
  /// Calls: behaviorIncidentReviews:getUnacknowledgedForUser
  /// Now accepts clerk_id (string) instead of user_id (Convex ID)
  Future<List<BehaviorIncidentReview>> getUnacknowledgedForUser(String clerkId) async {
    final result = await _convexClient.query<List<dynamic>?>(
      'behaviorIncidentReviews:getUnacknowledgedForUser',
      args: {'clerk_id': clerkId},
    );

    return (result ?? [])
        .map((json) => BehaviorIncidentReview.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create new behavior incident review
  /// Calls: behaviorIncidentReviews:create
  /// Now accepts reviewer_clerk_id (string) instead of reviewer_id (Convex ID)
  Future<BehaviorIncidentReview> createReview(
    BehaviorIncidentReview review,
    String reviewerClerkId,
  ) async {
    try {
      // Convert review to JSON and replace reviewer_id with reviewer_clerk_id
      final reviewJson = review.toJson();
      reviewJson.remove('reviewer_id'); // Remove Convex ID
      reviewJson['reviewer_clerk_id'] = reviewerClerkId; // Add Clerk ID
      
      final result = await _convexClient.mutation<dynamic>(
        'behaviorIncidentReviews:create',
        args: reviewJson,
      );

      // Handle null response
      if (result == null) {
        throw Exception('Backend returned null response when creating review');
      }

      // If result is a String (likely an ID), fetch the full review
      if (result is String) {
        print('📝 Created review with ID: $result');
        return review.copyWith(id: result);
      }

      // If result is a Map, parse it
      if (result is Map<String, dynamic>) {
        return BehaviorIncidentReview.fromJson(result);
      }

      throw Exception('Unexpected response type from backend: ${result.runtimeType}');
    } catch (e) {
      print('❌ Error creating review: $e');
      rethrow;
    }
  }

  /// Submit a review (change status from draft to submitted)
  /// Calls: behaviorIncidentReviews:submit
  Future<BehaviorIncidentReview> submitReview(String reviewId) async {
    try {
      final result = await _convexClient.mutation<Map<String, dynamic>>(
        'behaviorIncidentReviews:submit',
        args: {'id': reviewId},
      );

      return BehaviorIncidentReview.fromJson(result);
    } catch (e) {
      print('❌ Error submitting review: $e');
      rethrow;
    }
  }

  /// Update behavior incident review
  /// Calls: behaviorIncidentReviews:update
  Future<BehaviorIncidentReview> updateReview({
    required String reviewId,
    Map<String, dynamic>? updates,
  }) async {
    final args = <String, dynamic>{
      'id': reviewId,
      if (updates != null) ...updates,
    };

    final result = await _convexClient.mutation<Map<String, dynamic>>(
      'behaviorIncidentReviews:update',
      args: args,
    );

    return BehaviorIncidentReview.fromJson(result);
  }

  /// Acknowledge a review (support worker marks as read)
  /// Calls: behaviorIncidentReviews:acknowledge
  /// Now accepts acknowledged_by_clerk_id (string) instead of acknowledged_by (Convex ID)
  Future<BehaviorIncidentReview> acknowledgeReview({
    required String reviewId,
    required String acknowledgedByClerkId,
  }) async {
    try {
      final result = await _convexClient.mutation<Map<String, dynamic>>(
        'behaviorIncidentReviews:acknowledge',
        args: {
          'id': reviewId,
          'acknowledged_by_clerk_id': acknowledgedByClerkId,
        },
      );

      return BehaviorIncidentReview.fromJson(result);
    } catch (e) {
      print('❌ Error acknowledging review: $e');
      rethrow;
    }
  }

  /// Get review summary statistics
  /// Calls: behaviorIncidentReviews:getSummary
  /// Supports both reviewer_id (Convex ID) and reviewer_clerk_id (Clerk ID) for backward compatibility
  Future<ReviewSummary> getSummary({
    String? reviewerId, // Convex ID (for backward compatibility)
    String? reviewerClerkId, // Clerk ID (preferred)
  }) async {
    final args = <String, dynamic>{};
    if (reviewerClerkId != null) {
      args['reviewer_clerk_id'] = reviewerClerkId; // Prefer Clerk ID
    } else if (reviewerId != null) {
      args['reviewer_id'] = reviewerId; // Fallback to Convex ID for backward compatibility
    }

    final result = await _convexClient.query<Map<String, dynamic>>(
      'behaviorIncidentReviews:getSummary',
      args: args,
    );

    return ReviewSummary.fromJson(result);
  }

  /// Delete behavior incident review
  /// Calls: behaviorIncidentReviews:remove
  Future<void> deleteReview(String reviewId) async {
    await _convexClient.mutation(
      'behaviorIncidentReviews:remove',
      args: {'id': reviewId},
    );
  }
}
