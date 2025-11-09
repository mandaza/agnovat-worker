import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import '../../core/providers/service_providers.dart';

/// Auth state - keeping the same structure for compatibility
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth state notifier that syncs with Clerk authentication
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Schedule user profile loading AFTER build completes
    // This prevents "uninitialized provider" error
    Future.microtask(() => _loadUserProfile());

    return const AuthState();
  }

  /// Load user profile from Convex using Clerk user ID
  /// Requires clerk_id stored in SharedPreferences (saved after login)
  /// Falls back to cached Clerk data if Convex is unavailable
  Future<void> _loadUserProfile() async {
    try {
      // Now safe to modify state - build() has completed
      state = state.copyWith(isLoading: true);

      // Get user data from local storage (saved after Clerk login)
      final prefs = await SharedPreferences.getInstance();
      final clerkId = prefs.getString('clerk_user_id');

      print('📊 Auth Provider: Loading user profile...');
      print('   - clerk_id: ${clerkId ?? 'NOT FOUND'}');

      if (clerkId == null) {
        // No clerk_id found - user not logged in
        print('❌ Auth Provider: No clerk_id found - user not authenticated');
        state = state.copyWith(
          isLoading: false,
          error: 'No authenticated user found. Please sign in again.',
          isAuthenticated: false,
        );
        return;
      }

      // Get cached user data from Clerk (available immediately)
      final cachedName = prefs.getString('clerk_user_name');
      final cachedEmail = prefs.getString('clerk_user_email');
      final cachedImageUrl = prefs.getString('clerk_user_image_url');

      print('   - cached name: ${cachedName ?? 'NOT FOUND'}');
      print('   - cached email: ${cachedEmail ?? 'NOT FOUND'}');
      print('   - cached image: ${cachedImageUrl ?? 'NOT FOUND'}');

      // Create a temporary user from cached Clerk data
      // This ensures the user sees their name immediately
      if (cachedName != null && cachedEmail != null) {
        print('✅ Auth Provider: Using cached Clerk data');
        final cachedUser = User(
          id: clerkId,
          clerkId: clerkId,
          email: cachedEmail,
          name: cachedName,
          imageUrl: cachedImageUrl,
          role: UserRole.supportWorker, // Default role
          active: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        state = state.copyWith(
          user: cachedUser,
          isLoading: false,
          isAuthenticated: true,
          error: null,
        );
      } else {
        print('⚠️  Auth Provider: No cached user data found - user needs to sign in again');
        // No cached data - user needs to sign in again to cache their data
        state = state.copyWith(
          isLoading: false,
          error: 'Please sign out and sign in again to sync your profile.',
          isAuthenticated: true, // Keep them logged in but show the error
        );
        return;
      }

      // Now try to fetch full profile from Convex in the background
      // This will update with more complete data if available
      print('🔄 Auth Provider: Fetching from Convex...');
      try {
        final apiService = ref.read(mcpApiServiceProvider);
        final convexUser = await apiService.getCurrentUser(clerkId: clerkId);

        print('✅ Auth Provider: Got user from Convex');
        // Update with full Convex profile
        state = state.copyWith(
          user: convexUser,
          isLoading: false,
          isAuthenticated: true,
          error: null,
        );
      } catch (convexError) {
        // Convex fetch failed, but we already have cached data showing
        // So just log the error but don't update state
        print('⚠️  Convex user fetch failed (using cached data): $convexError');
      }
    } catch (e) {
      // Critical error - no cached data available
      print('❌ Auth Provider: Critical error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  /// Manually refresh user profile
  Future<void> refresh() async {
    await _loadUserProfile();
  }
}

/// Main auth provider with Clerk integration
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

