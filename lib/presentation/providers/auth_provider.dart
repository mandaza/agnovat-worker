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
  final bool isLoggingOut; // Flag to prevent profile reload during logout

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.isLoggingOut = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? isLoggingOut,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}

/// Auth state notifier that syncs with Clerk authentication
class AuthNotifier extends Notifier<AuthState> {
  Timer? _backgroundRetryTimer; // Keep track of background retry timer
  static bool _isLoggingOut = false; // Static flag that persists across rebuilds

  @override
  AuthState build() {
    // Schedule user profile loading AFTER build completes
    // This prevents "uninitialized provider" error
    // BUT: Don't load profile if we're in the middle of logging out
    Future.microtask(() {
      // Check static logout flag before trying to load profile
      if (!_isLoggingOut) {
        _loadUserProfile();
      } else {
        print('🚫 Auth Provider: Skipping profile load - logout in progress');
      }
    });

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
      var clerkId = prefs.getString('clerk_user_id');

      print('📊 Auth Provider: Loading user profile...');
      print('   - clerk_id: ${clerkId ?? 'NOT FOUND'}');

      // IMMEDIATE CHECK: If clerk_id is null, check if user just logged out
      // This prevents the 5-second wait loop during logout scenarios
      if (clerkId == null) {
        final cachedName = prefs.getString('clerk_user_name');
        final cachedEmail = prefs.getString('clerk_user_email');
        final allUserDataCleared = cachedName == null && cachedEmail == null;

        if (allUserDataCleared) {
          // All user data is cleared - this is a logout scenario
          print('🔍 Auth Provider: All user data cleared - user is signed out (immediate check)');
          state = state.copyWith(
            isLoading: false,
            error: null,
            isAuthenticated: false,
            user: null,
          );
          return;
        }

        // If some cached data exists, this might be a login-in-progress scenario
        // Wait a bit for login to complete (handles race condition during login)
        print('⏳ Auth Provider: clerk_id not found but cached data exists, waiting for login to complete...');
        // Wait up to 5 seconds for login to complete, checking every 200ms
        // Give enough time for sign-in process to save data to SharedPreferences
        for (int i = 0; i < 25; i++) {
          await Future.delayed(const Duration(milliseconds: 200));
          clerkId = prefs.getString('clerk_user_id');
          if (clerkId != null) {
            print('✅ Auth Provider: Found clerk_id after ${(i + 1) * 200}ms');
            break;
          }
          if (i % 10 == 9) {
            print('   Still waiting... (${(i + 1) * 200}ms elapsed)');
          }
        }
      }

      if (clerkId == null) {
        // Still no clerk_id found after initial retries
        // Check again if this might be a logout scenario
        final cachedName = prefs.getString('clerk_user_name');
        final cachedEmail = prefs.getString('clerk_user_email');
        final allUserDataCleared = cachedName == null && cachedEmail == null;

        if (allUserDataCleared) {
          // All user data is cleared - this is likely a logout
          print('🔍 Auth Provider: All user data cleared after retries - user is signed out');
          state = state.copyWith(
            isLoading: false,
            error: null,
            isAuthenticated: false,
            user: null,
          );
          return;
        } else {
          // Some cached data exists but no clerk_id - continue background retry
          print('⏳ Auth Provider: No clerk_id found but cached data exists - continuing background retry...');
          // Keep loading state active while retrying in background
          state = state.copyWith(
            isLoading: true,
            error: null,
            isAuthenticated: false,
            user: null,
          );
          _startBackgroundRetry();
          return;
        }
      }

      // Get cached user data from Clerk (available immediately)
      // Re-fetch in case they were cleared during retry
      final cachedNameFinal = prefs.getString('clerk_user_name');
      final cachedEmailFinal = prefs.getString('clerk_user_email');
      final cachedImageUrl = prefs.getString('clerk_user_image_url');

      print('   - cached name: ${cachedNameFinal ?? 'NOT FOUND'}');
      print('   - cached email: ${cachedEmailFinal ?? 'NOT FOUND'}');
      print('   - cached image: ${cachedImageUrl ?? 'NOT FOUND'}');

      // Ensure clerkId is not null at this point
      if (clerkId == null) {
        print('❌ Auth Provider: clerkId is still null after all retries');
        state = state.copyWith(
          isLoading: false,
          error: 'No authenticated user found. Please sign in again.',
          isAuthenticated: false,
        );
        return;
      }

      // Try to fetch from Convex first (most reliable source)
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
        return; // Success! Exit early
      } catch (convexError) {
        print('⚠️  Convex fetch failed: $convexError');
        // Fall back to cached data if Convex fetch fails
      }

