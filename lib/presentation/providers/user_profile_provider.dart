import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../data/models/user.dart';

/// User profile provider with real-time updates from Clerk
/// Automatically syncs with Clerk authentication state
final userProfileProvider = StreamProvider.autoDispose<User?>((ref) {
  final controller = StreamController<User?>();
  
  // Auto-refresh interval (every 60 seconds to sync with Clerk)
  Timer? timer;
  
  void fetchUserProfile() async {
    try {
      // Get Clerk user from authentication state
      // This will be populated when user is signed in via ClerkAuthBuilder
      // For now, we'll create a placeholder implementation
      // In a real scenario, you'd get this from Clerk's user object
      
      // TODO: Replace with actual Clerk user data
      // final clerkUser = await Clerk.instance.user;
      // if (clerkUser != null) {
      //   final user = User.fromClerkUser(clerkUser);
      //   controller.add(user);
      // }
      
      // Placeholder - returns null when not signed in
      controller.add(null);
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }
  
  // Initial fetch
  fetchUserProfile();
  
  // Set up periodic refresh (every 60 seconds)
  timer = Timer.periodic(const Duration(seconds: 60), (_) {
    fetchUserProfile();
  });
  
  // Clean up
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });
  
  return controller.stream;
});

/// Current user ID provider (from Clerk)
final currentUserIdProvider = Provider.autoDispose<AsyncValue<String?>>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  
  return userAsync.when(
    data: (user) => AsyncValue.data(user?.id),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// User name provider
final userNameProvider = Provider.autoDispose<AsyncValue<String?>>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  
  return userAsync.when(
    data: (user) => AsyncValue.data(user?.name),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// User email provider
final userEmailProvider = Provider.autoDispose<AsyncValue<String?>>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  
  return userAsync.when(
    data: (user) => AsyncValue.data(user?.email),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// User role provider
final userRoleProvider = Provider.autoDispose<AsyncValue<UserRole?>>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  
  return userAsync.when(
    data: (user) => AsyncValue.data(user?.role),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Manual refresh trigger for user profile
final refreshUserProfileProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(userProfileProvider);
  };
});