      // If Convex fetch failed, try to use cached data
      // Only require email - name can be null/empty
      if (cachedEmailFinal != null && cachedEmailFinal.isNotEmpty) {
        print('✅ Auth Provider: Using cached Clerk data (Convex unavailable)');
        final cachedUser = User(
          id: clerkId,
          clerkId: clerkId,
          email: cachedEmailFinal,
          name: cachedNameFinal ?? 'User', // Default to 'User' if name is null
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
        print('❌ Auth Provider: No cached email found and Convex unavailable');
        print('   - clerk_id: $clerkId');
        print('   - cached email: ${cachedEmailFinal ?? 'NULL'}');
        // Neither Convex nor cached data available
        state = state.copyWith(
          isLoading: false,
          error: 'Unable to load profile. Please sign out and sign in again to sync your profile.',
          isAuthenticated: true,
        );
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

  /// Start background retry for authentication
  /// This keeps trying until authentication data is found or user logs out
  void _startBackgroundRetry() {
    // Cancel any existing background retry first
    _backgroundRetryTimer?.cancel();
    
    print('🔄 Auth Provider: Starting indefinite background retry...');
    _backgroundRetryTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final clerkId = prefs.getString('clerk_user_id');
        
        if (clerkId != null) {
          // Found clerk_id, stop retrying and load profile
          print('✅ Auth Provider: Background retry found clerk_id after ${timer.tick * 0.5} seconds');
          timer.cancel();
          _backgroundRetryTimer = null;
          // Reset loading state and restart the full profile load process
          state = state.copyWith(isLoading: true);
          await _loadUserProfile();
          return;
        }
        
        // Check if user logged out during background retry
        final cachedName = prefs.getString('clerk_user_name');
        final cachedEmail = prefs.getString('clerk_user_email');
        final allUserDataCleared = cachedName == null && cachedEmail == null;
        
        if (allUserDataCleared) {
          // User logged out, stop retrying
          print('🔍 Auth Provider: User logged out during background retry');
          timer.cancel();
          _backgroundRetryTimer = null;
          state = state.copyWith(
            isLoading: false,
            error: null,
            isAuthenticated: false,
            user: null,
          );
          return;
        }
        
        // Continue waiting - log every 20 seconds
        if (timer.tick % 40 == 0) { // Every 40 attempts (20 seconds)
          print('⏳ Auth Provider: Still waiting for authentication data... (${timer.tick * 0.5}s elapsed)');
        }
        
      } catch (e) {
        print('❌ Auth Provider: Background retry error: $e');
        // Continue retrying even on error
      }
      
      // NO TIMEOUT - continue indefinitely until auth data is found or user logs out
      // This ensures user never sees error screens during normal login flow
    });
  }

  /// Stop background retry (called during logout)
  void _stopBackgroundRetry() {
    if (_backgroundRetryTimer != null) {
      print('🛑 Auth Provider: Stopping background retry');
      _backgroundRetryTimer!.cancel();
      _backgroundRetryTimer = null;
    }
  }

  /// Force logout and stop all background processes
  void forceLogout() {
    print('🚪 Auth Provider: Force logout called');
    _stopBackgroundRetry();
    _isLoggingOut = true; // Set static flag to prevent profile reload across rebuilds
    state = state.copyWith(
      isLoading: false,
      error: null,
      isAuthenticated: false,
      user: null,
      isLoggingOut: true, // Also set instance flag
    );
  }

  /// Reset logout flag and trigger profile load (called after user data is saved during sign-in)
  void resetLogoutFlag() {
    print('🔄 Auth Provider: Resetting logout flag and loading profile');
    _isLoggingOut = false;
    state = state.copyWith(
      isLoggingOut: false,
    );
    // Trigger profile load now that logout flag is reset and user data is saved
    _loadUserProfile();
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

